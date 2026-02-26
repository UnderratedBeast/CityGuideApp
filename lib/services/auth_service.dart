// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../models/auth_models.dart';

// class AuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   // Stream of auth state changes
//   Stream<User?> get authStateChanges => _auth.authStateChanges();

//   // Get current user
//   User? get currentUser => _auth.currentUser;

//   // ------------------- SIGN IN -------------------
// Future<UserModel?> signIn({
//   required String email,
//   required String password,
// }) async {
//   try {
//     final userCredential = await _auth.signInWithEmailAndPassword(
//       email: email.trim(),
//       password: password,
//     );

//     final user = userCredential.user;

//     if (user != null) {

//       // 🔥 CHECK EMAIL VERIFIED
//       if (!user.emailVerified) {
//         await user.sendEmailVerification();
//         await _auth.signOut();
//         throw Exception(
//           'Email not verified. A verification link has been sent.',
//         );
//       }

//       return await _getUserData(user.uid);
//     }

//     return null;
//   } on FirebaseAuthException catch (e) {
//     throw Exception(_handleAuthException(e));
//   }
// }

// Future<void> resendVerificationEmail() async {
//   final user = _auth.currentUser;
//   if (user != null && !user.emailVerified) {
//     await user.sendEmailVerification();
//   }
// }

//   // ------------------- SIGN UP -------------------
//   Future<UserModel?> signUp({
//     required String email,
//     required String password,
//     required String fullName,
//   }) async {
//     try {
//       final userCredential = await _auth.createUserWithEmailAndPassword(
//         email: email.trim(),
//         password: password,
//       );

//       final user = userCredential.user;
//       if (user != null) {
//         final newUser = UserModel.fromFirebaseUser(
//           user.uid,
//           email.trim(),
//           fullName.trim(),
//           photoUrl: user.photoURL,
//         );

//         await _firestore
//             .collection('users')
//             .doc(user.uid)
//             .set(newUser.toMap());

//         return newUser;
//       }

//       return null;
//     } on FirebaseAuthException catch (e) {
//       throw Exception(_handleAuthException(e));
//     } catch (_) {
//       throw Exception('An unknown error occurred');
//     }
//   }

//   // ------------------- PASSWORD RESET -------------------
//   Future<void> sendPasswordReset(String email) async {
//     try {
//       await _auth.sendPasswordResetEmail(email: email.trim());
//     } on FirebaseAuthException catch (e) {
//       throw Exception(_handleAuthException(e));
//     }
//   }

//   // ------------------- SIGN OUT -------------------
//   Future<void> signOut() async {
//     await _auth.signOut();
//   }

//   // ------------------- GET USER DATA -------------------
//   Future<UserModel?> getUserData(String uid) async {
//     return _getUserData(uid);
//   }

//   Future<UserModel?> _getUserData(String uid) async {
//     try {
//       final doc = await _firestore.collection('users').doc(uid).get();
//       if (doc.exists) {
//         return UserModel.fromDocument(doc);
//       }
//       return null;
//     } catch (_) {
//       throw Exception('Failed to fetch user data');
//     }
//   }

//   // ------------------- ERROR HANDLING -------------------
//   String _handleAuthException(FirebaseAuthException e) {
//     switch (e.code) {
//       case 'user-not-found':
//         return 'No user found with this email.';
//       case 'wrong-password':
//         return 'Wrong password provided.';
//       case 'email-already-in-use':
//         return 'An account already exists with this email.';
//       case 'weak-password':
//         return 'The password provided is too weak.';
//       case 'invalid-email':
//         return 'The email address is badly formatted.';
//       case 'too-many-requests':
//         return 'Too many attempts. Please try again later.';
//       default:
//         return 'Authentication failed. Please try again.';
//     }
//   }
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/auth_models.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔹 Stream for auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  // ================= SIGN IN =================
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // 1️⃣ Sign in with Firebase Auth
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) return null;

      // 2️⃣ Get Firestore user data
      final userData = await getUserData(user.uid);

      // 3️⃣ Only enforce email verification for non-admins
      if (!user.emailVerified && !userData.isAdmin) {
        await user.sendEmailVerification();
        await _auth.signOut();
        throw Exception(
          "Email not verified. A verification link has been sent.",
        );
      }

      // 4️⃣ Return user data
      return userData;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    }
  }

  // ================= SIGN UP =================
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String fullName,
    String role = "user", // default role, can be 'admin' if needed
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) return null;

      // Send verification email for normal users
      if (role != "admin") {
        await user.sendEmailVerification();
      }

      final now = DateTime.now();

      // Create new user document in Firestore
      final newUser = UserModel(
        uid: user.uid,
        email: email.trim(),
        fullName: fullName.trim(),
        role: role, // admin or user
        photoUrl: user.photoURL,
        createdAt: now,
        updatedAt: now,
      );

      await _firestore.collection('users').doc(user.uid).set(newUser.toMap());

      // Only sign out non-admin users to force email verification
      if (!newUser.isAdmin) {
        await _auth.signOut();
        throw Exception(
          "Account created. Please verify your email before logging in.",
        );
      }

      return newUser; // admin can login immediately
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    }
  }

  // ================= RESEND VERIFICATION =================
  Future<void> resendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  // ================= PASSWORD RESET =================
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    }
  }

  // ================= LOGOUT =================
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ================= UPDATEUSERNAME =================

  Future<void> updateUserName({
  required String uid,
  required String newName,
}) async {
  await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .update({
    'fullName': newName,
  });
}

  // ================= GET USER DATA =================
  Future<UserModel> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();

    if (!doc.exists) {
      throw Exception("User data not found.");
    }

    return UserModel.fromDocument(doc);
  }

  // ================= ERROR HANDLING =================
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}