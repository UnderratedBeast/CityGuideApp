// lib/utils/constants.dart

import 'package:flutter/material.dart';

/// App-wide constants not related to Firebase config or theme
class Constants {
  // ---------- ROUTE NAMES ----------
  static const String routeSplash = '/';
  static const String routeOnboarding = '/onboarding';
  static const String routeLogin = '/login';
  static const String routeSignUp = '/signup';
  static const String routeForgotPassword = '/forgot-password';
  static const String routeResetPassword = '/reset-password';
  static const String routeHome = '/home';
  static const String routeProfile = '/profile';
  static const String routeEditProfile = '/edit-profile';
  static const String routePreferences = '/preferences';
  static const String routeFavorites = '/favorites';
  static const String routeChangePassword = '/change-password';
  static const String routeAttractionDetail = '/attraction-detail';

  // ---------- SHARED PREFERENCES KEYS (additional) ----------
  static const String prefOnboardingCompleted = 'onboarding_completed';
  static const String prefThemeMode = 'theme_mode';
  static const String prefLocale = 'locale';
  static const String prefFirstLaunch = 'first_launch';

  // ---------- ANIMATION DURATIONS ----------
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  static const Duration splashDuration = Duration(seconds: 2);

  // ---------- PAGINATION ----------
  static const int paginationLimit = 20;
  static const int paginationInitialPage = 1;

  // ---------- DEBOUNCE & THROTTLE ----------
  static const Duration debounceDuration = Duration(milliseconds: 500);
  static const Duration throttleDuration = Duration(milliseconds: 1000);

  // ---------- CACHE ----------
  static const Duration cacheValidityDuration = Duration(hours: 24);
  static const int maxCacheSize = 50; // items

  // ---------- VALIDATION ----------
  static const int passwordMinLength = 8;
  static const int nameMinLength = 2;
  static const int phoneMinLength = 10;
  static const int phoneMaxLength = 15;

  // ---------- IMAGE UPLOAD ----------
  static const int imageMaxWidth = 1024;
  static const int imageMaxHeight = 1024;
  static const int imageQuality = 85;
  static const int maxProfilePictureSizeMB = 5;

  // ---------- USER ROLES ----------
  static const String roleUser = 'user';
  static const String roleAdmin = 'admin';
  static const String roleModerator = 'moderator';

  // ---------- NOTIFICATION TYPES ----------
  static const String notificationTypeGeneral = 'general';
  static const String notificationTypeFavorite = 'favorite';
  static const String notificationTypeReview = 'review';
  static const String notificationTypePromo = 'promo';

  // ---------- RATING ----------
  static const double maxRating = 5.0;
  static const int defaultRating = 0;

  // ---------- ERROR CODES ----------
  static const String errorCodeNetwork = 'network_error';
  static const String errorCodeAuth = 'auth_error';
  static const String errorCodePermission = 'permission_denied';
  static const String errorCodeNotFound = 'not_found';
  static const String errorCodeValidation = 'validation_error';
  static const String errorCodeUnknown = 'unknown_error';

  // ---------- ENUMS ----------
  // Instead of enums (can be used in switch statements), but we define constants for now
  // For theme mode
  static const String themeModeLight = 'light';
  static const String themeModeDark = 'dark';
  static const String themeModeSystem = 'system';
}

/// Enum for user roles (better type safety)
enum UserRole {
  user,
  admin,
  moderator;

  static UserRole fromString(String role) {
    switch (role) {
      case Constants.roleAdmin:
        return UserRole.admin;
      case Constants.roleModerator:
        return UserRole.moderator;
      case Constants.roleUser:
      default:
        return UserRole.user;
    }
  }

  String toJson() => name;
}

/// Enum for theme mode
enum ThemeModeType {
  light,
  dark,
  system;

  static ThemeModeType fromString(String value) {
    switch (value) {
      case Constants.themeModeLight:
        return ThemeModeType.light;
      case Constants.themeModeDark:
        return ThemeModeType.dark;
      case Constants.themeModeSystem:
      default:
        return ThemeModeType.system;
    }
  }

  String toJson() => name;

  ThemeMode toThemeMode() {
    switch (this) {
      case ThemeModeType.light:
        return ThemeMode.light;
      case ThemeModeType.dark:
        return ThemeMode.dark;
      case ThemeModeType.system:
        return ThemeMode.system;
    }
  }
}

/// Enum for notification types
enum NotificationType {
  general,
  favorite,
  review,
  promo;

  static NotificationType fromString(String type) {
    switch (type) {
      case Constants.notificationTypeFavorite:
        return NotificationType.favorite;
      case Constants.notificationTypeReview:
        return NotificationType.review;
      case Constants.notificationTypePromo:
        return NotificationType.promo;
      case Constants.notificationTypeGeneral:
      default:
        return NotificationType.general;
    }
  }

  String toJson() => name;
}