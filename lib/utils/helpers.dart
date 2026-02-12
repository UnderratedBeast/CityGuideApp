// lib/utils/helper.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../config/app_config.dart';
import 'strings.dart';

class Helper {
  // ---------- SNACKBAR ----------
  static void showSnackBar(BuildContext context, String message,
      {Color? color, Duration? duration}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color ?? Colors.black87,
        duration: duration ?? const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    showSnackBar(context, message, color: Colors.green.shade700);
  }

  static void showErrorSnackBar(BuildContext context, String message) {
    showSnackBar(context, message, color: Colors.red.shade700);
  }

  // ---------- DIALOG ----------
  static Future<void> showAlertDialog({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    VoidCallback? onConfirm,
    bool isDestructive = false,
  }) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm?.call();
            },
            style: TextButton.styleFrom(
              foregroundColor: isDestructive ? Colors.red : null,
            ),
            child: Text(confirmText ?? AppStrings.confirm),
          ),
        ],
      ),
    );
  }

  static Future<void> showLogoutDialog(BuildContext context, VoidCallback onConfirm) {
    return showAlertDialog(
      context: context,
      title: AppStrings.logout,
      message: AppStrings.logoutConfirmation,
      confirmText: AppStrings.logout,
      onConfirm: onConfirm,
    );
  }

  static Future<void> showDeleteAccountDialog(BuildContext context, VoidCallback onConfirm) {
    return showAlertDialog(
      context: context,
      title: AppStrings.deleteAccount,
      message: AppStrings.deleteAccountConfirmation,
      confirmText: AppStrings.delete,
      isDestructive: true,
      onConfirm: onConfirm,
    );
  }

  // ---------- LOADING INDICATOR ----------
  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(message ?? AppStrings.loading),
            ],
          ),
        ),
      ),
    );
  }

  static void hideLoadingDialog(BuildContext context) {
    Navigator.pop(context);
  }

  // ---------- SHARED PREFERENCES HELPERS ----------
  static Future<SharedPreferences> getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  static Future<void> saveString(String key, String value) async {
    final prefs = await getPrefs();
    await prefs.setString(key, value);
  }

  static Future<String?> getString(String key) async {
    final prefs = await getPrefs();
    return prefs.getString(key);
  }

  static Future<void> saveBool(String key, bool value) async {
    final prefs = await getPrefs();
    await prefs.setBool(key, value);
  }

  static Future<bool?> getBool(String key) async {
    final prefs = await getPrefs();
    return prefs.getBool(key);
  }

  static Future<void> removeKey(String key) async {
    final prefs = await getPrefs();
    await prefs.remove(key);
  }

  static Future<void> clearAllPrefs() async {
    final prefs = await getPrefs();
    await prefs.clear();
  }

  // ---------- NOTIFICATION PREFERENCES ----------
  static Future<void> setNotificationEnabled(bool value) async {
    await saveBool(AppConfig.notificationPrefKey, value);
  }

  static Future<bool> isNotificationEnabled() async {
    return await getBool(AppConfig.notificationPrefKey) ?? true;
  }

  // ---------- USER SESSION HELPERS ----------
  static Future<void> saveUserId(String userId) async {
    await saveString(AppConfig.userIdKey, userId);
  }

  static Future<String?> getUserId() async {
    return await getString(AppConfig.userIdKey);
  }

  static Future<void> saveUserEmail(String email) async {
    await saveString(AppConfig.userEmailKey, email);
  }

  static Future<String?> getUserEmail() async {
    return await getString(AppConfig.userEmailKey);
  }

  static Future<void> clearUserSession() async {
    await removeKey(AppConfig.userIdKey);
    await removeKey(AppConfig.userEmailKey);
    await setNotificationEnabled(true); // Reset to default
  }

  // ---------- FIREBASE AUTH ERROR HANDLER ----------
  static String getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return AppStrings.authErrorEmailAlreadyInUse;
      case 'invalid-email':
        return AppStrings.authErrorInvalidEmail;
      case 'weak-password':
        return AppStrings.authErrorWeakPassword;
      case 'user-not-found':
        return AppStrings.authErrorUserNotFound;
      case 'wrong-password':
        return AppStrings.authErrorWrongPassword;
      case 'too-many-requests':
        return AppStrings.authErrorTooManyRequests;
      case 'network-request-failed':
        return AppStrings.authErrorNetwork;
      default:
        return e.message ?? AppStrings.authErrorGeneric;
    }
  }

  // ---------- IMAGE PICKER ----------
  static Future<File?> pickImage({ImageSource source = ImageSource.gallery}) async {
    final picker = ImagePicker();
    try {
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
    } catch (e) {
      debugPrint('Image picker error: $e');
    }
    return null;
  }

  static Future<File?> pickImageFromGallery() => pickImage(source: ImageSource.gallery);
  static Future<File?> pickImageFromCamera() => pickImage(source: ImageSource.camera);

  // ---------- CONNECTIVITY ----------
  static Future<bool> isConnected() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  static Stream<List<ConnectivityResult>> get connectivityStream =>
      Connectivity().onConnectivityChanged;

  // ---------- DATE FORMATTING ----------
  static String formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year(s) ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month(s) ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day(s) ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour(s) ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute(s) ago';
    } else {
      return 'Just now';
    }
  }

  static String formatDate(DateTime dateTime, {String pattern = 'dd/MM/yyyy'}) {
    // Simple formatting, you can use intl package for more options
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;
    return '$day/$month/$year';
  }

  // ---------- EMAIL HIDE (for privacy) ----------
  static String maskEmail(String email) {
    if (email.isEmpty) return '';
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final local = parts[0];
    final domain = parts[1];
    if (local.length <= 2) return '***@$domain';
    final maskedLocal = '${local[0]}${'*' * (local.length - 2)}${local[local.length - 1]}';
    return '$maskedLocal@$domain';
  }

  // ---------- NAVIGATION ----------
  static void pushReplacement(BuildContext context, Widget screen) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  static void push(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  static void pushAndRemoveUntil(BuildContext context, Widget screen) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => screen),
      (route) => false,
    );
  }

  static void pop(BuildContext context, [dynamic result]) {
    Navigator.pop(context, result);
  }
}