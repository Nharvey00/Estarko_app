import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../views/auth_routing_screens.dart';
import '../views/role_selection_dialog.dart';
import '../views/login_screen.dart';
import '../../../shared/widgets/estar_friendly_error.dart';

export '../views/auth_routing_screens.dart';
export '../views/role_selection_dialog.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  FirebaseFirestore? _firestore;
  FirebaseAuth? _auth;
  StreamSubscription<DocumentSnapshot>? _userSubscription;

  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isInitialLoading = false;
  String _errorMessage = '';

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isInitialLoading => _isInitialLoading;
  String get errorMessage => _errorMessage;

  FirebaseFirestore get firestore => _firestore ??= FirebaseFirestore.instance;
  FirebaseAuth get auth => _auth ??= FirebaseAuth.instance;

  AuthProvider({
    AuthService? authService,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    UserModel? initialUser,
    bool autoCheckCurrentUser = true,
  })  : _authService = authService ??
            (auth != null || firestore != null
                ? AuthService(auth: auth, firestore: firestore)
                : AuthService()),
        _firestore = firestore,
        _auth = auth,
        _currentUser = initialUser {
    if (autoCheckCurrentUser) {
      _checkCurrentUser();
    }
  }

  void _listenToUser(String uid) {
    _userSubscription?.cancel();
    _userSubscription = firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen(
      (doc) {
        if (doc.exists && doc.data() != null) {
          _currentUser =
              UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          notifyListeners();
        }
      },
      onError: (e, stackTrace) {
        debugPrint('Error listening to user snapshot: $e\n$stackTrace');
      },
    );
  }

  /// Attempt to restore user session on app launch.
  /// Edge case handling: If an authenticated Firebase user lacks a Firestore document
  /// (e.g. app was terminated during role selection), sign them out to prevent orphaned accounts.
  Future<void> _checkCurrentUser() async {
    final firebaseUser = auth.currentUser;
    if (firebaseUser != null) {
      _isInitialLoading = true;
      _isLoading = true;
      notifyListeners();
      try {
        _currentUser = await _authService.getUserData(firebaseUser.uid);
        if (_currentUser == null) {
          // Orphaned account found without Firestore record; sign out cleanly
          debugPrint('Orphaned account without Firestore record found on startup. Signing out: ${firebaseUser.uid}');
          await _authService.signOut();
        } else {
          _listenToUser(firebaseUser.uid);
        }
      } catch (e, stackTrace) {
        debugPrint('Error restoring user session on launch: $e\n$stackTrace');
        _currentUser = null;
        await _authService.signOut();
      } finally {
        _isInitialLoading = false;
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  /// Centralized routing destination resolver matching strict role rules:
  /// - Tenant -> MapDashboardScreen
  /// - Landlord (verified == true) -> LandlordDashboardScreen
  /// - Landlord (verified == false) -> AccountVerificationScreen
  /// - Admin -> AdminReviewDashboardScreen
  Widget getDestinationScreen(UserModel user) {
    final role = user.role.toLowerCase().trim();

    if (role == 'tenant') {
      return const MapDashboardScreen();
    }
    if ((role == 'landlord' || role == 'seller') && user.isVerified == true) {
      return const LandlordDashboardScreen();
    }
    if ((role == 'landlord' || role == 'seller') && user.isVerified == false) {
      return const AccountVerificationScreen();
    }
    if (role == 'admin') {
      return const AdminReviewDashboardScreen();
    }

    return const MapDashboardScreen();
  }

  /// Centralized routing handler applying strict routing rules to all auth methods
  void routeUser(BuildContext context, UserModel user) {
    final destination = getDestinationScreen(user);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => destination),
      (route) => false,
    );
  }

  /// Google Sign-In with Interrupted State & Role Assignment handling:
  /// 1. Signs in via Google standard flow.
  /// 2. Queries 'users' collection for the user's uid.
  /// 3. Returning User: Routes immediately using strict routing rules.
  /// 4. New User: Pauses auth flow and presents non-dismissible RoleSelectionDialog.
  /// 5. Edge Case Protection: If role selection is dismissed or cancelled,
  ///    signs out of Firebase Auth to prevent orphaned accounts.
  Future<bool> loginWithGoogle(BuildContext context) async {
    _setLoading(true);
    _errorMessage = '';

    try {
      final credential = await _authService.signInWithGoogle();

      if (credential == null || credential.user == null) {
        // User aborted or dismissed the Google account picker
        debugPrint('Google Sign-In cancelled by user in account picker.');
        _setLoading(false);
        return false;
      }

      final firebaseUser = credential.user!;
      debugPrint('Google Sign-In authenticated successfully. UID: ${firebaseUser.uid}');

      // Query the 'users' collection for existing document
      final docRef = firestore.collection('users').doc(firebaseUser.uid);
      final doc = await docRef.get();

      if (doc.exists && doc.data() != null) {
        // Existing user: Extract role and isVerified, then route immediately
        debugPrint('Existing user found in Firestore for UID: ${firebaseUser.uid}');
        final existingUser =
            UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        _currentUser = existingUser;
        _listenToUser(existingUser.uid);
        _setLoading(false);

        if (context.mounted) {
          routeUser(context, existingUser);
        }
        return true;
      } else {
        // New Google user: Pause auth flow and prompt for role selection
        debugPrint('New user detected. Prompting for role assignment (UID: ${firebaseUser.uid})');
        _setLoading(false);

        if (!context.mounted) {
          debugPrint('Context unmounted before showing RoleSelectionDialog. Signing out.');
          await _authService.signOut();
          _currentUser = null;
          return false;
        }

        final selectedRole = await RoleSelectionDialog.show(
          context,
          barrierDismissible: false,
        );

        // Edge case: User dismissed the dialog or closed without picking a role
        if (selectedRole == null || selectedRole.isEmpty) {
          debugPrint('Role selection cancelled or dismissed. Signing out to prevent orphaned account.');
          await _authService.signOut();
          _currentUser = null;
          _errorMessage = 'Role selection was cancelled. Please try again.';
          _setLoading(false);
          return false;
        }

        // Resume loading while creating Firestore user profile
        _setLoading(true);

        final cleanRole = selectedRole.trim().toLowerCase();
        final bool isVerified = cleanRole == 'tenant';
        final String displayName = firebaseUser.displayName ?? '';
        final String email = firebaseUser.email ?? '';

        await docRef.set({
          'uid': firebaseUser.uid,
          'email': email,
          'displayName': displayName,
          'name': displayName,
          'role': cleanRole,
          'isVerified': isVerified,
          'inquiryCountToday': 0,
          'activeListingCount': 0,
          'createdAt': FieldValue.serverTimestamp(),
        });

        final newUser = UserModel(
          uid: firebaseUser.uid,
          name: displayName,
          email: email,
          role: cleanRole,
          isVerified: isVerified,
          inquiryCountToday: 0,
          activeListingCount: 0,
          createdAt: DateTime.now(),
        );

        _currentUser = newUser;
        _listenToUser(newUser.uid);
        _setLoading(false);

        if (context.mounted) {
          routeUser(context, newUser);
        }
        return true;
      }
    } catch (e, stackTrace) {
      debugPrint('Error in loginWithGoogle: $e\n$stackTrace');
      _errorMessage = EstarFriendlyError.mask(e);
      try {
        await _authService.signOut();
      } catch (signOutErr) {
        debugPrint('Error signing out after Google Sign-In failure: $signOutErr');
      }
      _currentUser = null;
      _setLoading(false);
      return false;
    }
  }

  /// Email/Password Log in wrapper
  Future<bool> login(
    String email,
    String password, {
    BuildContext? context,
  }) async {
    _setLoading(true);
    _errorMessage = '';
    try {
      _currentUser =
          await _authService.signInWithEmailAndPassword(email, password);
      if (_currentUser != null) {
        _listenToUser(_currentUser!.uid);
        _setLoading(false);
        if (context != null && context.mounted) {
          routeUser(context, _currentUser!);
        }
        return true;
      }
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = EstarFriendlyError.mask(e);
      _setLoading(false);
      return false;
    }
  }

  /// Register wrapper
  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String role,
    BuildContext? context,
  }) async {
    _setLoading(true);
    _errorMessage = '';
    try {
      _currentUser = await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
        role: role,
      );
      if (_currentUser != null) {
        _listenToUser(_currentUser!.uid);
        _setLoading(false);
        if (context != null && context.mounted) {
          routeUser(context, _currentUser!);
        }
        return true;
      }
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = EstarFriendlyError.mask(e);
      _setLoading(false);
      return false;
    }
  }

  /// Sign out wrapper. If [context] is provided, safely navigates back to LoginScreen.
  Future<void> logout({BuildContext? context}) async {
    _setLoading(true);
    await _userSubscription?.cancel();
    _userSubscription = null;
    try {
      await _authService.signOut();
    } catch (e, stackTrace) {
      debugPrint('Sign out warning: $e\n$stackTrace');
    }
    _currentUser = null;
    _errorMessage = '';
    _setLoading(false);

    if (context != null && context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  /// Delete user account and wipe session for store-ready compliance
  Future<bool> deleteAccount() async {
    if (_currentUser == null) return false;
    _setLoading(true);
    _errorMessage = '';
    try {
      final uid = _currentUser!.uid;
      await _userSubscription?.cancel();
      _userSubscription = null;
      await _authService.deleteAccount(uid);
      _currentUser = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = EstarFriendlyError.mask(e);
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }
}