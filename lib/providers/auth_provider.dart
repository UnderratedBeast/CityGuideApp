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

  // ================= UPDATE PROFILE NAME =================
Future<bool> updateProfileName(String newName) async {
  _setLoading();

  try {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      _setError("User not authenticated");
      return false;
    }

    // Update in Firestore via AuthService
    await _authService.updateUserName(
      uid: currentUser.uid,
      newName: newName,
    );

    // Update local user model
    _user = _user?.copyWith(fullName: newName);

    _status = AuthStatus.authenticated;
    notifyListeners();
    return true;
  } catch (e) {
    _setError(e.toString().replaceFirst("Exception: ", ""));
    return false;
  }
}

// ================= CHANGE PASSWORD =================
Future<bool> changePassword(
  String currentPassword,
  String newPassword,
) async {
  _setLoading();

  try {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.email == null) {
      _setError("User not authenticated");
      return false;
    }

    // Re-authenticate user
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );

    await user.reauthenticateWithCredential(credential);

    // Update password
    await user.updatePassword(newPassword);

    _status = AuthStatus.authenticated;
    notifyListeners();
    return true;
  } on FirebaseAuthException catch (e) {
    _setError(e.message ?? "Password change failed");
    return false;
  } catch (e) {
    _setError("Something went wrong");
    return false;
  }
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