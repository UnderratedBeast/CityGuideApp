import 'dart:ui';
import 'package:city_guide_app/screens/favorites/FavoritesScreen.dart';
import 'package:city_guide_app/screens/map/AllPlacesMapScreen.dart';
import 'package:city_guide_app/screens/profile/profile_screen.dart';
import 'package:city_guide_app/widgets/admin_floating_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'admin_dashboard.dart';
import 'admin_listing_list_screen.dart';
import 'admin_reviews_screen.dart';
import 'admin_settings_screen.dart';
import 'admin_notification_screen.dart';
import '../../utils/theme.dart';
import '../../providers/auth_provider.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}


class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  String _selectedCollection = 'attractions';
  String? _selectedCityId;

  final List<String> collections = [
    'attractions',
    'hotels',
    'dining',
    'events'
  ];

  static const Color primaryBlue = Color(0xFF1565C0);
static const Color lightBlue = Color(0xFFE3F2FD);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'CityGuide Admin',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
 IconButton(
  icon: const Icon(Icons.notifications_outlined),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AdminNotificationsScreen(),
      ),
    );
  },
),
  const SizedBox(width: 8),

  InkWell(
    onTap: () => _showAdminProfile(context),
    borderRadius: BorderRadius.circular(20),
    child: CircleAvatar(
      backgroundColor: Colors.blue,
      child: Text(
        context.read<AuthProvider>().user?.fullName.isNotEmpty == true
            ? context
                .read<AuthProvider>()
                .user!
                .fullName[0]
                .toUpperCase()
            : 'A',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ),

  const SizedBox(width: 16),
],
      ),
      body: _buildBody(),
      bottomNavigationBar: AdminFloatingBottomNavBar(
        currentIndex: -1,
        onTap: (index) {
          // setState(() {
          //   _selectedNavIndex = index;
          // });
          if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          }
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminReviewsScreen()),
            );
          }
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AllPlacesMapScreen()),
            );
          }
          if (index == 0) {
            // Already on home, maybe do nothing or scroll to top
          }
        },
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return const DashboardHome();

      case 1:
        // LISTINGS TAB
        if (_selectedCityId == null) {
          // Step 1: Show all cities
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('cities')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(
                      color: Colors.blue),
                );
              }

              final cities = snapshot.data!.docs;
              if (cities.isEmpty) {
                return const Center(child: Text('No cities found'));
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: cities.length,
                itemBuilder: (context, index) {
                  final city = cities[index];
                  final cityData =
                      city.data() as Map<String, dynamic>;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedCityId = city.id;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: primaryBlue.withOpacity(0.08),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                             color: primaryBlue.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.location_city,
                              color: primaryBlue,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            cityData['name'] ?? 'Unnamed City',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ID: ${city.id}',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        }

        // Step 2: Show selected city's listings with collection dropdown
        return Column(
          children: [
            // AppBar-like back button for the listings view
            Container(
  padding: const EdgeInsets.symmetric(
      horizontal: 16, vertical: 12),
  child: Row(
    children: [
      IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          setState(() {
            _selectedCityId = null;
          });
        },
      ),

      const SizedBox(width: 8),

      Expanded(
        child: Text(
          'Admin Listings - $_selectedCityId',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  ),
),
        
            // Listings
            Expanded(
              child: AdminListingTabbedScreen(
                cityId: _selectedCityId!,
              ),
            ),
          ],
        );

      case 2:
        return const AdminReviewsScreen();

      case 3:
        return const SettingsScreen();

      default:
        return const DashboardHome();
    }
  }

  void _showAdminProfile(BuildContext context) {
  final authProvider = context.read<AuthProvider>();
  final user = authProvider.user;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ClipRRect(
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(30)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor:
                        Colors.blue.withOpacity(0.1),
                    child: Text(
                      user?.fullName.isNotEmpty == true
                          ? user!.fullName[0]
                              .toUpperCase()
                          : 'A',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.fullName ?? 'Admin User',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user?.email ?? '',
                    style: TextStyle(
                        color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  ListTile(
                    leading: const Icon(
                        Icons.settings_outlined),
                    title:
                        const Text('Account Settings'),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() =>
                          _selectedIndex = 3);
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.logout,
                      color: Colors.red,
                    ),
                    title: const Text(
                      'Sign Out',
                      style:
                          TextStyle(color: Colors.red),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      await context
                          .read<AuthProvider>()
                          .logout();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}




// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:provider/provider.dart';
// import 'admin_dashboard.dart';
// import 'admin_listing_list_screen.dart';
// import 'admin_reviews_screen.dart';
// import 'admin_settings_screen.dart';
// import 'admin_notification_screen.dart';
// import '../../providers/auth_provider.dart';

// class DashboardScreen extends StatefulWidget {
//   const DashboardScreen({super.key});

//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen> {
//   int _selectedIndex = 0;
//   String? _selectedCityId;

//   // ================= GLASS CARD =================

//   Widget _glassCard({required Widget child}) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(20),
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
//         child: Container(
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.75),
//             borderRadius: BorderRadius.circular(20),
//             border: Border.all(
//               color: Colors.blue.withOpacity(0.08),
//             ),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.blue.withOpacity(0.06),
//                 blurRadius: 20,
//                 offset: const Offset(0, 8),
//               )
//             ],
//           ),
//           child: child,
//         ),
//       ),
//     );
//   }

//   // ================= BUILD =================

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         title: const Text(
//           'CityGuide Admin',
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             color: Colors.black87,
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.notifications_outlined,
//                 color: Colors.black87),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) =>
//                       const AdminNotificationsScreen(),
//                 ),
//               );
//             },
//           ),
//           const SizedBox(width: 8),
//           InkWell(
//             onTap: () => _showAdminProfile(context),
//             borderRadius: BorderRadius.circular(20),
//             child: CircleAvatar(
//               backgroundColor: Colors.blue,
//               child: Text(
//                 context.read<AuthProvider>().user?.fullName
//                             .isNotEmpty ==
//                         true
//                     ? context
//                         .read<AuthProvider>()
//                         .user!
//                         .fullName[0]
//                         .toUpperCase()
//                     : 'A',
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 16),
//         ],
//       ),
//       body: _buildBody(),
//       bottomNavigationBar: NavigationBar(
//         selectedIndex: _selectedIndex,
//         onDestinationSelected: (int index) {
//           setState(() => _selectedIndex = index);
//         },
//         backgroundColor: Colors.white,
//         indicatorColor: Colors.blue.withOpacity(0.12),
//         labelBehavior:
//             NavigationDestinationLabelBehavior.alwaysShow,
//         destinations: const [
//           NavigationDestination(
//             icon: Icon(Icons.dashboard_outlined),
//             selectedIcon:
//                 Icon(Icons.dashboard, color: Colors.blue),
//             label: 'Home',
//           ),
//           NavigationDestination(
//             icon: Icon(Icons.place_outlined),
//             selectedIcon:
//                 Icon(Icons.place, color: Colors.blue),
//             label: 'Listings',
//           ),
//           NavigationDestination(
//             icon: Icon(Icons.reviews_outlined),
//             selectedIcon:
//                 Icon(Icons.reviews, color: Colors.blue),
//             label: 'Reviews',
//           ),
//           NavigationDestination(
//             icon: Icon(Icons.settings_outlined),
//             selectedIcon:
//                 Icon(Icons.settings, color: Colors.blue),
//             label: 'Settings',
//           ),
//         ],
//       ),
//     );
//   }

//   // ================= BODY =================

//   Widget _buildBody() {
//     switch (_selectedIndex) {
//       case 0:
//         return const DashboardHome();

//       case 1:
//         if (_selectedCityId == null) {
//           return StreamBuilder<QuerySnapshot>(
//             stream: FirebaseFirestore.instance
//                 .collection('cities')
//                 .snapshots(),
//             builder: (context, snapshot) {
//               if (!snapshot.hasData) {
//                 return const Center(
//                   child: CircularProgressIndicator(
//                       color: Colors.blue),
//                 );
//               }

//               final cities = snapshot.data!.docs;

//               return GridView.builder(
//                 padding: const EdgeInsets.all(20),
//                 gridDelegate:
//                     const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   crossAxisSpacing: 16,
//                   mainAxisSpacing: 16,
//                   childAspectRatio: 0.9,
//                 ),
//                 itemCount: cities.length,
//                 itemBuilder: (context, index) {
//                   final city = cities[index];
//                   final cityData =
//                       city.data() as Map<String, dynamic>;

//                   return InkWell(
//                     onTap: () {
//                       setState(() {
//                         _selectedCityId = city.id;
//                       });
//                     },
//                     child: _glassCard(
//                       child: Column(
//                         mainAxisAlignment:
//                             MainAxisAlignment.center,
//                         children: [
//                           Container(
//                             padding:
//                                 const EdgeInsets.all(18),
//                             decoration: BoxDecoration(
//                               color: Colors.blue
//                                   .withOpacity(0.1),
//                               shape: BoxShape.circle,
//                             ),
//                             child: const Icon(
//                               Icons.location_city,
//                               color: Colors.blue,
//                               size: 32,
//                             ),
//                           ),
//                           const SizedBox(height: 16),
//                           Text(
//                             cityData['name'] ??
//                                 'Unnamed City',
//                             style: const TextStyle(
//                               fontWeight:
//                                   FontWeight.bold,
//                               fontSize: 16,
//                               color: Colors.black87,
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               );
//             },
//           );
//         }

//         return AdminListingTabbedScreen(
//           cityId: _selectedCityId!,
//         );

//       case 2:
//         return const AdminReviewsScreen();

//       case 3:
//         return const SettingsScreen();

//       default:
//         return const DashboardHome();
//     }
//   }

//   // ================= PROFILE SHEET =================

//   void _showAdminProfile(BuildContext context) {
//     final user = context.read<AuthProvider>().user;

//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) {
//         return ClipRRect(
//           borderRadius:
//               const BorderRadius.vertical(top: Radius.circular(30)),
//           child: BackdropFilter(
//             filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
//             child: Container(
//               padding: const EdgeInsets.all(24),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.85),
//                 borderRadius: const BorderRadius.vertical(
//                     top: Radius.circular(30)),
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   CircleAvatar(
//                     radius: 40,
//                     backgroundColor:
//                         Colors.blue.withOpacity(0.1),
//                     child: Text(
//                       user?.fullName.isNotEmpty == true
//                           ? user!.fullName[0]
//                               .toUpperCase()
//                           : 'A',
//                       style: const TextStyle(
//                         fontSize: 28,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.blue,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     user?.fullName ?? 'Admin User',
//                     style: const TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   Text(
//                     user?.email ?? '',
//                     style: TextStyle(
//                         color: Colors.grey[600]),
//                   ),
//                   const SizedBox(height: 24),
//                   ListTile(
//                     leading: const Icon(
//                         Icons.settings_outlined),
//                     title:
//                         const Text('Account Settings'),
//                     onTap: () {
//                       Navigator.pop(context);
//                       setState(() =>
//                           _selectedIndex = 3);
//                     },
//                   ),
//                   ListTile(
//                     leading: const Icon(
//                       Icons.logout,
//                       color: Colors.red,
//                     ),
//                     title: const Text(
//                       'Sign Out',
//                       style:
//                           TextStyle(color: Colors.red),
//                     ),
//                     onTap: () async {
//                       Navigator.pop(context);
//                       await context
//                           .read<AuthProvider>()
//                           .logout();
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }