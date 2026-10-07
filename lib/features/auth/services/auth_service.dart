import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthService {
  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;
  GoogleSignIn? _googleSignIn;

  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  }) {
    _auth = auth;
    _firestore = firestore;
    _googleSignIn = googleSignIn;
  }

  FirebaseAuth get auth => _auth ??= FirebaseAuth.instance;
  FirebaseFirestore get firestore => _firestore ??= FirebaseFirestore.instance;
  GoogleSignIn get googleSignIn => _googleSignIn ??= GoogleSignIn();

  /// Standard Google Sign-In flow:
  /// 1. Trigger GoogleSignIn().signIn()
  /// 2. Obtain GoogleSignInAuthentication
  /// 3. Create GoogleAuthProvider credential
  /// 4. Sign in with credential to Firebase Auth
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // User aborted or closed the Google account selector
        debugPrint('Google Sign-In aborted by user in account picker.');
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e, stackTrace) {
      debugPrint('FirebaseAuthException during signInWithGoogle: [${e.code}] ${e.message}\n$stackTrace');
      throw Exception(e.message ?? 'Google Sign-In authentication error.');
    } catch (e, stackTrace) {
      debugPrint('Exception during signInWithGoogle: $e\n$stackTrace');
      throw Exception('Google Sign-In failed: $e');
    }
  }

  /// Sign in existing user with email and password, then fetch Firestore profile
  Future<UserModel> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final UserCredential credential = await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final User? firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw Exception('User authentication failed.');
      }

      final UserModel? userModel = await getUserData(firebaseUser.uid);
      if (userModel == null) {
        throw Exception('User profile not found in database.');
      }

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Authentication error occurred.');
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  /// Register new user with email/password and create user record in Firestore
  Future<UserModel> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      final UserCredential credential =
          await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final User? firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw Exception('User registration failed.');
      }

      await firebaseUser.updateDisplayName(name.trim());

      final UserModel newUser = UserModel(
        uid: firebaseUser.uid,
        name: name.trim(),
        email: email.trim(),
        role: role,
        isVerified: false,
        inquiryCountToday: 0,
        activeListingCount: 0,
        createdAt: DateTime.now(),
      );

      await firestore
          .collection('users')
          .doc(newUser.uid)
          .set(newUser.toMap());

      return newUser;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Registration error occurred.');
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  /// Backward-compatible alias for login
  Future<UserModel> login(String email, String password) =>
      signInWithEmailAndPassword(email, password);

  /// Backward-compatible alias for register
  Future<UserModel> register(
    String email,
    String password,
    String name,
    String role,
  ) =>
      registerWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
        role: role,
      );

  /// Create new user document in Firestore (used for new Google Sign-In users)
  Future<UserModel> createUserProfile({
    required String uid,
    required String name,
    required String email,
    required String role,
  }) async {
    final cleanRole = role.trim().toLowerCase();
    final bool isVerified = cleanRole == 'tenant';
    final trimmedName = name.trim();
    final trimmedEmail = email.trim();

    final UserModel newUser = UserModel(
      uid: uid,
      name: trimmedName,
      email: trimmedEmail,
      role: cleanRole,
      isVerified: isVerified,
      inquiryCountToday: 0,
      activeListingCount: 0,
      createdAt: DateTime.now(),
    );

    final Map<String, dynamic> docMap = {
      'uid': uid,
      'email': trimmedEmail,
      'displayName': trimmedName,
      'name': trimmedName,
      'role': cleanRole,
      'isVerified': isVerified,
      'inquiryCountToday': 0,
      'activeListingCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
    };

    try {
      await firestore.collection('users').doc(uid).set(docMap);
      return newUser;
    } catch (e, stackTrace) {
      debugPrint('Error creating user profile in Firestore: $e\n$stackTrace');
      rethrow;
    }
  }

  /// Fetch Firestore user document
  Future<UserModel?> getUserData(String uid) async {
    try {
      final DocumentSnapshot doc =
          await firestore.collection('users').doc(uid).get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e, stackTrace) {
      debugPrint('Failed to load user profile for $uid: $e\n$stackTrace');
      throw Exception('Failed to load user profile: $e');
    }
  }

  /// Sign out from both Firebase Auth and Google Sign-In
  Future<void> signOut() async {
    try {
      await googleSignIn.signOut().timeout(const Duration(seconds: 3));
    } catch (_) {}
    try {
      await auth.signOut().timeout(const Duration(seconds: 3));
    } catch (_) {}
  }

  /// Delete user profile and account for store-ready compliance
  Future<void> deleteAccount(String uid) async {
    try {
      await firestore.collection('users').doc(uid).delete();
    } catch (_) {}
    final currentUser = auth.currentUser;
    if (currentUser != null) {
      await currentUser.delete();
    }
  }
}