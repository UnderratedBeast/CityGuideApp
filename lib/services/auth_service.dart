// import 'package:firebase_auth/firebase_auth.dart';

// class AuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   Stream<User?> get authStateChanges => _auth.authStateChanges();
//   User? get currentUser => _auth.currentUser;

//   // Sign Up
//   Future<UserCredential> signUpWithEmail(String email, String password) async {
//     return await _auth.createUserWithEmailAndPassword(
//       email: email,
//       password: password,
//     );
//   }

//   // Login
//   Future<UserCredential> signInWithEmail(String email, String password) async {
//     return await _auth.signInWithEmailAndPassword(
//       email: email,
//       password: password,
//     );
//   }

//   // Password Reset
//   Future<void> sendPasswordResetEmail(String email) async {
//     await _auth.sendPasswordResetEmail(email: email);
//   }

//   // Sign Out
//   Future<void> signOut() async {
//     await _auth.signOut();
//   }
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/auth_models.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user from Firebase Auth
  User? get currentUser => _auth.currentUser;

  // ------------------- Sign In -------------------
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        return await _getUserData(user.uid);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unknown error occurred');
    }
  }

  // ------------------- Sign Up -------------------
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      // Create user in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        // Create user document in Firestore
        final newUser = UserModel.fromFirebaseUser(
          user.uid,
          email.trim(),
          fullName.trim(),
          photoUrl: user.photoURL,
        );

        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(newUser.toMap());

        return newUser;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unknown error occurred');
    }
  }

  // ------------------- Sign Out -------------------
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ------------------- Get User Data from Firestore -------------------
  
  Future<UserModel?> getUserData(String uid) async {
    return _getUserData(uid);
  }

  Future<UserModel?> _getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromDocument(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch user data');
    }
  }


  // ------------------- Error Handling -------------------
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-email':
        return 'The email address is badly formatted.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}