import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Log in existing user and fetch user profile
  Future<UserModel> login(String email, String password) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
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

  // Register new user, create Auth record, and create Firestore user document
  Future<UserModel> register(
    String email,
    String password,
    String name,
    String role,
  ) async {
    try {
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
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

      await _firestore
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

  // Fetch Firestore user document
  Future<UserModel?> getUserData(String uid) async {
    try {
      final DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      throw Exception('Failed to load user profile: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}