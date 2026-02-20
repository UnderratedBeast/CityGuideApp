// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../models/auth_models.dart';
// import '../services/auth_service.dart';

// class AuthProvider extends ChangeNotifier {
//   final AuthService _authService = AuthService();

//   UserModel? _user;
//   AuthStatus _status = AuthStatus.initial;
//   String? _errorMessage;

//   UserModel? get user => _user;
//   String? get role => _user?.role;
//   AuthStatus get status => _status;
//   String? get errorMessage => _errorMessage;
//   bool get isLoading => _status == AuthStatus.loading;
//   bool get isAuthenticated => _status == AuthStatus.authenticated;
//   bool get isAdmin => _user?.role == 'admin';

//   AuthProvider() {
//     _init();
//   }

//   void _init() {
//     _authService.authStateChanges.listen((User? firebaseUser) async {
//       if (firebaseUser == null) {
//         _user = null;
//         _status = AuthStatus.unauthenticated;
//         notifyListeners();
//       } else {
//         _status = AuthStatus.loading;
//         notifyListeners();

//         try {
//           final userModel =
//               await _authService.getUserData(firebaseUser.uid);

//           _user = userModel;
//           _status = AuthStatus.authenticated;
//           _errorMessage = null;
//         } catch (e) {
//           _errorMessage = e.toString();
//           _status = AuthStatus.error;
//         }

//         notifyListeners();
//       }
//     });
//   }

//   // ---------------- LOGIN ----------------
//   Future<bool> login(String email, String password) async {
//     _setLoading();

//     try {
//       final user = await _authService.signIn(
//         email: email,
//         password: password,
//       );

//       if (user != null) {
//         _user = user;
//         _status = AuthStatus.authenticated;
//         _errorMessage = null;
//         notifyListeners();
//         return true;
//       }

//       _setError('Login failed');
//       return false;
//     } catch (e) {
//       _setError(e.toString().replaceFirst('Exception: ', ''));
//       return false;
//     }
//   }

//   // ---------------- REGISTER ----------------
//   Future<bool> register({
//     required String email,
//     required String password,
//     required String fullName,
//   }) async {
//     _setLoading();

//     try {
//       final user = await _authService.signUp(
//         email: email,
//         password: password,
//         fullName: fullName,
//       );

//       if (user != null) {
//         _user = user;
//         _status = AuthStatus.authenticated;
//         _errorMessage = null;
//         notifyListeners();
//         return true;
//       }

//       _setError('Registration failed');
//       return false;
//     } catch (e) {
//       _setError(e.toString().replaceFirst('Exception: ', ''));
//       return false;
//     }
//   }

//   // ---------------- PASSWORD RESET ----------------
//   Future<bool> sendPasswordReset(String email) async {
//     _setLoading();

//     try {
//       await _authService.sendPasswordReset(email);

//       _status = AuthStatus.unauthenticated;
//       _errorMessage = null;
//       notifyListeners();
//       return true;
//     } catch (e) {
//       _setError(e.toString().replaceFirst('Exception: ', ''));
//       return false;
//     }
//   }

//   // ---------------- LOGOUT ----------------
//   Future<void> logout() async {
//     _setLoading();

//     try {
//       await _authService.signOut();
//       _user = null;
//       _status = AuthStatus.unauthenticated;
//       notifyListeners();
//     } catch (e) {
//       _setError(e.toString());
//     }
//   }

//   // ---------------- RESENDVERIFICATION ----------------

//   Future<bool> resendVerification() async {
//   try {
//     await _authService.resendVerificationEmail();
//     return true;
//   } catch (e) {
//     _setError(e.toString());
//     return false;
//   }
// }

//   // ---------------- HELPERS ----------------
//   void _setLoading() {
//     _status = AuthStatus.loading;
//     _errorMessage = null;
//     notifyListeners();
//   }

//   void _setError(String message) {
//     _status = AuthStatus.error;
//     _errorMessage = message;
//     notifyListeners();
//   }

//   void clearError() {
//     _errorMessage = null;
//     notifyListeners();
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/auth_models.dart';
import '../services/auth_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;

  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isAdmin => _user?.role == "admin";

  AuthProvider() {
    _listenToAuthState();
  }

  void _listenToAuthState() {
    _authService.authStateChanges.listen((User? firebaseUser) async {
      if (firebaseUser == null) {
        _user = null;
        _status = AuthStatus.unauthenticated;
        notifyListeners();
      } else {
        _status = AuthStatus.loading;
        notifyListeners();

        try {
          _user = await _authService.getUserData(firebaseUser.uid);
          _status = AuthStatus.authenticated;
        } catch (e) {
          _errorMessage = e.toString();
          _status = AuthStatus.error;
        }

        notifyListeners();
      }
    });
  }

  // ================= LOGIN =================
  Future<bool> login(String email, String password) async {
    _setLoading();

    try {
      final user = await _authService.signIn(
        email: email,
        password: password,
      );

      if (user == null) {
        _setError("Login failed");
        return false;
      }

      _user = user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst("Exception: ", ""));
      return false;
    }
  }

  // ================= REGISTER =================
  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    _setLoading();

    try {
      await _authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );

      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst("Exception: ", ""));
      return false;
    }
  }

  // ================= PASSWORD RESET =================
  Future<bool> sendPasswordReset(String email) async {
    _setLoading();

    try {
      await _authService.sendPasswordReset(email);
      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst("Exception: ", ""));
      return false;
    }
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    await _authService.signOut();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // ================= INTERNAL HELPERS =================
  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = AuthStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}