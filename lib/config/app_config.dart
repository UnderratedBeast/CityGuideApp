import 'package:firebase_core/firebase_core.dart';

/// App-wide configuration constants
class AppConfig {
  // ---------- FIREBASE ANDROID ----------
  static const FirebaseOptions androidFirebaseOptions = FirebaseOptions(
    apiKey: 'AIzaSyCxoYPZHi4qz8cCrwfEZBju-FDfCE6tr5Q',
    appId: '1:494443128212:android:5c26040860218228fa9b81',
    messagingSenderId: '494443128212',
    projectId: 'cityguide-2407f',
    storageBucket: 'cityguide-2407f.firebasestorage.app',
  );

  // ---------- FIREBASE iOS ----------
  // Replace with your iOS app credentials from Firebase Console
  static const FirebaseOptions iosFirebaseOptions = FirebaseOptions(
    apiKey: 'AIzaSy...', // Your iOS API key
    appId: '1:494443128212:ios:xxxxxxxxxxxxxxxx', // Your iOS app ID
    messagingSenderId: '494443128212',
    projectId: 'cityguide-2407f',
    storageBucket: 'cityguide-2407f.firebasestorage.app',
    iosClientId: 'xxxxxxxxxxxxxxxx-xxxxxxxxxxxxxxxx.apps.googleusercontent.com', // Optional but recommended for Google Sign-In
    iosBundleId: 'com.example.cityGuideApp', // Your iOS bundle ID
  );

  

  // ---------- FIRESTORE COLLECTIONS ----------
  static const String usersCollection = 'users';
  static const String favoritesCollection = 'favorites';
  static const String attractionsCollection = 'attractions';
  static const String reviewsCollection = 'reviews';

  // ---------- SHARED PREFERENCES KEYS ----------
  static const String notificationPrefKey = 'notifications_enabled';
  static const String userIdKey = 'user_id';
  static const String userEmailKey = 'user_email';

  // ---------- VALIDATION ----------
  static final RegExp emailRegex = RegExp(
    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
  );
  static final RegExp passwordRegex = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*#?&]{8,}$',
  );

  // ---------- PAGINATION ----------
  static const int defaultPageSize = 20;

  // ---------- ERROR MESSAGES ----------
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError = 'No internet connection.';
  static const String authError = 'Authentication failed.';
}