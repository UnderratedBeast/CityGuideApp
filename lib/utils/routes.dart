// lib/routes/app_routes.dart

class AppRoutes {
  // ---------- SPLASH & ONBOARDING ----------
  static const String splash = '/';
  static const String onboarding = '/onboarding';

  // ---------- AUTH ----------
  static const String login = '/login';
  static const String signUp = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String changePassword = '/change-password';

  // ---------- PROFILE ----------
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String preferences = '/preferences';

  // ---------- FAVORITES ----------
  static const String favorites = '/favorites';

  // ---------- HOME ----------
  static const String home = '/home';

  // ---------- ATTRACTION DETAIL (reference for other team members) ----------
  static const String attractionDetail = '/attraction-detail';
}