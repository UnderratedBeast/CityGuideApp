// import 'package:flutter/material.dart';
// import 'admin_dashboard.dart';
// import 'admin_listing_list_screen.dart';
// import 'admin_review_list_screen.dart';
// import 'admin_settings_screen.dart';

// class DashboardScreen extends StatefulWidget {
//   const DashboardScreen({super.key});

//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen> {
//   int _selectedIndex = 0;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'CityGuide Admin',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.notifications_outlined),
//             onPressed: () {},
//           ),
//           const SizedBox(width: 8),
//           const CircleAvatar(
//             backgroundColor: Color(0xFF6200EE),
//             child: Text('A', style: TextStyle(color: Colors.white)),
//           ),
//           const SizedBox(width: 16),
//         ],
//       ),
//       body: _buildBody(),
//       bottomNavigationBar: NavigationBar(
//         selectedIndex: _selectedIndex,
//         onDestinationSelected: (int index) {
//           setState(() {
//             _selectedIndex = index;
//           });
//         },
//         backgroundColor: Colors.white,
//         indicatorColor: const Color(
//           0xFF6200EE,
//         ).withValues(alpha: 0.1),
//         destinations: const [
//           NavigationDestination(
//             icon: Icon(Icons.dashboard_outlined),
//             selectedIcon: Icon(Icons.dashboard),
//             label: 'Home',
//           ),
//           NavigationDestination(
//             icon: Icon(Icons.place_outlined),
//             selectedIcon: Icon(Icons.place),
//             label: 'Attractions',
//           ),
//           NavigationDestination(
//             icon: Icon(Icons.reviews_outlined),
//             selectedIcon: Icon(Icons.reviews),
//             label: 'Reviews',
//           ),
//           NavigationDestination(
//             icon: Icon(Icons.settings_outlined),
//             selectedIcon: Icon(Icons.settings),
//             label: 'Settings',
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBody() {
//     switch (_selectedIndex) {
//       case 0:
//         return const DashboardHome();
//       case 1:
//         return AdminListingListScreen(collectionName: 'attractions');
//       case 2:
//         return const ReviewListScreen();
//       case 3:
//         return const SettingsScreen();
//       default:
//         return const DashboardHome();
//     }
//   }
// }


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_dashboard.dart';
import 'admin_listing_list_screen.dart';
import 'admin_review_list_screen.dart';
import 'admin_settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  String _selectedCollection = 'attractions';
  String? _selectedCityId;

  final List<String> collections = ['attractions', 'hotels', 'dining', 'events'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CityGuide Admin',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          const CircleAvatar(
            backgroundColor: Color(0xFF6200EE),
            child: Text('A', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFF6200EE).withAlpha(25),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.place_outlined),
            selectedIcon: Icon(Icons.place),
            label: 'Listings',
          ),
          NavigationDestination(
            icon: Icon(Icons.reviews_outlined),
            selectedIcon: Icon(Icons.reviews),
            label: 'Reviews',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
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

            return ListView.builder(
              itemCount: cities.length,
              itemBuilder: (context, index) {
                final city = cities[index];
                final cityData = city.data() as Map<String, dynamic>;
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(cityData['name'] ?? 'Unnamed City'),
                    subtitle: Text('City ID: ${city.id}'),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      setState(() {
                        _selectedCityId = city.id; // Step 2: select city
                      });
                    },
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      _selectedCityId = null; // go back to cities list
                    });
                  },
                ),
                Text(
                  'Listings for City: $_selectedCityId',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Collection dropdown
          Padding(
            padding: const EdgeInsets.all(12),
            child: DropdownButton<String>(
              value: _selectedCollection,
              items: collections
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e[0].toUpperCase() + e.substring(1)),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCollection = value;
                  });
                }
              },
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
      return const ReviewListScreen();

    case 3:
      return const SettingsScreen();

    default:
      return const DashboardHome();
  }
}
}
