// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:provider/provider.dart';

// import 'config/app_config.dart';
// import 'utils/theme.dart';
// import 'utils/routes.dart';
// import 'screens/splash/splash_screen.dart';
// import 'screens/onboarding/onboarding_screen.dart';
// import 'screens/auth/login_screen.dart';
// import 'screens/auth/register_screen.dart';
// import 'screens/attraction/AttractionDetailScreen.dart';
// import 'screens/attraction/AttractionListScreen.dart';
// import 'screens/CityguideHome/CityDetailScreen.dart';
// import 'screens/CityguideHome/CityListScreen.dart';
// import 'providers/auth_provider.dart';

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
//       child: MaterialApp(
//         title: 'City Guide',
//         debugShowCheckedModeBanner: false,
//         theme: AppTheme.lightTheme,
//         darkTheme: AppTheme.darkTheme,
//         themeMode: ThemeMode.light,
//         initialRoute: AppRoutes.splash,
//         onGenerateRoute: (settings) {
//           switch (settings.name) {
//             case AppRoutes.splash:
//               return MaterialPageRoute(builder: (_) => const SplashScreen());
//             case AppRoutes.onboarding:
//               return MaterialPageRoute(builder: (_) => const OnboardingScreen());
//             case AppRoutes.login:
//               return MaterialPageRoute(builder: (_) => const LoginScreen());
//             case AppRoutes.signUp:
//               return MaterialPageRoute(builder: (_) => const RegisterScreen());
//             case AppRoutes.forgotPassword:
//               return MaterialPageRoute(
//                 builder: (_) => const PlaceholderScreen(screenName: 'Forgot Password'),
//               );
//             case AppRoutes.profile:
//               return MaterialPageRoute(
//                 builder: (_) => const PlaceholderScreen(screenName: 'Profile'),
//               );
//             case AppRoutes.editProfile:
//               return MaterialPageRoute(
//                 builder: (_) => const PlaceholderScreen(screenName: 'Edit Profile'),
//               );
//             case AppRoutes.preferences:
//               return MaterialPageRoute(
//                 builder: (_) => const PlaceholderScreen(screenName: 'Preferences'),
//               );
//             case AppRoutes.favorites:
//               return MaterialPageRoute(
//                 builder: (_) => const PlaceholderScreen(screenName: 'Favorites'),
//               );
//             case AppRoutes.home:
//               return MaterialPageRoute(
//                 builder: (_) => const PlaceholderScreen(screenName: 'CityListScreen'),
//               );
//             default:
//               return MaterialPageRoute(
//                 builder: (_) => const PlaceholderScreen(screenName: 'Unknown'),
//               );
//           }
//         },
//       ),
//     );
//   }
// }

// /// Temporary placeholder for screens under construction.
// /// 
// /// Provides a consistent "Coming Soon" UI with proper back navigation.
// class PlaceholderScreen extends StatelessWidget {
//   final String screenName;

//   const PlaceholderScreen({
//     super.key,
//     required this.screenName,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         // If there's something to pop, go back; otherwise, go to onboarding
//         if (Navigator.canPop(context)) {
//           Navigator.pop(context);
//         } else {
//           Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
//         }
//         return false;
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text(screenName),
//           backgroundColor: AppTheme.primaryPurple,
//           foregroundColor: AppTheme.white,
//           automaticallyImplyLeading: false, // hides the default back button
//         ),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 Icons.construction,
//                 size: 80,
//                 color: AppTheme.primaryPurple,
//               ),
//               const SizedBox(height: 24),
//               Text(
//                 '$screenName Screen',
//                 style: const TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: AppTheme.black,
//                 ),
//               ),
//               const SizedBox(height: 12),
//               const Text(
//                 'Coming Soon! 🚀',
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: AppTheme.darkGrey,
//                 ),
//               ),
//               const SizedBox(height: 32),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 48.0),
//                 child: ElevatedButton.icon(
//                   onPressed: () {
//                     // Navigate intelligently based on authentication status
//                     final authProvider = Provider.of<AuthProvider>(
//                       context,
//                       listen: false,
//                     );
//                     if (authProvider.isAuthenticated) {
//                       Navigator.pushReplacementNamed(context, AppRoutes.home);
//                     } else {
//                       Navigator.pushReplacementNamed(context, AppRoutes.login);
//                     }
//                   },
//                   icon: const Icon(Icons.arrow_back),
//                   label: const Text('Back'),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'config/app_config.dart';
import 'utils/theme.dart';
import 'utils/routes.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/CityguideHome/CityListScreen.dart';
import 'screens/CityguideHome/CityDetailScreen.dart';
import 'screens/attraction/AttractionListScreen.dart';
import 'screens/attraction/AttractionDetailScreen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'screens/profile/my_trips_screen.dart';
import 'screens/settings/privacy_security_screen.dart';
import 'screens/settings/account_management_screen.dart';
import 'providers/auth_provider.dart';

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
      child: MaterialApp(
        title: 'City Guide',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case AppRoutes.splash:
              return MaterialPageRoute(
                builder: (_) => const SplashScreen(),
              );

            case AppRoutes.onboarding:
              return MaterialPageRoute(
                builder: (_) => const OnboardingScreen(),
              );

            case AppRoutes.login:
              return MaterialPageRoute(
                builder: (_) => const LoginScreen(),
              );

            case AppRoutes.signUp:
              return MaterialPageRoute(
                builder: (_) => const RegisterScreen(),
              );

            case AppRoutes.home:
              return MaterialPageRoute(
                builder: (_) => const CityListScreen(),
              );

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

            // ---------- PROFILE ----------
            case AppRoutes.profile:
              return MaterialPageRoute(
                builder: (_) => const ProfileScreen(),
              );

            case AppRoutes.editProfile:
              return MaterialPageRoute(
                builder: (_) => const EditProfileScreen(),
              );

            case AppRoutes.preferences:
              return MaterialPageRoute(
                builder: (_) => const MyTripsScreen(),
              );

            case AppRoutes.accountManagement:
              return MaterialPageRoute(
                builder: (_) => const AccountManagementScreen(),
              );

            case AppRoutes.privacySecurity:
              return MaterialPageRoute(
                builder: (_) => const PrivacySecurityScreen(),
              );

            default:
              return MaterialPageRoute(
                builder: (_) => const Scaffold(
                  body: Center(child: Text('Unknown Route')),
                ),
              );
          }
        },
      ),
    );
  }
}



