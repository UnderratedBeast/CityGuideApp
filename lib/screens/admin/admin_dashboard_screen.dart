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
  String _selectedCollection = 'attractions'; // default collection

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

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return const DashboardHome();

      case 1:
        // Listings tab with collection switcher
        return Column(
          children: [
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
            Expanded(
              child: AdminListingListScreen(collectionName: _selectedCollection),
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
