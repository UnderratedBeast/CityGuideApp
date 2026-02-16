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

  // ---------- ADMINS ----------
  static const String adminHome = '/admin-home';
  static const String adminAttractions = '/admin-attractions';
  static const String adminAddAttraction = '/admin-add-attraction';
  static const String adminReviews = '/admin-reviews';
  static const String adminSettings = '/admin-settings';
  

  // ---------- PROFILE ----------
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String preferences = '/preferences';
  static const String accountManagement = '/account-management';
  static const String privacySecurity = '/privacy-security';

  // ---------- FAVORITES ----------
  static const String favorites = '/favorites';

  // ---------- HOME ----------
  static const String home = '/cities'; 
  static const String cityDetail = '/city-detail';

  // ---------- ATTRACTION ----------
  static const String attractionList = '/attractions';
  static const String attractionDetail = '/attraction-detail';
}