// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:provider/provider.dart';

// import 'config/app_config.dart';
// import 'utils/theme.dart';
// import 'utils/routes.dart';

// import 'providers/auth_provider.dart';

// // Public Screens
// import 'screens/splash/splash_screen.dart';
// import 'screens/onboarding/onboarding_screen.dart';
// import 'screens/auth/login_screen.dart';
// import 'screens/auth/register_screen.dart';
// import 'screens/CityguideHome/CityListScreen.dart';
// import 'screens/CityguideHome/CityDetailScreen.dart';
// import 'screens/attraction/AttractionListScreen.dart';
// import 'screens/attraction/AttractionDetailScreen.dart';
// import 'screens/profile/profile_screen.dart';
// import 'screens/profile/edit_profile_screen.dart';
// import 'screens/profile/my_trips_screen.dart';
// import 'screens/profile/privacy_security_screen.dart';
// import 'screens/settings/account_management_screen.dart';

// // Admin Screens
// import 'screens/admin/admin_dashboard_screen.dart';
// import 'screens/admin/admin_listing_list_screen.dart';
// import 'screens/admin/admin_listings_form_screen.dart';
// import 'screens/admin/admin_review_list_screen.dart';
// import 'screens/admin/admin_settings_screen.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   await Firebase.initializeApp(
//     options: Platform.isIOS
//         ? AppConfig.iosFirebaseOptions
//         : AppConfig.androidFirebaseOptions,
//   );

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (_) => AuthProvider(),
//       child: Builder(
//         builder: (context) {
//           return MaterialApp(
//             title: 'City Guide',
//             debugShowCheckedModeBanner: false,
//             theme: AppTheme.lightTheme,
//             darkTheme: AppTheme.darkTheme,
//             themeMode: ThemeMode.light,
//             initialRoute: AppRoutes.splash,
//             onGenerateRoute: (settings) =>
//                 _generateRoute(settings, context),
//           );
//         },
//       ),
//     );
//   }

//   Route<dynamic> _generateRoute(
//       RouteSettings settings, BuildContext context) {
//     final authProvider =
//         Provider.of<AuthProvider>(context, listen: false);

//     switch (settings.name) {
//       // ---------------- SPLASH ----------------
//       case AppRoutes.splash:
//         return MaterialPageRoute(builder: (_) => const SplashScreen());

//       case AppRoutes.onboarding:
//         return MaterialPageRoute(
//             builder: (_) => const OnboardingScreen());

//       // ---------------- AUTH ----------------
//       case AppRoutes.login:
//         return MaterialPageRoute(builder: (_) => const LoginScreen());

//       case AppRoutes.signUp:
//         return MaterialPageRoute(builder: (_) => const RegisterScreen());

//       // ---------------- HOME ----------------
//       case AppRoutes.home:
//         return MaterialPageRoute(
//             builder: (_) => const CityListScreen());

//       case AppRoutes.cityDetail:
//         final args = settings.arguments as Map<String, dynamic>;
//         return MaterialPageRoute(
//           builder: (_) => CityDetailScreen(
//             cityName: args['cityName'],
//             country: args['country'],
//             heroImageUrl: args['heroImageUrl'],
//           ),
//         );

//       case AppRoutes.attractionList:
//         final args = settings.arguments as Map<String, dynamic>;
//         return MaterialPageRoute(
//           builder: (_) => AttractionListScreen(
//             category: args['category'],
//             cityName: args['cityName'],
//           ),
//         );

//       case AppRoutes.attractionDetail:
//         final args = settings.arguments as Map<String, dynamic>;
//         return MaterialPageRoute(
//           builder: (_) => AttractionDetailScreen(
//             name: args['name'],
//             imageUrl: args['imageUrl'],
//             additionalImages: args['additionalImages'],
//             rating: args['rating'],
//             reviewCount: args['reviewCount'],
//             priceLevel: args['priceLevel'],
//             description: args['description'],
//             address: args['address'],
//             city: args['city'],
//             website: args['website'],
//             latitude: args['latitude'],
//             longitude: args['longitude'],
//           ),
//         );

//       // ---------------- PROFILE ----------------
//       case AppRoutes.profile:
//         return MaterialPageRoute(
//             builder: (_) => const ProfileScreen());

//       case AppRoutes.editProfile:
//         return MaterialPageRoute(
//             builder: (_) => const EditProfileScreen());

//       case AppRoutes.preferences:
//         return MaterialPageRoute(
//             builder: (_) => const MyTripsScreen());

//       case AppRoutes.accountManagement:
//         return MaterialPageRoute(
//             builder: (_) => const AccountManagementScreen());

//       case AppRoutes.privacySecurity:
//         return MaterialPageRoute(
//             builder: (_) => const PrivacySecurityScreen());

//       // ---------------- ADMIN ----------------
//       case AppRoutes.adminHome:
//         return _adminGuard(authProvider, const DashboardScreen());

//       case AppRoutes.adminAttractions:
//         return _adminGuard(
//             authProvider, const AdminAttractionListScreen());

//       case AppRoutes.adminAddAttraction:
//         return _adminGuard(
//             authProvider, const AdminListingFormScreen());

//       case AppRoutes.adminReviews:
//         return _adminGuard(
//             authProvider, const ReviewListScreen());

//       case AppRoutes.adminSettings:
//         return _adminGuard(authProvider, const SettingsScreen());

//       default:
//         return MaterialPageRoute(
//           builder: (_) => const Scaffold(
//             body: Center(child: Text('Unknown Route')),
//           ),
//         );
//     }
//   }

//   MaterialPageRoute _adminGuard(
//       AuthProvider authProvider, Widget screen) {
//     if (!authProvider.isAuthenticated) {
//       return MaterialPageRoute(builder: (_) => const LoginScreen());
//     }

//     if (authProvider.user?.role != 'admin') {
//       return MaterialPageRoute(
//         builder: (_) => const Scaffold(
//           body: Center(
//             child: Text(
//               "Access Denied - Admin Only",
//               style: TextStyle(fontSize: 18),
//             ),
//           ),
//         ),
//       );
//     }

//     return MaterialPageRoute(builder: (_) => screen);
//   }
// }


import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'config/app_config.dart';
import 'utils/theme.dart';
import 'utils/routes.dart';

import 'providers/auth_provider.dart';

// Public Screens
import 'screens/splash/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/CityguideHome/CityListScreen.dart';
import 'screens/CityguideHome/CityDetailScreen.dart';
import 'screens/attraction/AttractionListScreen.dart';
import 'screens/attraction/AttractionDetailScreen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'screens/profile/my_trips_screen.dart';
import 'screens/profile/privacy_security_screen.dart';
import 'screens/settings/account_management_screen.dart';

// Admin Screens
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/admin_listing_list_screen.dart';
import 'screens/admin/admin_listings_form_screen.dart';
import 'screens/admin/admin_review_list_screen.dart';
import 'screens/admin/admin_settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: Platform.isIOS
        ? AppConfig.iosFirebaseOptions
        : AppConfig.androidFirebaseOptions,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: Builder(
        builder: (context) {
          return MaterialApp(
            title: 'City Guide',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,
            initialRoute: AppRoutes.splash,
            onGenerateRoute: (settings) =>
                _generateRoute(settings, context),
          );
        },
      ),
    );
  }

  Route<dynamic> _generateRoute(
      RouteSettings settings, BuildContext context) {
    final authProvider =
        Provider.of<AuthProvider>(context, listen: false);

    switch (settings.name) {
      // ---------------- SPLASH ----------------
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case AppRoutes.onboarding:
        return MaterialPageRoute(
            builder: (_) => const OnboardingScreen());

      // ---------------- AUTH ----------------
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case AppRoutes.signUp:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case AppRoutes.forgotPassword:
  return MaterialPageRoute(
      builder: (_) => const ForgotPasswordScreen());

      // ---------------- HOME ----------------
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const CityListScreen());

      case AppRoutes.cityDetail:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => CityDetailScreen(
            cityName: args['cityName'],
            country: args['country'],
            heroImageUrl: args['heroImageUrl'],
          ),
        );

      case AppRoutes.attractionList:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => AttractionListScreen(
            category: args['category'],
            cityName: args['cityName'],
          ),
        );

      case AppRoutes.attractionDetail:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => AttractionDetailScreen(
            name: args['name'],
            imageUrl: args['imageUrl'],
            additionalImages: args['additionalImages'],
            rating: args['rating'],
            reviewCount: args['reviewCount'],
            priceLevel: args['priceLevel'],
            description: args['description'],
            address: args['address'],
            city: args['city'],
            website: args['website'],
            latitude: args['latitude'],
            longitude: args['longitude'],
          ),
        );

      // ---------------- PROFILE ----------------
      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      case AppRoutes.editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());

      case AppRoutes.preferences:
        return MaterialPageRoute(builder: (_) => const MyTripsScreen());

      case AppRoutes.accountManagement:
        return MaterialPageRoute(
            builder: (_) => const AccountManagementScreen());

      case AppRoutes.privacySecurity:
        return MaterialPageRoute(
            builder: (_) => const PrivacySecurityScreen());

      // ---------------- ADMIN ----------------
      case AppRoutes.adminHome:
        return _adminGuard(authProvider, const DashboardScreen());

      // Admin listing lists by category
      case AppRoutes.adminAttractions:
        return _adminGuard(
          authProvider,
          AdminListingListScreen(collectionName: 'attractions'),
        );

      case AppRoutes.adminDining:
        return _adminGuard(
          authProvider,
          AdminListingListScreen(collectionName: 'dining'),
        );

      case AppRoutes.adminEvents:
        return _adminGuard(
          authProvider,
          AdminListingListScreen(collectionName: 'events'),
        );

      case AppRoutes.adminHotels:
        return _adminGuard(
          authProvider,
          AdminListingListScreen(collectionName: 'hotels'),
        );

      // Admin add/edit listing
      case AppRoutes.adminAddListing:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return _adminGuard(
          authProvider,
          AdminListingFormScreen(
            collectionName: args['collectionName'] as String,
          ),
        );

      case AppRoutes.adminEditListing:
        final args = settings.arguments as Map<String, dynamic>;
        return _adminGuard(
          authProvider,
          AdminListingFormScreen(
            collectionName: args['collectionName'] as String,
            listingId: args['listingId'] as String,
            existingData: args['existingData'] as Map<String, dynamic>?,
          ),
        );

      case AppRoutes.adminReviews:
        return _adminGuard(authProvider, const ReviewListScreen());

      case AppRoutes.adminSettings:
        return _adminGuard(authProvider, const SettingsScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Unknown Route')),
          ),
        );
    }
  }

  MaterialPageRoute _adminGuard(AuthProvider authProvider, Widget screen) {
    if (!authProvider.isAuthenticated) {
      return MaterialPageRoute(builder: (_) => const LoginScreen());
    }

    if (authProvider.user?.role != 'admin') {
      return MaterialPageRoute(
        builder: (_) => const Scaffold(
          body: Center(
            child: Text(
              "Access Denied - Admin Only",
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      );
    }

    return MaterialPageRoute(builder: (_) => screen);
  }
}
