import 'dart:ui';
import 'package:city_guide_app/screens/admin/admin_listing_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

// CORRECT IMPORTS
import 'admin_dashboard.dart';
// import 'admin_listing_tabbed_screen.dart'; 
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
  String? _selectedCityId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBody: true,
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
              backgroundColor: AppTheme.primaryBlue,
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
      // bottomNavigationBar: NavigationBar(
      //   selectedIndex: _selectedIndex,
      //   onDestinationSelected: (int index) {
      //     setState(() {
      //       _selectedIndex = index;
      //     });
      //   },
      //   backgroundColor: Colors.white,
      //   indicatorColor: const Color.fromARGB(255, 46, 91, 228).withAlpha(25),
      //   destinations: const [
      //     NavigationDestination(
      //       icon: Icon(Icons.dashboard_outlined),
      //       selectedIcon: Icon(Icons.dashboard),
      //       label: 'Home',
      //     ),
      //     NavigationDestination(
      //       icon: Icon(Icons.place_outlined),
      //       selectedIcon: Icon(Icons.place),
      //       label: 'Listings',
      //     ),
      //     NavigationDestination(
      //       icon: Icon(Icons.reviews_outlined),
      //       selectedIcon: Icon(Icons.reviews),
      //       label: 'Reviews',
      //     ),
      //     NavigationDestination(
      //       icon: Icon(Icons.settings_outlined),
      //       selectedIcon: Icon(Icons.settings),
      //       label: 'Settings',
      //     ),
      //   ],
      // ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            // filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
  height: 76,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(40),

    // Glass color
    color: Colors.white.withOpacity(0.12),

    // subtle glass gradient highlight
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withOpacity(0.25),
        Colors.white.withOpacity(0.05),
      ],
    ),

    border: Border.all(
      color: Colors.white.withOpacity(0.25),
      width: 1,
    ),

    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.12),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
    ],
  ),
              child: Row(
                children: List.generate(4, (index) {
                  final isSelected = index == _selectedIndex;

                  final icons = [
                    Icons.dashboard_outlined,
                    Icons.place_outlined,
                    Icons.reviews_outlined,
                    Icons.settings_outlined,
                  ];

                  final activeIcons = [
                    Icons.dashboard,
                    Icons.place,
                    Icons.reviews,
                    Icons.settings,
                  ];

                  final labels = [
                    "Home",
                    "Listings",
                    "Reviews",
                    "Settings",
                  ];

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOutCubic,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 6),
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primaryBlue.withValues(alpha: 0.18)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedScale(
                              duration: const Duration(milliseconds: 250),
                              scale: isSelected ? 1.15 : 1,
                              child: Icon(
                                isSelected ? activeIcons[index] : icons[index],
                                size: 24,
                                // size: 26,
                                color: isSelected
                                    ? AppTheme.primaryBlue
                                    : Colors.blueGrey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 250),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: isSelected
                                    ? AppTheme.primaryBlue
                                    : Colors.blueGrey,
                              ),
                              child: Text(labels[index]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget _buildBody() {
  //   switch (_selectedIndex) {
  //     case 0:
  //       return const DashboardHome();

  //     case 1:
  //       // Listings tab with collection switcher
  //       return Column(
  //         children: [
  //           Padding(
  //             padding: const EdgeInsets.all(12),
  //             child: DropdownButton<String>(
  //               value: _selectedCollection,
  //               items: collections
  //                   .map((e) => DropdownMenuItem(
  //                         value: e,
  //                         child: Text(e[0].toUpperCase() + e.substring(1)),
  //                       ))
  //                   .toList(),
  //               onChanged: (value) {
  //                 if (value != null) {
  //                   setState(() {
  //                     _selectedCollection = value;
  //                   });
  //                 }
  //               },
  //             ),
  //           ),
  //           Expanded(
  //             child: AdminListingListScreen(
  //               cityId: _selectedCityId!,
  //               collectionName: _selectedCollection),
  //           ),
  //         ],
  //       );

  //     case 2:
  //       return const ReviewListScreen();

  //     case 3:
  //       return const SettingsScreen();

  //     default:
  //       return const DashboardHome();
  //   }
  // }
  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return const DashboardHome();

      case 1:
        // LISTINGS TAB
        if (_selectedCityId == null) {
          // Step 1: Show all cities
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('cities').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text('Something went wrong'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final cities = snapshot.data!.docs;
              if (cities.isEmpty) {
                return const Center(child: Text('No cities found'));
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: cities.length,
                itemBuilder: (context, index) {
                  final city = cities[index];
                  final cityData = city.data() as Map<String, dynamic>;
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
                            color: AppTheme.primaryBlue.withValues(alpha: 0.25),
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
                              color:
                                  AppTheme.primaryBlue.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.location_city,
                              color: AppTheme.primaryBlue,
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

        // Step 2: Show selected city's listings with tabs
        return Column(
          children: [
            // Header with back button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

  String _getCityNameFromId(String cityId) {
    // You can fetch this from Firestore if needed
    return cityId;
  }

  void _showAdminProfile(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /// Avatar
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          // color: Colors.blue.withValues(0.1),
                          color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            user?.fullName.isNotEmpty == true
                                ? user!.fullName[0].toUpperCase()
                                : 'A',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              // color: Colors.blue,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// Name
                      Text(
                        user?.fullName ?? 'Admin User',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      /// Email
                      Text(
                        user?.email ?? 'admin@cityguide.com',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 12),

                      /// Role Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'ADMINISTRATOR',
                          style: TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                      const Divider(),
                      const SizedBox(height: 10),

                      /// Account Settings
                      ListTile(
                        leading: const Icon(Icons.settings_outlined),
                        title: const Text('Account Settings'),
                        onTap: () {
                          Navigator.pop(context);
                          setState(() => _selectedIndex = 3);
                        },
                      ),

                      /// Sign Out
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.red),
                        title: const Text(
                          'Sign Out',
                          style: TextStyle(color: Colors.red),
                        ),
                        onTap: () async {
                          Navigator.pop(context);

                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Sign Out'),
                              content: const Text(
                                'Are you sure you want to log out?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text(
                                    'Sign Out',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await authProvider.logout();
                          }
                        },
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
