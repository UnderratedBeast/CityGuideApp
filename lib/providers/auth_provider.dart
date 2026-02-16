import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import '../models/auth_models.dart';
import '../services/auth_service.dart';          

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;

  UserModel? get user => _user;
  String? get role => _user?.role;            // Add this getter
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isAdmin => _user?.role == 'admin'; // keep this for quick checks

  AuthProvider() {
    _init();
  }

  void _init() {
    _authService.authStateChanges.listen((User? firebaseUser) async {
      if (firebaseUser == null) {
        _user = null;
        _status = AuthStatus.unauthenticated;
        notifyListeners();
      } else {
        _status = AuthStatus.loading;
        notifyListeners();
        try {
          final userModel = await _authService.getUserData(firebaseUser.uid);
          _user = userModel;
          _status = AuthStatus.authenticated;
          _errorMessage = null;
        } catch (e) {
          _errorMessage = e.toString();
          _status = AuthStatus.error;
        }
        notifyListeners();
      }
    });
  }

  Future<bool> login(String email, String password) async {
    _setLoading();
    try {
      final user = await _authService.signIn(
        email: email,
        password: password,
      );
      if (user != null) {
        _user = user;
        _status = AuthStatus.authenticated;
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _setError('Login failed');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    _setLoading();
    try {
      final user = await _authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );
      if (user != null) {
        _user = user;
        _status = AuthStatus.authenticated;
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _setError('Registration failed');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    _setLoading();
    try {
      await _authService.signOut();
    } catch (e) {
      _setError(e.toString());
    }
  }

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
