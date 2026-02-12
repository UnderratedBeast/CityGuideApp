// lib/utils/strings.dart

class AppStrings {
  // ---------- APP ----------
  static const String appName = 'City Guide';
  static const String loading = 'Loading...';
  static const String error = 'Error';
  static const String success = 'Success';
  static const String cancel = 'Cancel';
  static const String save = 'Save';
  static const String edit = 'Edit';
  static const String delete = 'Delete';
  static const String confirm = 'Confirm';
  static const String ok = 'OK';
  static const String retry = 'Retry';
  static const String noInternet = 'No internet connection';
  static const String somethingWentWrong = 'Something went wrong. Please try again.';

  // ---------- AUTH ----------
  // Screen titles
  static const String login = 'Log In';
  static const String signUp = 'Sign Up';
  static const String forgotPassword = 'Forgot Password?';
  static const String resetPassword = 'Reset Password';
  static const String createAccount = 'Create Account';

  // Labels & hints
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String fullName = 'Full Name';
  static const String phoneNumber = 'Phone Number (optional)';
  static const String rememberMe = 'Remember me';

  // Buttons
  static const String loginButton = 'Log In';
  static const String signUpButton = 'Sign Up';
  static const String sendResetLink = 'Send Reset Link';
  static const String backToLogin = 'Back to Login';
  static const String dontHaveAccount = 'Don\'t have an account? ';
  static const String alreadyHaveAccount = 'Already have an account? ';

  // Auth feedback messages
  static const String loginSuccess = 'Logged in successfully!';
  static const String signUpSuccess = 'Account created successfully!';
  static const String passwordResetEmailSent = 'Password reset link sent to your email.';
  static const String passwordResetSuccess = 'Password reset successfully!';
  static const String logoutSuccess = 'Logged out successfully.';
  static const String accountCreated = 'Welcome! Your account has been created.';

  // Validation errors (user-facing)
  static const String emailRequired = 'Email is required';
  static const String invalidEmail = 'Please enter a valid email address';
  static const String passwordRequired = 'Password is required';
  static const String passwordMinLength = 'Password must be at least 8 characters';
  static const String passwordWeak = 'Password must contain at least one letter and one number';
  static const String confirmPasswordRequired = 'Please confirm your password';
  static const String passwordsDoNotMatch = 'Passwords do not match';
  static const String nameRequired = 'Name is required';
  static const String nameMinLength = 'Name must be at least 2 characters';
  static const String nameNoNumbers = 'Name cannot contain numbers';
  static const String invalidPhone = 'Please enter a valid phone number (10-15 digits)';
  static const String invalidUrl = 'Please enter a valid URL';

  // Auth errors (Firebase specific, but generic fallbacks)
  static const String authErrorGeneric = 'Authentication failed. Please check your credentials.';
  static const String authErrorEmailAlreadyInUse = 'This email is already registered.';
  static const String authErrorInvalidEmail = 'Invalid email address.';
  static const String authErrorWeakPassword = 'Password is too weak.';
  static const String authErrorUserNotFound = 'No user found with this email.';
  static const String authErrorWrongPassword = 'Incorrect password.';
  static const String authErrorTooManyRequests = 'Too many attempts. Please try again later.';
  static const String authErrorNetwork = 'Network error. Please check your connection.';

  // ---------- PROFILE ----------
  static const String profile = 'Profile';
  static const String editProfile = 'Edit Profile';
  static const String myProfile = 'My Profile';
  static const String accountSettings = 'Account Settings';
  static const String personalInfo = 'Personal Information';
  static const String name = 'Name';
  static const String emailAddress = 'Email Address';
  static const String phone = 'Phone';
  static const String profilePicture = 'Profile Picture';
  static const String changePhoto = 'Change Photo';
  static const String removePhoto = 'Remove Photo';
  static const String takePhoto = 'Take Photo';
  static const String chooseFromGallery = 'Choose from Gallery';
  static const String updateProfile = 'Update Profile';
  static const String profileUpdated = 'Profile updated successfully!';
  static const String logout = 'Log Out';
  static const String logoutConfirmation = 'Are you sure you want to log out?';

  // ---------- PREFERENCES ----------
  static const String preferences = 'Preferences';
  static const String notifications = 'Notifications';
  static const String pushNotifications = 'Push Notifications';
  static const String emailNotifications = 'Email Notifications';
  static const String notificationSettings = 'Notification Settings';
  static const String favoriteAttractions = 'Favorite Attractions';
  static const String myFavorites = 'My Favorites';
  static const String noFavoritesYet = 'No favorites yet.';
  static const String exploreAttractions = 'Explore Attractions';
  static const String enableNotifications = 'Enable Notifications';
  static const String notificationPermissionDenied = 'Notification permission denied.';
  static const String openSettings = 'Open Settings';

  // ---------- FAVORITES ----------
  static const String addToFavorites = 'Add to Favorites';
  static const String removeFromFavorites = 'Remove from Favorites';
  static const String addedToFavorites = 'Added to favorites!';
  static const String removedFromFavorites = 'Removed from favorites.';
  static const String favoriteError = 'Could not update favorites. Please try again.';

  // ---------- SECURITY ----------
  static const String changePassword = 'Change Password';
  static const String currentPassword = 'Current Password';
  static const String newPassword = 'New Password';
  static const String confirmNewPassword = 'Confirm New Password';
  static const String passwordChanged = 'Password changed successfully!';
  static const String deleteAccount = 'Delete Account';
  static const String deleteAccountConfirmation = 'This action is permanent. All your data will be lost. Are you sure?';
  static const String accountDeleted = 'Account deleted successfully.';
}