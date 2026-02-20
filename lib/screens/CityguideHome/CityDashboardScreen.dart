import 'package:city_guide_app/screens/CityguideHome/SearchScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../../utils/theme.dart';
import '../../screens/attraction/AttractionListScreen.dart';
import '../../screens/notificationS/notification_Screen.dart';
import '../../screens/attraction/AttractionDetailScreen.dart';
import '../../widgets/floating_bottom_nav_bar.dart';

// ---------- Data Models ----------
class PopularListing {
  final String id;
  final String title;
  final String type;
  final String category;
  final double rating;
  final int reviewCount;
  final String distance;
  final String imageUrl;
  final DateTime? eventDate;

  PopularListing({
    required this.id,
    required this.title,
    required this.type,
    required this.category,
    required this.rating,
    required this.reviewCount,
    required this.distance,
    required this.imageUrl,
    this.eventDate,
  });
}

class Event {
  final String id;
  final String title;
  final DateTime date;
  final String time;
  final String imageUrl;
  final String? location;

  Event({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.imageUrl,
    this.location,
  });
}

// ---------- Main Screen ----------
class CityDashboardScreen extends StatefulWidget {
  final String cityName;

  const CityDashboardScreen({super.key, required this.cityName});

  @override
  State<CityDashboardScreen> createState() => _CityDashboardScreenState();
}

class _CityDashboardScreenState extends State<CityDashboardScreen> {
  int _selectedCategoryIndex = 0;
  int _currentIndex = 0;
  String? _cityId;
  bool _isLoading = true;
  String? _errorMessage;

  List<PopularListing> _popularListings = [];
  List<PopularListing> _featuredAttractions = [];
  List<Event> _upcomingEvents = [];

  final List<String> _categories = [
    'Attractions',
    'Restaurants',
    'Hotels',
    'Events',
  ];

  final List<IconData> _categoryIcons = [
    Icons.attractions,
    Icons.restaurant,
    Icons.hotel,
    Icons.event,
  ];

  // ---------- Safe Parsing Helpers ----------
  String _safeString(dynamic value, {String defaultValue = ''}) {
    if (value == null) return defaultValue;
    if (value is String) return value;
    if (value is Map) {
      if (value.containsKey('text') && value['text'] is String) {
        return value['text'];
      }
      return value.toString();
    }
    return value.toString();
  }

  double _safeDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed ?? defaultValue;
    }
    return defaultValue;
  }

  int _safeInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      return parsed ?? defaultValue;
    }
    return defaultValue;
  }

  String _parseDistance(dynamic value) {
    return _safeString(value, defaultValue: '0.5 mi');
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Get cityId from city name
      final cityQuery = await FirebaseFirestore.instance
          .collection('cities')
          .where('name', isEqualTo: widget.cityName)
          .limit(1)
          .get();

      if (cityQuery.docs.isEmpty) {
        throw Exception('City "${widget.cityName}" not found');
      }
      _cityId = cityQuery.docs.first.id;

      // 2. Fetch data from subcollections in parallel
      final futures = await Future.wait([
        _fetchAttractions(),
        _fetchDining(),
        _fetchHotels(),
        _fetchEvents(),
      ]);

      final attractions = futures[0] as List<PopularListing>;
      final dining = futures[1] as List<PopularListing>;
      final hotels = futures[2] as List<PopularListing>;
      final events = futures[3] as List<PopularListing>;

      print('Fetched: attractions=${attractions.length}, dining=${dining.length}, hotels=${hotels.length}, events=${events.length}');

      // 3. Build popular listings: 2 random from each type (if available)
      final random = Random();
      List<PopularListing> popular = [];
      if (attractions.isNotEmpty) popular.addAll(_getRandomItems(attractions, min(2, attractions.length), random));
      if (dining.isNotEmpty) popular.addAll(_getRandomItems(dining, min(2, dining.length), random));
      if (hotels.isNotEmpty) popular.addAll(_getRandomItems(hotels, min(2, hotels.length), random));
      if (events.isNotEmpty) popular.addAll(_getRandomItems(events, min(2, events.length), random));
      popular.shuffle(random);

      // 4. Featured attractions: 3 random attractions (or all if less)
      final featured = _getRandomItems(attractions, min(3, attractions.length), random);

      // 5. Upcoming events: fetch from events subcollection, order by date
      final eventDocs = await FirebaseFirestore.instance
          .collection('cities')
          .doc(_cityId)
          .collection('events')
          .where('date', isGreaterThan: Timestamp.now())
          .orderBy('date')
          .limit(10)
          .get();

      print('Found ${eventDocs.docs.length} upcoming events'); // Debug print

      final upcoming = eventDocs.docs.map((doc) {
        final data = doc.data();
        return Event(
          id: doc.id,
          title: _safeString(data['title'], defaultValue: 'Untitled Event'),
          date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
          time: _safeString(data['time']),
          imageUrl: _safeString(data['imageUrl']),
          location: _safeString(data['location']),
        );
      }).toList();

      setState(() {
        _popularListings = popular;
        _featuredAttractions = featured;
        _upcomingEvents = upcoming;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading dashboard data: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // Helper to fetch attractions
  Future<List<PopularListing>> _fetchAttractions() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('cities')
        .doc(_cityId)
        .collection('attractions')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return PopularListing(
        id: doc.id,
        title: _safeString(data['name'], defaultValue: 'Unknown'),
        type: 'attraction',
        category: _safeString(data['hashtag'], defaultValue: 'Attraction'),
        rating: _safeDouble(data['rating']),
        reviewCount: _safeInt(data['reviewCount']),
        distance: _parseDistance(data['distance']),
        imageUrl: _safeString(data['imageUrl']),
      );
    }).toList();
  }

  // Fetch dining (formerly restaurants)
  Future<List<PopularListing>> _fetchDining() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('cities')
        .doc(_cityId)
        .collection('dining')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return PopularListing(
        id: doc.id,
        title: _safeString(data['name'], defaultValue: 'Unknown'),
        type: 'restaurant',
        category: _safeString(data['cuisine'] ?? data['type'], defaultValue: 'Restaurant'),
        rating: _safeDouble(data['rating']),
        reviewCount: _safeInt(data['reviewCount']),
        distance: _parseDistance(data['distance']),
        imageUrl: _safeString(data['imageUrl']),
      );
    }).toList();
  }

  Future<List<PopularListing>> _fetchHotels() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('cities')
        .doc(_cityId)
        .collection('hotels')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return PopularListing(
        id: doc.id,
        title: _safeString(data['name'], defaultValue: 'Unknown'),
        type: 'hotel',
        category: _safeString(data['type'], defaultValue: 'Hotel'),
        rating: _safeDouble(data['rating']),
        reviewCount: _safeInt(data['reviewCount']),
        distance: _parseDistance(data['distance']),
        imageUrl: _safeString(data['imageUrl']),
      );
    }).toList();
  }

  Future<List<PopularListing>> _fetchEvents() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('cities')
        .doc(_cityId)
        .collection('events')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return PopularListing(
        id: doc.id,
        title: _safeString(data['title'], defaultValue: 'Unknown Event'),
        type: 'event',
        category: 'Event',
        rating: 0,
        reviewCount: 0,
        distance: _parseDistance(data['location']),
        imageUrl: _safeString(data['imageUrl']),
        eventDate: (data['date'] as Timestamp?)?.toDate(),
      );
    }).toList();
  }

  List<T> _getRandomItems<T>(List<T> list, int count, Random random) {
    if (list.isEmpty) return [];
    if (list.length <= count) return List.from(list);
    final indices = <int>{};
    while (indices.length < count) {
      indices.add(random.nextInt(list.length));
    }
    return indices.map((i) => list[i]).toList();
  }

  int min(int a, int b) => a < b ? a : b;

  // ---------- NAVIGATION HELPERS (USING AttractionDetailScreen) ----------
  Future<void> _navigateToPopularListing(PopularListing item) async {
    if (_cityId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('City data not ready yet')),
      );
      return;
    }

    try {
      DocumentSnapshot doc;
      switch (item.type) {
        case 'attraction':
          doc = await FirebaseFirestore.instance
              .collection('cities')
              .doc(_cityId)
              .collection('attractions')
              .doc(item.id)
              .get();
          break;
        case 'restaurant':
          doc = await FirebaseFirestore.instance
              .collection('cities')
              .doc(_cityId)
              .collection('dining')
              .doc(item.id)
              .get();
          break;
        case 'hotel':
          doc = await FirebaseFirestore.instance
              .collection('cities')
              .doc(_cityId)
              .collection('hotels')
              .doc(item.id)
              .get();
          break;
        case 'event':
          doc = await FirebaseFirestore.instance
              .collection('cities')
              .doc(_cityId)
              .collection('events')
              .doc(item.id)
              .get();
          break;
        default:
          return;
      }

      if (!doc.exists) return;
      final data = doc.data() as Map<String, dynamic>;

      // Build parameters for AttractionDetailScreen
      String name = data['name'] ?? item.title;
      String imageUrl = data['imageUrl'] ?? item.imageUrl;
      double rating = (data['rating'] as num?)?.toDouble() ?? item.rating;
      int reviewCount = data['reviewCount'] as int? ?? item.reviewCount;
      String priceLevel = data['priceLevel'] ?? item.category; // fallback
      String description = data['description'] ?? '';
      String address = data['address'] ?? item.distance; // fallback
      String city = widget.cityName;
      String website = data['website'] ?? '';
      double? latitude = data['latitude']?.toDouble();
      double? longitude = data['longitude']?.toDouble();
      List<String>? additionalImages;
      if (data['additionalImages'] != null) {
        additionalImages = List<String>.from(data['additionalImages']);
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AttractionDetailScreen(
            name: name,
            imageUrl: imageUrl,
            rating: rating,
            reviewCount: reviewCount,
            priceLevel: priceLevel,
            description: description,
            address: address,
            city: city,
            website: website,
            latitude: latitude,
            longitude: longitude,
            additionalImages: additionalImages,
          ),
        ),
      );
    } catch (e) {
      print('Error navigating to detail: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading details: $e')),
      );
    }
  }

  Future<void> _navigateToEvent(Event event) async {
    if (_cityId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('City data not ready yet')),
      );
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('cities')
          .doc(_cityId)
          .collection('events')
          .doc(event.id)
          .get();

      if (!doc.exists) return;
      final data = doc.data() as Map<String, dynamic>;

      // Map event data to AttractionDetailScreen parameters
      String name = data['title'] ?? event.title;
      String imageUrl = data['imageUrl'] ?? event.imageUrl;
      double rating = (data['rating'] as num?)?.toDouble() ?? 0.0;
      int reviewCount = data['reviewCount'] as int? ?? 0;
      String priceLevel = data['priceLevel'] ?? 'Event';
      String description = data['description'] ?? '';
      String address = data['address'] ?? event.location ?? '';
      String city = widget.cityName;
      String website = data['website'] ?? '';
      double? latitude = data['latitude']?.toDouble();
      double? longitude = data['longitude']?.toDouble();
      List<String>? additionalImages;
      if (data['additionalImages'] != null) {
        additionalImages = List<String>.from(data['additionalImages']);
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AttractionDetailScreen(
            name: name,
            imageUrl: imageUrl,
            rating: rating,
            reviewCount: reviewCount,
            priceLevel: priceLevel,
            description: description,
            address: address,
            city: city,
            website: website,
            latitude: latitude,
            longitude: longitude,
            additionalImages: additionalImages,
          ),
        ),
      );
    } catch (e) {
      print('Error navigating to event detail: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading event details: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      bottomNavigationBar: FloatingBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.grey.shade800),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.cityName,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: Colors.grey.shade800),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 60),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading data',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      // Greeting
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$greeting,',
                                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                                ),
                                const Text(
                                  'Hi, Erioluwa',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: AppTheme.primaryBlue,
                            child: const Text(
                              'E',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      // Search bar – now tappable
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SearchScreen(cityName: widget.cityName),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const TextField(
                            enabled: false,
                            decoration: InputDecoration(
                              hintText: 'Discover...',
                              hintStyle: TextStyle(color: Colors.grey),
                              prefixIcon: Icon(Icons.search, color: Colors.grey),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                      // Category buttons
                      SizedBox(
                        height: 48,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _categories.length,
                          itemBuilder: (context, index) {
                            final category = _categories[index];
                            final isSelected = index == _selectedCategoryIndex;
                            final icon = _categoryIcons[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: _CategoryButton(
                                label: category,
                                icon: icon,
                                isSelected: isSelected,
                                onTap: () {
                                  setState(() {
                                    _selectedCategoryIndex = index;
                                  });
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AttractionListScreen(
                                        category: category,
                                        cityName: widget.cityName,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 24),
                      // Popular Listings – "See all" removed
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Popular Listings',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          // 👈 "See all" button removed
                        ],
                      ),

                      const SizedBox(height: 16),
                      _popularListings.isEmpty
                          ? const Center(child: Text('No popular listings'))
                          : SizedBox(
                              height: 350,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _popularListings.length,
                                itemBuilder: (context, index) {
                                  final item = _popularListings[index];
                                  return GestureDetector(
                                    onTap: () => _navigateToPopularListing(item),
                                    child: _buildPopularListingCard(item),
                                  );
                                },
                              ),
                            ),

                      const SizedBox(height: 24),
                      // Featured Attractions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Featured Attractions',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              'View Map',
                              style: TextStyle(color: AppTheme.primaryBlue),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      _featuredAttractions.isEmpty
                          ? const Center(child: Text('No featured attractions'))
                          : Column(
                              children: _featuredAttractions.map((item) => GestureDetector(
                                    onTap: () => _navigateToPopularListing(item),
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 16),
                                      child: _buildAttractionRow(item),
                                    ),
                                  )).toList(),
                            ),

                      const SizedBox(height: 24),
                      // Upcoming Events
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Upcoming Events',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              'Calendar',
                              style: TextStyle(color: AppTheme.primaryBlue),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      _upcomingEvents.isEmpty
                          ? const Center(child: Text('No upcoming events'))
                          : SizedBox(
                              height: 220,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _upcomingEvents.length,
                                itemBuilder: (context, index) {
                                  final event = _upcomingEvents[index];
                                  return GestureDetector(
                                    onTap: () => _navigateToEvent(event),
                                    child: Container(
                                      width: 280,
                                      margin: const EdgeInsets.only(right: 16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _formatEventDate(event.date),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Expanded(
                                            child: _buildEventCard(
                                              title: event.title,
                                              time: event.time,
                                              imageUrl: event.imageUrl,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
    );
  }

  String _formatEventDate(DateTime date) {
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return '${months[date.month - 1]} ${date.day}';
  }

  // Card for Popular Listings (horizontal scroll) – IMPROVED: title below image
  Widget _buildPopularListingCard(PopularListing item) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with rating overlay
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  item.imageUrl,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 250,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.broken_image),
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 2),
                      Text(
                        item.rating > 0 ? '${item.rating.toStringAsFixed(1)}' : 'N/A',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      if (item.reviewCount > 0) ...[
                        const SizedBox(width: 4),
                        Text(
                          '(${item.reviewCount})',
                          style: const TextStyle(color: Colors.white70, fontSize: 10),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Title (now outside image)
          Text(
            item.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Category
          Text(
            item.category,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          // Distance
          Row(
            children: [
              Icon(Icons.location_on, size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  item.distance,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Row for Featured Attractions (unchanged)
  Widget _buildAttractionRow(PopularListing item) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            item.imageUrl,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 80,
              height: 80,
              color: Colors.grey.shade300,
              child: const Icon(Icons.broken_image),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                item.distance,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.category,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (item.rating > 0)
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 2),
                        Text(
                          item.rating.toStringAsFixed(1),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (item.reviewCount > 0)
                          Text(
                            ' (${item.reviewCount})',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                          ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Event card (unchanged)
  Widget _buildEventCard({
    required String title,
    required String time,
    required String imageUrl,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
          onError: (_, __) => const Icon(Icons.broken_image),
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
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.white70, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Category Button Widget (unchanged)
class _CategoryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : Colors.grey.shade700,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade800,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}