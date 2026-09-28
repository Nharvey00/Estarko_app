import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  StreamSubscription<DocumentSnapshot>? _userSubscription;

  UserModel? _currentUser;
  bool _isLoading = false;
  String _errorMessage = '';

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  AuthProvider() {
    _checkCurrentUser();
  }

  void _listenToUser(String uid) {
    _userSubscription?.cancel();
    _userSubscription = FirebaseFirestore.instance
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
      onError: (e) {
        debugPrint('Error listening to user snapshot: $e');
      },
    );
  }

  // Attempt to restore user session on app launch
  Future<void> _checkCurrentUser() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      _isLoading = true;
      notifyListeners();
      try {
        _currentUser = await _authService.getUserData(firebaseUser.uid);
        _listenToUser(firebaseUser.uid);
      } catch (_) {
        _currentUser = null;
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  // Log in wrapper
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = '';
    try {
      _currentUser = await _authService.login(email, password);
      if (_currentUser != null) {
        _listenToUser(_currentUser!.uid);
      }
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  // Register wrapper
  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    _setLoading(true);
    _errorMessage = '';
    try {
      _currentUser = await _authService.register(email, password, name, role);
      if (_currentUser != null) {
        _listenToUser(_currentUser!.uid);
      }
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  // Sign out wrapper
  Future<void> logout() async {
    _setLoading(true);
    await _userSubscription?.cancel();
    _userSubscription = null;
    await _authService.signOut();
    _currentUser = null;
    _errorMessage = '';
    _setLoading(false);
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