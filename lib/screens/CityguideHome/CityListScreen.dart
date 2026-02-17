import 'dart:ui'; // Required for ImageFilter
import 'package:flutter/material.dart';
import 'package:city_guide_app/screens/CityguideHome/CityDetailScreen.dart';
import 'package:city_guide_app/screens/profile/profile_screen.dart';
import '../../utils/theme.dart';

class CityListScreen extends StatefulWidget {
  const CityListScreen({super.key});

  @override
  State<CityListScreen> createState() => _CityListScreenState();
}

class _CityListScreenState extends State<CityListScreen> {
  final List<String> zones = [
    'All',
    'North Central',
    'North East',
    'North West',
    'South East',
    'South South',
    'South West',
  ];

  String selectedZone = 'All';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Track selected navigation index
  int _selectedNavIndex = 0;

  // Nigerian cities with their zones and image URLs
  final List<City> allCities = [
    City(name: 'Abuja', zone: 'North Central', country: 'Nigeria', imageUrl: 'https://img-s-msn-com.akamaized.net/tenant/amp/entityid/AA1OcNq3.img?w=1600&h=1066&m=4&q=67'),
    City(name: 'Lokoja', zone: 'North Central', country: 'Nigeria', imageUrl: 'https://img-s-msn-com.akamaized.net/tenant/amp/entityid/AA1OcNq3.img?w=1600&h=1066&m=4&q=67'),
    City(name: 'Minna', zone: 'North Central', country: 'Nigeria', imageUrl: 'https://img-s-msn-com.akamaized.net/tenant/amp/entityid/AA1OcNq3.img?w=1600&h=1066&m=4&q=67'),
    City(name: 'Maiduguri', zone: 'North East', country: 'Nigeria', imageUrl: 'https://img-s-msn-com.akamaized.net/tenant/amp/entityid/AA1OcNq3.img?w=1600&h=1066&m=4&q=67'),
    City(name: 'Yola', zone: 'North East', country: 'Nigeria', imageUrl: 'https://images.unsplash.com/photo-1586260828725-8c99f9b4d0e4?w=400&h=300&fit=crop'),
    City(name: 'Gombe', zone: 'North East', country: 'Nigeria', imageUrl: 'https://images.unsplash.com/photo-1586260828725-8c99f9b4d0e4?w=400&h=300&fit=crop'),
    City(name: 'Kano', zone: 'North West', country: 'Nigeria', imageUrl: 'https://images.unsplash.com/photo-1586260828725-8c99f9b4d0e4?w=400&h=300&fit=crop'),
    City(name: 'Kaduna', zone: 'North West', country: 'Nigeria', imageUrl: 'https://images.unsplash.com/photo-1586260828725-8c99f9b4d0e4?w=400&h=300&fit=crop'),
    City(name: 'Sokoto', zone: 'North West', country: 'Nigeria', imageUrl: 'https://images.unsplash.com/photo-1586260828725-8c99f9b4d0e4?w=400&h=300&fit=crop'),
    City(name: 'Enugu', zone: 'South East', country: 'Nigeria', imageUrl: 'https://images.unsplash.com/photo-1586260828725-8c99f9b4d0e4?w=400&h=300&fit=crop'),
    City(name: 'Aba', zone: 'South East', country: 'Nigeria', imageUrl: 'https://images.unsplash.com/photo-1586260828725-8c99f9b4d0e4?w=400&h=300&fit=crop'),
    City(name: 'Onitsha', zone: 'South East', country: 'Nigeria', imageUrl: 'https://images.unsplash.com/photo-1586260828725-8c99f9b4d0e4?w=400&h=300&fit=crop'),
    City(name: 'Port Harcourt', zone: 'South South', country: 'Nigeria', imageUrl: 'https://images.unsplash.com/photo-1586260828725-8c99f9b4d0e4?w=400&h=300&fit=crop'),
    City(name: 'Calabar', zone: 'South South', country: 'Nigeria', imageUrl: 'https://images.unsplash.com/photo-1586260828725-8c99f9b4d0e4?w=400&h=300&fit=crop'),
    City(name: 'Uyo', zone: 'South South', country: 'Nigeria', imageUrl: 'https://images.unsplash.com/photo-1586260828725-8c99f9b4d0e4?w=400&h=300&fit=crop'),
    City(name: 'Lagos', zone: 'South West', country: 'Nigeria', imageUrl: 'https://images.unsplash.com/photo-1586260828725-8c99f9b4d0e4?w=400&h=300&fit=crop'),
    City(name: 'Ibadan', zone: 'South West', country: 'Nigeria', imageUrl: 'https://images.unsplash.com/photo-1586260828725-8c99f9b4d0e4?w=400&h=300&fit=crop'),
    City(name: 'Abeokuta', zone: 'South West', country: 'Nigeria', imageUrl: 'https://images.unsplash.com/photo-1586260828725-8c99f9b4d0e4?w=400&h=300&fit=crop'),
  ];

  List<City> get filteredCities {
    return allCities.where((city) {
      if (selectedZone != 'All' && city.zone != selectedZone) return false;
      if (_searchQuery.isNotEmpty &&
          !city.name.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBody: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Select Your City',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Discovery your next adventure',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Where to next?',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.tune, color: Colors.grey.shade600),
                      onPressed: () {},
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ),

            // Horizontally scrollable zone filters as buttons
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: zones.length,
                itemBuilder: (context, index) {
                  final zone = zones[index];
                  final isSelected = zone == selectedZone;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: FilterButton(
                      label: zone,
                      isSelected: isSelected,
                      onTap: () => setState(() => selectedZone = zone),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Grid of cities (2 per row)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: filteredCities.length,
                  itemBuilder: (context, index) {
                    final city = filteredCities[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CityDetailScreen(
                              cityName: city.name,
                              country: city.country,
                              heroImageUrl: city.imageUrl,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(
                            image: NetworkImage(city.imageUrl),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Dark gradient overlay
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.6),
                                  ],
                                ),
                              ),
                            ),
                            // City name and country
                            Positioned(
                              bottom: 12,
                              left: 12,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    city.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    city.country,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      // Custom floating bottom navigation bar
      bottomNavigationBar: FloatingBottomNavBar(
        currentIndex: _selectedNavIndex,
        onTap: (index) {
          setState(() {
            _selectedNavIndex = index;
          });
          if (index == 3) { // Profile tab
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          }
          // Handle navigation for other tabs if needed (e.g., Home, Favorites, Bookmarks)
        },
      ),
    );
  }
}

// Custom button widget for zone filters
class FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const FilterButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade400,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

// Custom floating bottom navigation bar with frosted glass effect
class FloatingBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const FloatingBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': Icons.home, 'label': 'Home'},
      {'icon': Icons.favorite_border, 'label': 'Favorites'},
      {'icon': Icons.bookmark_border, 'label': 'Bookmarks'},
      {'icon': Icons.person_outline, 'label': 'Profile'},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35), // Pill shape
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: Colors.transparent, // Semi-transparent
              borderRadius: BorderRadius.circular(35),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: List.generate(items.length, (index) {
                final isSelected = index == currentIndex;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onTap(index),
                    child: Container(
                     
                      margin: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            items[index]['icon'] as IconData,
                            color: isSelected
                                ? AppTheme.primaryBlue
                                : Colors.white,
                            size: 26,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            items[index]['label'] as String,
                            style: TextStyle(
                              color: isSelected
                                  ? AppTheme.primaryBlue
                                  : Colors.white,
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
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
    );
  }
}

class City {
  final String name;
  final String zone;
  final String country;
  final String imageUrl;

  City({required this.name, required this.zone, required this.country, required this.imageUrl});
}