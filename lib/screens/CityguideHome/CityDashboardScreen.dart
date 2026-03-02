import 'package:city_guide_app/screens/CityguideHome/CityListScreen.dart';
import 'package:city_guide_app/screens/CityguideHome/SearchScreen.dart';
import 'package:city_guide_app/screens/profile/profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models//auth_models.dart';
import 'dart:math';
import '../../utils/theme.dart';
import '../../screens/attraction/AttractionListScreen.dart';
import '../../screens/notificationS/notification_Screen.dart';
import '../../screens/attraction/AttractionDetailScreen.dart';
import '../../widgets/floating_bottom_nav_bar.dart';

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
  UserModel? _currentUser;
  bool _isUserLoading = true;

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

  Future<void> _loadCurrentUser() async {
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;

      if (firebaseUser == null) {
        setState(() => _isUserLoading = false);
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (doc.exists) {
        setState(() {
          _currentUser = UserModel.fromDocument(doc);
          _isUserLoading = false;
        });
      } else {
        setState(() => _isUserLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
      setState(() => _isUserLoading = false);
    }
  }

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

  // ===== Extract latitude & longitude from either top-level or nested location =====
  (double?, double?) _extractLatLng(Map<String, dynamic> data) {
    // Check for top-level fields
    if (data.containsKey('latitude') && data.containsKey('longitude')) {
      return (data['latitude']?.toDouble(), data['longitude']?.toDouble());
    }
    // Check for nested location map
    if (data.containsKey('location') && data['location'] is Map) {
      final loc = data['location'] as Map;
      if (loc.containsKey('latitude') && loc.containsKey('longitude')) {
        return (loc['latitude']?.toDouble(), loc['longitude']?.toDouble());
      }
    }
    return (null, null);
  }

  // Helper to get listing type from item type
  String _getListingTypeFromItemType(String type) {
    switch (type) {
      case 'attraction':
        return 'attractions';
      case 'restaurant':
        return 'dining';
      case 'hotel':
        return 'hotels';
      case 'event':
        return 'events';
      default:
        return 'attractions';
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final cityQuery = await FirebaseFirestore.instance
          .collection('cities')
          .where('name', isEqualTo: widget.cityName)
          .limit(1)
          .get();

      if (cityQuery.docs.isEmpty) {
        throw Exception('City "${widget.cityName}" not found');
      }
      _cityId = cityQuery.docs.first.id;

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

      final random = Random();
      List<PopularListing> popular = [];
      if (attractions.isNotEmpty) popular.addAll(_getRandomItems(attractions, min(2, attractions.length), random));
      if (dining.isNotEmpty) popular.addAll(_getRandomItems(dining, min(2, dining.length), random));
      if (hotels.isNotEmpty) popular.addAll(_getRandomItems(hotels, min(2, hotels.length), random));
      if (events.isNotEmpty) popular.addAll(_getRandomItems(events, min(2, events.length), random));
      popular.shuffle(random);

      final featured = _getRandomItems(attractions, min(3, attractions.length), random);

      final eventDocs = await FirebaseFirestore.instance
          .collection('cities')
          .doc(_cityId)
          .collection('events')
          .get();

      print('Found ${eventDocs.docs.length} total events');

      final now = DateTime.now();
      final upcoming = eventDocs.docs
          .map((doc) {
            final data = doc.data();
            DateTime? eventDate;
            final dateStr = _safeString(data['eventDate']);
            if (dateStr.isNotEmpty) {
              try {
                eventDate = DateTime.parse(dateStr);
              } catch (e) {
                print('Error parsing date $dateStr: $e');
              }
            }
            return Event(
              id: doc.id,
              title: _safeString(data['name'], defaultValue: 'Untitled Event'),
              date: eventDate ?? DateTime.now(),
              time: _safeString(data['eventStartTime']),
              imageUrl: _safeString(data['imageUrl']),
              location: _safeString(data['address']),
            );
          })
          .where((event) => event.date.isAfter(now))
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));

      print('Upcoming events after filtering: ${upcoming.length}');

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
      DateTime? eventDate;
      final dateStr = _safeString(data['eventDate']);
      if (dateStr.isNotEmpty) {
        try {
          eventDate = DateTime.parse(dateStr);
        } catch (e) {
          print('Error parsing date in _fetchEvents: $e');
        }
      }
      return PopularListing(
        id: doc.id,
        title: _safeString(data['name'], defaultValue: 'Unknown Event'),
        type: 'event',
        category: 'Event',
        rating: _safeDouble(data['rating']),
        reviewCount: _safeInt(data['reviewCount']),
        distance: _parseDistance(data['address']),
        imageUrl: _safeString(data['imageUrl']),
        eventDate: eventDate,
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

  // ===== UPDATED NAVIGATION WITH CORRECT LISTING TYPE =====
  Future<void> _navigateToPopularListing(PopularListing item) async {
    if (_cityId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('City data not ready yet')),
      );
      return;
    }
    try {
      String collectionName;
      switch (item.type) {
        case 'attraction':
          collectionName = 'attractions';
          break;
        case 'restaurant':
          collectionName = 'dining';
          break;
        case 'hotel':
          collectionName = 'hotels';
          break;
        case 'event':
          collectionName = 'events';
          break;
        default:
          return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('cities')
          .doc(_cityId)
          .collection(collectionName)
          .doc(item.id)
          .get();

      if (!doc.exists) return;
      final data = doc.data() as Map<String, dynamic>;

      // Extract coordinates using the helper
      final (lat, lng) = _extractLatLng(data);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AttractionDetailScreen(
            name: _safeString(data['name'], defaultValue: item.title),
            imageUrl: _safeString(data['imageUrl'], defaultValue: item.imageUrl),
            rating: _safeDouble(data['rating'], defaultValue: item.rating),
            reviewCount: _safeInt(data['reviewCount'], defaultValue: item.reviewCount),
            priceLevel: _safeString(data['priceLevel'], defaultValue: item.category),
            description: _safeString(data['details']),
            address: _safeString(data['address'], defaultValue: item.distance),
            city: widget.cityName,
            website: _safeString(data['website']),
            latitude: lat,
            longitude: lng,
            additionalImages: data['extraImages'] != null ? List<String>.from(data['extraImages']) : null,
            listingType: collectionName, // Pass the correct collection name
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

      // Extract coordinates using the helper
      final (lat, lng) = _extractLatLng(data);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AttractionDetailScreen(
            name: _safeString(data['name'], defaultValue: event.title),
            imageUrl: _safeString(data['imageUrl'], defaultValue: event.imageUrl),
            rating: _safeDouble(data['rating']),
            reviewCount: _safeInt(data['reviewCount']),
            priceLevel: _safeString(data['priceLevel'], defaultValue: 'Event'),
            description: _safeString(data['details']),
            address: _safeString(data['address'], defaultValue: event.location ?? ''),
            city: widget.cityName,
            website: _safeString(data['website']),
            latitude: lat,
            longitude: lng,
            additionalImages: data['extraImages'] != null ? List<String>.from(data['extraImages']) : null,
            listingType: 'events', // Pass 'events' as the listing type
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
        currentIndex: -1,
        onTap: (index) {
           if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          }
          if (index == 0) {
              Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CityListScreen()),
            );
          }
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
          // SEARCH ICON instead of notification
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300, width: 1.5),
            ),
            child: IconButton(
              icon: Icon(Icons.search, color: Colors.grey.shade800),
// In CityDashboardScreen, update the search icon onPressed:
onPressed: () {
  if (_cityId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('City data still loading...')),
    );
    return;
  }
  
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => SearchScreen(
        cityName: widget.cityName,
        cityId: _cityId!,
      ),
    ),
  );
},
            ),
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
                                Text(
                                  _isUserLoading
                                      ? 'Hi...'
                                      : 'Hi, ${_currentUser?.fullName ?? 'Guest'}',
                                  style: const TextStyle(
                                    fontSize: 22,
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
                            child: Text(
                              _isUserLoading || _currentUser?.fullName.isEmpty == true
                                  ? '?'
                                  : _currentUser!.fullName[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
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
                            final icon = _categoryIcons[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: _CategoryButton(
                                label: category,
                                icon: icon,
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
                      // Popular Listings
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Popular Listings',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
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

  Widget _buildPopularListingCard(PopularListing item) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          Text(
            item.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            item.category,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
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

// Category Button with uniform style
class _CategoryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _CategoryButton({
    required this.label,
    required this.icon,
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color.fromARGB(174, 46, 91, 255), width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: AppTheme.primaryBlue),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: const Color.fromARGB(176, 0, 0, 0),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}