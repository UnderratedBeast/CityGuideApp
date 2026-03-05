import 'dart:ui';
import 'package:city_guide_app/screens/admin/admin_listing_list_screen.dart';
import 'package:city_guide_app/screens/favorites/FavoritesScreen.dart';
import 'package:city_guide_app/screens/map/AllPlacesMapScreen.dart';
import 'package:city_guide_app/screens/profile/profile_screen.dart';
import 'package:city_guide_app/widgets/admin_floating_bottom_nav_bar.dart';
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
          if (index == 3) {
           
               if (_selectedCityId != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsScreen(
                    // cityId: _selectedCityId!,
                  ),
                ),
              );
            } else {
              // If no city selected, just stay on current screen
              setState(() {
                _selectedIndex = 3;
              });
            }


          }
          if (index == 2) {
              if (_selectedCityId != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AdminReviewsScreen(
                    // cityId: _selectedCityId!,
                  ),
                ),
              );
            } else {
              // If no city selected, just stay on current screen
              setState(() {
                _selectedIndex = 2;
              });
            }



          }
          if (index == 1) {
            // Make sure _selectedCityId is not null before navigating
            if (_selectedCityId != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AdminListingTabbedScreen(
                    cityId: _selectedCityId!,
                  ),
                ),
              );
            } else {
              // If no city selected, just stay on current screen
              setState(() {
                _selectedIndex = 1;
              });
            }
          }
          if (index == 0) {
            setState(() {
              _selectedIndex = 0;
            });
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
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 60),
                      const SizedBox(height: 16),
                      Text('Error: ${snapshot.error}'),
                    ],
                  ),
                );
              }

              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.blue),
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

        // Step 2: Show selected city's listings with tabs
        return Column(
          children: [
            // Header with back button
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
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
                      'Listings - ${_getCityNameFromId(_selectedCityId!)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // Tabbed Listings
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
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              
              // Profile Info
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue.withOpacity(0.1),
                child: Text(
                  user?.fullName.isNotEmpty == true
                      ? user!.fullName[0].toUpperCase()
                      : 'A',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                user?.fullName ?? 'Admin User',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user?.email ?? '',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'ADMINISTRATOR',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Divider(height: 1),
              
              // PREFERENCES SECTION
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'PREFERENCES',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
              
              // Account Settings Option
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.settings_outlined, color: Colors.blue),
                ),
                title: const Text(
                  'Account Settings',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedIndex = 3;
                  });
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              
              // Sign Out Option
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.logout, color: Colors.red),
                ),
                title: const Text(
                  'Sign Out',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.red),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await context.read<AuthProvider>().logout();
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}