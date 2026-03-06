import 'package:city_guide_app/screens/favorites/FavoritesScreen.dart';
import 'package:city_guide_app/screens/map/AllPlacesMapScreen.dart';
import 'package:city_guide_app/screens/profile/profile_screen.dart';
import 'package:city_guide_app/widgets/favorite_button.dart';
import 'package:city_guide_app/widgets/floating_bottom_nav_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../../utils/theme.dart';
import 'CityDashboardScreen.dart';

class CityDetailScreen extends StatefulWidget {
  final String cityName;
  final String country;
  final String heroImageUrl;

  const CityDetailScreen({
    super.key,
    required this.cityName,
    required this.country,
    required this.heroImageUrl,
  });

  @override
  State<CityDetailScreen> createState() => _CityDetailScreenState();
}

class _CityDetailScreenState extends State<CityDetailScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  // City data from Firestore
  String _description = '';
  List<String> _highlights = [];
  List<String> _extraImages = [];
  double _rating = 0.0;
  int _reviewCount = 0;
  String _simpleWeather = 'Clear  22°C'; // for backward compatibility

  // NEW: detailed weather map
  Map<String, String> _weatherDetails = {};

  // Add this gradient for image placeholders
  final Gradient _imagePlaceholderGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE0E0E0),
      Color(0xFFF5F5F5),
      Color(0xFFE0E0E0),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  @override
  void initState() {
    super.initState();
    _fetchCityData();
  }

  Future<void> _fetchCityData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('cities')
          .where('name', isEqualTo: widget.cityName)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('City not found');
      }

      final doc = querySnapshot.docs.first;
      final data = doc.data();

      setState(() {
        _description = _parseString(data['description']) ?? 'No description available.';
        _highlights = _parseListOfStrings(data['highlights']) ?? [];
        _extraImages = _parseListOfStrings(data['extraImages']) ?? [];
        _rating = _parseDouble(data['ratings']) ?? 0.0;
        _reviewCount = _parseInt(data['reviewCount']) ?? 0;
        _simpleWeather = _parseString(data['weatherSimple']) ?? 'Clear  22°C';

        // NEW: parse detailed weather map
        final weatherMap = data['weather'];
        if (weatherMap is Map) {
          _weatherDetails = Map.fromEntries(
            weatherMap.entries.map((e) => MapEntry(
                  e.key.toString(),
                  e.value?.toString() ?? '',
                )),
          );
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load data: $e';
        _isLoading = false;
      });
    }
  }

  // ... (keep your existing parse helpers: _parseString, _parseListOfStrings, _parseDouble, _parseInt)

  String? _parseString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }

  List<String>? _parseListOfStrings(dynamic value) {
    if (value == null) return null;
    if (value is List) {
      try {
        return value.map((e) => e.toString()).toList();
      } catch (_) {
        return [];
      }
    }
    if (value is Map) {
      return value.values.map((e) => e.toString()).toList();
    }
    return [];
  }

  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $_errorMessage'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchCityData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final gallery = _extraImages.isNotEmpty
        ? _extraImages
        : [
            'https://images.pexels.com/photos/2901209/pexels-photo-2901209.jpeg',
            'https://images.pexels.com/photos/1692693/pexels-photo-1692693.jpeg',
            'https://images.pexels.com/photos/1796727/pexels-photo-1796727.jpeg',
            'https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg',
            'https://images.pexels.com/photos/1796730/pexels-photo-1796730.jpeg',
          ];

    return Scaffold(
      extendBody: true,
      backgroundColor: const Color.fromARGB(56, 24, 5, 5),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color.fromARGB(146, 0, 0, 0),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color.fromARGB(146, 0, 0, 0),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: () {},
                ),
              ),
              // In CityDetailScreen, replace the favorite IconButton with:
              Container(
                margin: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.black26,
                  shape: BoxShape.circle,
                ),
                child: FavoriteButton(
                  itemId: 'city_${widget.cityName}', // Create a unique ID
                  itemType: 'city',
                  name: widget.cityName,
                  imageUrl: widget.heroImageUrl,
                  cityName: widget.country,
                  rating: _rating,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: null,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: _imagePlaceholderGradient,
                    ),
                    child: Image.network(
                      widget.heroImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        decoration: BoxDecoration(
                          gradient: _imagePlaceholderGradient,
                        ),
                        child: const Icon(Icons.image_not_supported, color: Colors.grey),
                      ),
                      // REMOVED loadingBuilder with spinner
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color.fromARGB(66, 0, 0, 0),
                          Color.fromARGB(0, 0, 0, 0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            backgroundColor: Colors.blue.shade800,
            title: Text(widget.cityName),
            titleTextStyle: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SliverToBoxAdapter(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 0),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(1)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 16,
                          offset: const Offset(0, -16),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 36),

                        // City name
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            widget.cityName,
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Rating row
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 22),
                              const SizedBox(width: 6),
                              Text(
                                _rating.toStringAsFixed(1),
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '($_reviewCount Reviews)',
                                style: TextStyle(
                                    color: Colors.grey.shade700, fontSize: 15),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                child: const Text(
                                  'Most Visited 2024',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primaryBlue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Top Highlights
                        if (_highlights.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Top Highlights',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 40,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _highlights.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: const EdgeInsets.only(right: 12),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(30),
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Text(
                                    _highlights[index],
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // About the City
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'About the City',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            _description,
                            style: const TextStyle(
                                fontSize: 15,
                                height: 1.4,
                                color: Colors.black87),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ----- DETAILED WEATHER CARD -----
                        if (_weatherDetails.isNotEmpty)
                          WeatherDetailsCard(weather: _weatherDetails)
                        else
                          // Fallback simple weather row
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.wb_sunny,
                                      color: Colors.orange.shade700),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('WEATHER',
                                          style: TextStyle(
                                              fontSize: 12, color: Colors.grey)),
                                      Text(_simpleWeather,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(height: 24),

                        // Photo Gallery
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Photo Gallery',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: gallery.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  _showFullScreenGallery(
                                      context, gallery, index);
                                },
                                child: Container(
                                  width: 120,
                                  margin: const EdgeInsets.only(right: 12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: _imagePlaceholderGradient,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      gallery[index],
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        decoration: BoxDecoration(
                                          gradient: _imagePlaceholderGradient,
                                        ),
                                        child: const Icon(Icons.broken_image, color: Colors.grey),
                                      ),
                                      // REMOVED loadingBuilder with spinner
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Explore Button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CityDashboardScreen(
                                        cityName: widget.cityName),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: AppTheme.primaryBlue,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Transform.rotate(
                                    angle: -pi / 4,
                                    child: const Icon(
                                      Icons.send,
                                      color: Colors.white,
                                      size: 17,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Explore City',
                                    style: TextStyle(
                                        fontSize: 18, color: Color.fromRGBO(255, 255, 255, 1)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      //   bottomNavigationBar: FloatingBottomNavBar(
      //   currentIndex: -1,
      //   onTap: (index) {
        
      //     if (index == 3) {
      //       Navigator.push(
      //         context,
      //         MaterialPageRoute(builder: (_) => const ProfileScreen()),
      //       );}
      //       if (index == 2) {
      //       Navigator.push(
      //         context,
      //         MaterialPageRoute(builder: (_) => const FavoritesScreen()),
      //       );}
      //     if (index == 1) {
      //       Navigator.push(
      //         context,
      //         MaterialPageRoute(builder: (_) => const AllPlacesMapScreen()),
      //       );
      //     }
      //     if (index == 0) {
      //       // Already on home, maybe do nothing or scroll to top
      //     }
      //   },
      // ),
    
    );
  }

  void _showFullScreenGallery(
      BuildContext context, List<String> images, int initialIndex) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color.fromARGB(223, 0, 0, 0),
          insetPadding: EdgeInsets.zero,
          child: Stack(
            children: [
              PageView.builder(
                itemCount: images.length,
                controller: PageController(initialPage: initialIndex),
                itemBuilder: (context, index) {
                  return InteractiveViewer(
                    panEnabled: true,
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: _imagePlaceholderGradient,
                      ),
                      child: Image.network(
                        images[index],
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Container(
                          decoration: BoxDecoration(
                            gradient: _imagePlaceholderGradient,
                          ),
                          child: const Icon(Icons.broken_image, color: Colors.white70),
                        ),
                        // REMOVED loadingBuilder with spinner
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                top: 40,
                right: 15,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ------------------------------------------------------------
// WeatherDetailsCard – displays the structured weather info
// ------------------------------------------------------------
class WeatherDetailsCard extends StatelessWidget {
  final Map<String, String> weather;

  const WeatherDetailsCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.wb_sunny, color: Colors.orange, size: 24),
                SizedBox(width: 8),
                Text(
                  'Weather',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),

            // High / Low
            if (weather.containsKey('averageHigh') || weather.containsKey('averageLow'))
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildInfoRow(
                        icon: Icons.arrow_upward,
                        label: 'High',
                        value: weather['averageHigh'] ?? '--',
                      ),
                    ),
                    Expanded(
                      child: _buildInfoRow(
                        icon: Icons.arrow_downward,
                        label: 'Low',
                        value: weather['averageLow'] ?? '--',
                      ),
                    ),
                  ],
                ),
              ),

            // Humidity
            if (weather.containsKey('humidity'))
              _buildInfoRow(
                icon: Icons.water_drop,
                label: 'Humidity',
                value: weather['humidity']!,
              ),

            // Rainfall
            if (weather.containsKey('rainfall'))
              _buildInfoRow(
                icon: Icons.umbrella,
                label: 'Rainfall',
                value: weather['rainfall']!,
              ),

            // Season
            if (weather.containsKey('season'))
              _buildInfoRow(
                icon: Icons.calendar_today,
                label: 'Season',
                value: weather['season']!,
              ),

            // Note (special styling)
            if (weather.containsKey('note'))
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline,
                          color: Colors.blue.shade700, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          weather['note']!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue.shade900,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade700),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}