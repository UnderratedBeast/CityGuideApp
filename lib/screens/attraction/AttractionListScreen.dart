import 'package:city_guide_app/screens/CityguideHome/CityListScreen.dart';
import 'package:city_guide_app/screens/favorites/FavoritesScreen.dart';
import 'package:city_guide_app/screens/map/AllPlacesMapScreen.dart';
import 'package:city_guide_app/screens/profile/profile_screen.dart';
import 'package:city_guide_app/widgets/favorite_button.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:city_guide_app/screens/attraction/AttractionDetailScreen.dart';
import '../../utils/theme.dart';
import 'package:city_guide_app/widgets/floating_bottom_nav_bar.dart';
import 'package:intl/intl.dart';

class AttractionListScreen extends StatefulWidget {
  final String category;
  final String cityName;

  const AttractionListScreen({
    super.key,
    required this.category,
    required this.cityName,
  });

  @override
  State<AttractionListScreen> createState() => _AttractionListScreenState();
}

class _AttractionListScreenState extends State<AttractionListScreen> {
  // Filter state variables
  String _selectedCategoryFilter = 'All';
  String _selectedRatingFilter = 'Any Rating';
  bool _openNow = false;

  // Data and loading states
  bool _isLoading = true;
  String? _errorMessage;
  List<AttractionItem> _items = [];
  int _currentNavIndex = 0;

  // Available categories derived from the data
  List<String> _availableCategories = ['All'];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // ---------- SAFE PARSING HELPERS ----------
  String? _safeString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }

  double? _safeDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  int? _safeInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  List<String>? _safeList(dynamic value) {
    if (value == null) return null;
    if (value is List) {
      try {
        return value.map((e) => e.toString()).toList();
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  // Helper to check if a place is open now based on openHours
  bool _isOpenNow(String openHours) {
    if (openHours.isEmpty) return true; // Default to open if no hours specified

    try {
      final now = DateTime.now();
      final currentTime = DateFormat('HH:mm').format(now);
      final currentDay = DateFormat('EEEE').format(now);

      final hoursLower = openHours.toLowerCase();

      // Check if today is in the open days
      if (hoursLower.contains('mon') && currentDay == 'Monday') {
        return _parseTimeRange(hoursLower, currentTime);
      } else if (hoursLower.contains('tue') && currentDay == 'Tuesday') {
        return _parseTimeRange(hoursLower, currentTime);
      } else if (hoursLower.contains('wed') && currentDay == 'Wednesday') {
        return _parseTimeRange(hoursLower, currentTime);
      } else if (hoursLower.contains('thu') && currentDay == 'Thursday') {
        return _parseTimeRange(hoursLower, currentTime);
      } else if (hoursLower.contains('fri') && currentDay == 'Friday') {
        return _parseTimeRange(hoursLower, currentTime);
      } else if (hoursLower.contains('sat') && currentDay == 'Saturday') {
        return _parseTimeRange(hoursLower, currentTime);
      } else if (hoursLower.contains('sun') && currentDay == 'Sunday') {
        return _parseTimeRange(hoursLower, currentTime);
      }

      return true;
    } catch (e) {
      print('Error parsing open hours: $e');
      return true;
    }
  }

  bool _parseTimeRange(String hours, String currentTime) {
    final timeRegex = RegExp(r'(\d{1,2}:\d{2}\s*(?:AM|PM))\s*-\s*(\d{1,2}:\d{2}\s*(?:AM|PM))');
    final match = timeRegex.firstMatch(hours);

    if (match != null) {
      try {
        final openTime = _parseTimeToMinutes(match.group(1)!);
        final closeTime = _parseTimeToMinutes(match.group(2)!);
        final current = _parseTimeToMinutes(currentTime);

        return current >= openTime && current <= closeTime;
      } catch (e) {
        return true;
      }
    }
    return true;
  }

  int _parseTimeToMinutes(String timeStr) {
    final format = DateFormat('h:mm a');
    final date = format.parse(timeStr);
    return date.hour * 60 + date.minute;
  }

  // Convert price string to price level
  String _priceLevelFromString(String price) {
    if (price.contains('\$\$\$\$')) return '\$\$\$\$';
    if (price.contains('\$\$\$')) return '\$\$\$';
    if (price.contains('\$\$')) return '\$\$';
    if (price.contains('\$')) return '\$';
    return '';
  }

  // Helper to get the correct collection name based on category
  String _getCollectionName() {
    switch (widget.category) {
      case 'Attractions':
        return 'attractions';
      case 'Restaurants':
        return 'dining';
      case 'Hotels':
        return 'hotels';
      case 'Events':
        return 'events';
      default:
        return '';
    }
  }

  // Helper to get the correct listing type for detail screen
  String _getListingType() {
    switch (widget.category) {
      case 'Attractions':
        return 'attractions';
      case 'Restaurants':
        return 'dining';
      case 'Hotels':
        return 'hotels';
      case 'Events':
        return 'events';
      default:
        return 'attractions';
    }
  }

  Future<void> _fetchData() async {
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
      final cityId = cityQuery.docs.first.id;

      final subcollection = _getCollectionName();

      if (subcollection.isEmpty) {
        throw Exception('Invalid category');
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('cities')
          .doc(cityId)
          .collection(subcollection)
          .get();

      final items = <AttractionItem>[];
      final Set<String> categories = {'All'};

      for (var doc in snapshot.docs) {
        try {
          final data = doc.data();

          final name = _safeString(data['name']) ?? 'Unnamed';
          final details = _safeString(data['details']) ??
              _safeString(data['description']) ??
              'No description available';

          // ✅ FIX: Make lat/lng nullable and only set if location exists
          double? lat, lng;
          final locationData = data['location'];
          if (locationData != null) {
            if (locationData is GeoPoint) {
              lat = locationData.latitude;
              lng = locationData.longitude;
            } else if (locationData is Map) {
              // Fallback for legacy data stored as Map
              lat = (locationData['latitude'] as num?)?.toDouble();
              lng = (locationData['longitude'] as num?)?.toDouble();
            }
          }

          List<String> extraImages = [];
          if (data['extraImages'] != null) {
            if (data['extraImages'] is List) {
              extraImages = (data['extraImages'] as List)
                  .map((e) => e.toString())
                  .where((url) => url.startsWith('http'))
                  .toList();
            } else if (data['extraImages'] is Map) {
              extraImages = (data['extraImages'] as Map)
                  .values
                  .map((e) => e.toString())
                  .where((url) => url.startsWith('http'))
                  .toList();
            }
          }

          final address = _safeString(data['address']) ?? '';
          final phone = _safeString(data['phoneNumber']) ?? '';
          final openHours = _safeString(data['openHours']) ?? '';
          final price = _safeString(data['price']) ?? '';
          final rating = _safeDouble(data['rating']) ??
              _safeDouble(data['averageRating']) ??
              0.0;
          final reviewCount = _safeInt(data['reviewCount']) ?? 0;
          final hashtag = _safeString(data['hashtag']) ?? '';
          final website = _safeString(data['website']) ?? '';

          final mainImage = extraImages.isNotEmpty
              ? extraImages.first
              : 'https://via.placeholder.com/400x300';
          final priceLevel = _priceLevelFromString(price);

          // Extract category based on main category
          String itemCategory = _extractCategoryForType(
            widget.category,
            name,
            hashtag,
            details,
            priceLevel,
          );
          if (itemCategory.isNotEmpty && itemCategory != 'Other') {
            categories.add(itemCategory);
          }

          final isOpen = _isOpenNow(openHours);

          items.add(AttractionItem(
            id: doc.id,
            title: name,
            imageUrl: mainImage,
            additionalImages: extraImages,
            description: details,
            phone: phone,
            website: website,
            openingHours: openHours,
            rating: rating,
            priceLevel: priceLevel,
            popularity: hashtag,
            cuisine: '', // Will be overridden by category for restaurants
            location: address,
            distance: '0.5 mi',
            actions: <String>['Explore'],
            isOpen: isOpen,
            reviewCount: reviewCount,
            address: address,
            latitude: lat,   // ✅ now nullable
            longitude: lng,  // ✅ now nullable
            city: widget.cityName,
          ));
        } catch (e) {
          print('Error parsing document ${doc.id}: $e');
        }
      }

      setState(() {
        _items = items;
        _availableCategories = categories.toList()..sort();
        _isLoading = false;
      });
    } catch (e) {
      print('Fatal error in _fetchData: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // Extract category based on the main listing type
  String _extractCategoryForType(
    String mainCategory,
    String name,
    String hashtag,
    String description,
    String priceLevel,
  ) {
    final lowerName = name.toLowerCase();
    final lowerHashtag = hashtag.toLowerCase();
    final lowerDesc = description.toLowerCase();

    switch (mainCategory) {
      case 'Attractions':
        final Map<String, List<String>> attractionKeywords = {
          'Museum': ['museum', 'gallery', 'exhibit', 'art'],
          'Park': ['park', 'garden', 'nature', 'outdoor'],
          'Landmark': ['landmark', 'monument', 'historic', 'building', 'tower', 'bridge'],
          'Beach': ['beach', 'coast', 'shore', 'ocean'],
          'Religious': ['church', 'temple', 'mosque', 'cathedral', 'shrine'],
          'Sports': ['stadium', 'arena', 'sport', 'gym', 'field'],
          'Zoo': ['zoo', 'aquarium', 'wildlife'],
          'Shopping': ['mall', 'shop', 'store', 'market', 'boutique'],
        };
        for (var entry in attractionKeywords.entries) {
          for (var keyword in entry.value) {
            if (lowerName.contains(keyword) ||
                lowerHashtag.contains(keyword) ||
                lowerDesc.contains(keyword)) {
              return entry.key;
            }
          }
        }
        return 'Other Attraction';

      case 'Restaurants':
        final Map<String, List<String>> cuisineKeywords = {
          'Italian': ['italian', 'pizza', 'pasta', 'risotto'],
          'Japanese': ['japanese', 'sushi', 'ramen', 'tempura'],
          'Chinese': ['chinese', 'dim sum', 'peking'],
          'Mexican': ['mexican', 'taco', 'burrito', 'enchilada'],
          'Indian': ['indian', 'curry', 'tandoori'],
          'Thai': ['thai', 'pad thai', 'tom yum'],
          'French': ['french', 'bistro', 'croissant'],
          'American': ['american', 'burger', 'steak', 'bbq'],
          'Seafood': ['seafood', 'fish', 'lobster', 'oyster'],
          'Vegetarian': ['vegetarian', 'vegan', 'plant-based'],
          'Fast Food': ['fast food', 'burger', 'fries', 'drive-thru'],
          'Cafe': ['cafe', 'coffee', 'bakery', 'pastry'],
        };
        for (var entry in cuisineKeywords.entries) {
          for (var keyword in entry.value) {
            if (lowerName.contains(keyword) ||
                lowerHashtag.contains(keyword) ||
                lowerDesc.contains(keyword)) {
              return entry.key;
            }
          }
        }
        return 'Other Cuisine';

      case 'Hotels':
        // Use price level or keywords to categorize hotels
        if (priceLevel == '\$\$\$\$') return 'Luxury';
        if (priceLevel == '\$\$\$') return 'Upscale';
        if (priceLevel == '\$\$') return 'Mid-Range';
        if (priceLevel == '\$') return 'Budget';

        final Map<String, List<String>> hotelKeywords = {
          'Resort': ['resort', 'spa', 'beachfront', 'all-inclusive'],
          'Boutique': ['boutique', 'design', 'stylish'],
          'Business': ['business', 'corporate', 'conference'],
          'Motel': ['motel', 'roadside'],
          'Hostel': ['hostel', 'backpacker', 'dorm'],
          'Apartment': ['apartment', 'serviced', 'suite'],
        };
        for (var entry in hotelKeywords.entries) {
          for (var keyword in entry.value) {
            if (lowerName.contains(keyword) ||
                lowerHashtag.contains(keyword) ||
                lowerDesc.contains(keyword)) {
              return entry.key;
            }
          }
        }
        return 'Standard Hotel';

      case 'Events':
        final Map<String, List<String>> eventKeywords = {
          'Concert': ['concert', 'music', 'live', 'band', 'singer'],
          'Festival': ['festival', 'fair', 'celebration', 'carnival'],
          'Conference': ['conference', 'seminar', 'workshop', 'summit'],
          'Exhibition': ['exhibition', 'expo', 'trade show', 'art show'],
          'Sports': ['sport', 'game', 'match', 'tournament', 'race'],
          'Theater': ['theater', 'play', 'musical', 'performance', 'show'],
          'Workshop': ['workshop', 'class', 'training', 'course'],
          'Networking': ['networking', 'meetup', 'social'],
        };
        for (var entry in eventKeywords.entries) {
          for (var keyword in entry.value) {
            if (lowerName.contains(keyword) ||
                lowerHashtag.contains(keyword) ||
                lowerDesc.contains(keyword)) {
              return entry.key;
            }
          }
        }
        return 'Other Event';

      default:
        return 'Other';
    }
  }

  // ---------- FILTER LOGIC ----------
  List<AttractionItem> get _filteredItems {
    return _items.where((item) {
      // Category filter - now uses the correct categories per main type
      if (_selectedCategoryFilter != 'All') {
        // For category filter, we compare with the item's title, description, popularity,
        // but also we can store the extracted category in the item and compare directly.
        // Since we don't have a dedicated category field, we'll check if the filter string
        // appears in the relevant fields.
        if (!item.title.toLowerCase().contains(_selectedCategoryFilter.toLowerCase()) &&
            !item.description.toLowerCase().contains(_selectedCategoryFilter.toLowerCase()) &&
            !item.popularity.toLowerCase().contains(_selectedCategoryFilter.toLowerCase())) {
          return false;
        }
      }

      // Rating filter
      if (_selectedRatingFilter != 'Any Rating') {
        double minRating = double.parse(_selectedRatingFilter.replaceAll('+', ''));
        if (item.rating < minRating) return false;
      }

      // Open now filter
      if (_openNow && !item.isOpen) return false;

      return true;
    }).toList();
  }

  void _resetFilters() {
    setState(() {
      _selectedCategoryFilter = 'All';
      _selectedRatingFilter = 'Any Rating';
      _openNow = false;
    });
  }

  // ---------- FILTER BUTTON BUILDERS ----------
  List<Widget> _buildFilterButtons() {
    final ratingOptions = ['Any Rating'] +
        List.generate(5, (index) => '${index + 1}.0+').reversed.toList();

    return [
      // Category filter
      _buildDropdownButton(
        label: _selectedCategoryFilter,
        options: _availableCategories,
        onSelected: (value) => setState(() => _selectedCategoryFilter = value!),
      ),

      // Open Now toggle
      _buildToggleButton(
        label: 'Open Now',
        value: _openNow,
        onChanged: (value) => setState(() => _openNow = value),
      ),

      // Rating filter
      _buildDropdownButton(
        label: _selectedRatingFilter,
        options: ratingOptions,
        onSelected: (value) => setState(() => _selectedRatingFilter = value!),
      ),
    ];
  }

  Widget _buildDropdownButton({
    required String label,
    required List<String> options,
    required Function(String?) onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: PopupMenuButton<String>(
        onSelected: onSelected,
        itemBuilder: (context) => options.map((option) {
          return PopupMenuItem(
            value: option,
            child: Text(option),
          );
        }).toList(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_drop_down,
                size: 20,
                color: Colors.grey.shade600,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: () => onChanged(!value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: value
                ? const Color.fromARGB(255, 190, 197, 231)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: value ? AppTheme.primaryBlue : Colors.grey.shade300,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: value ? AppTheme.primaryBlue : Colors.grey.shade800,
                ),
              ),
              if (value) ...[
                const SizedBox(width: 4),
                const Icon(Icons.check, size: 16, color: AppTheme.primaryBlue),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ---------- BUILD ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          "Top ${widget.category}",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade900,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.grey.shade800),
          onPressed: () => Navigator.pop(context),
        )
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
                        onPressed: _fetchData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
                        ),
                      ),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: _buildFilterButtons().length,
                        itemBuilder: (context, index) => _buildFilterButtons()[index],
                      ),
                    ),
                    Expanded(
                      child: _filteredItems.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 80,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No ${widget.category} match your filters',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Try adjusting your filters',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  ElevatedButton(
                                    onPressed: _resetFilters,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryBlue,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(13),
                                      ),
                                    ),
                                    child: const Text('Clear Filters'),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                              itemCount: _filteredItems.length,
                              itemBuilder: (context, index) {
                                final item = _filteredItems[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _AttractionCard(
                                    item: item,
                                    listingType: _getListingType(),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
      bottomNavigationBar: FloatingBottomNavBar(
        currentIndex: -1,
        onTap: (index) {
          if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          }
           if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FavoritesScreen()),
            );
          }
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AllPlacesMapScreen()),
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
    );
  }
}

// ------------------------------------------------------------
// Attraction Card - (unchanged)
// ------------------------------------------------------------
class _AttractionCard extends StatefulWidget {
  final AttractionItem item;
  final String listingType;

  const _AttractionCard({
    required this.item,
    required this.listingType,
  });

  @override
  State<_AttractionCard> createState() => _AttractionCardState();
}

class _AttractionCardState extends State<_AttractionCard> {
  bool isFavorited = false;

  String _getItemType(String listingType) {
    switch (listingType) {
      case 'attractions':
        return 'attraction';
      case 'dining':
        return 'restaurant';
      case 'hotels':
        return 'hotel';
      case 'events':
        return 'event';
      default:
        return 'attraction';
    }
  }

  void _navigateToDetail() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AttractionDetailScreen(
          name: widget.item.title,
          imageUrl: widget.item.imageUrl,
          additionalImages: widget.item.additionalImages,
          rating: widget.item.rating,
          reviewCount: widget.item.reviewCount,
          priceLevel: widget.item.priceLevel,
          description: widget.item.description,
          address: widget.item.address,
          city: widget.item.city,
          website: widget.item.website,
          latitude: widget.item.latitude,
          longitude: widget.item.longitude,
          listingType: widget.listingType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return GestureDetector(
      onTap: _navigateToDetail,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    item.imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 180,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.image_not_supported, color: Colors.grey),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: FavoriteButton(
                    itemId: widget.item.id,
                    itemType: _getItemType(widget.listingType),
                    name: widget.item.title,
                    imageUrl: widget.item.imageUrl,
                    cityName: widget.item.city,
                    rating: widget.item.rating,
                    priceLevel: widget.item.priceLevel,
                    address: widget.item.address,
                    size: 20,
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: item.isOpen ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Text(
                      item.isOpen ? "OPEN" : "CLOSED",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    (item.cuisine.isNotEmpty ? item.cuisine : item.location),
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.description,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade800, height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),

                  if (item.phone.isNotEmpty)
                    Row(
                      children: [
                        Icon(Icons.phone, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.phone,
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  if (item.phone.isNotEmpty) const SizedBox(height: 4),
                  if (item.website.isNotEmpty)
                    Row(
                      children: [
                        Icon(Icons.language, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.website,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blue.shade700,
                              decoration: TextDecoration.underline,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  if (item.website.isNotEmpty) const SizedBox(height: 8),
                  if (item.openingHours.isNotEmpty)
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.openingHours,
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  if (item.openingHours.isNotEmpty) const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            item.rating.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 6),
                          Row(
                            children: List.generate(5, (index) {
                              if (index < item.rating.floor()) {
                                return const Icon(Icons.star, color: Colors.amber, size: 18);
                              } else if (index < item.rating) {
                                return const Icon(Icons.star_half, color: Colors.amber, size: 18);
                              } else {
                                return Icon(Icons.star_border, color: Colors.amber.shade300, size: 18);
                              }
                            }),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 100,
                        child: ElevatedButton(
                          onPressed: _navigateToDetail,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                          ),
                          child: Text(
                            item.actions.first,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// Data Model - UPDATED: latitude & longitude are now nullable
// ------------------------------------------------------------
class AttractionItem {
  final String id;
  final String title;
  final String imageUrl;
  final String description;
  final String phone;
  final String website;
  final String openingHours;
  final double rating;
  final String priceLevel;
  final String popularity;
  final String cuisine;
  final String location;
  final String distance;
  final List<String> actions;
  final bool isOpen;
  final int reviewCount;
  final String address;
  final double? latitude;   // ✅ now nullable
  final double? longitude;  // ✅ now nullable
  final String city;
  final List<String>? additionalImages;

  AttractionItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.phone,
    required this.website,
    required this.openingHours,
    required this.rating,
    required this.priceLevel,
    required this.popularity,
    required this.cuisine,
    required this.location,
    required this.distance,
    required this.actions,
    required this.isOpen,
    required this.reviewCount,
    required this.address,
    this.latitude,          // ✅ now optional
    this.longitude,         // ✅ now optional
    required this.city,
    this.additionalImages,
  });
}