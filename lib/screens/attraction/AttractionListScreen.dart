import 'package:city_guide_app/screens/CityguideHome/CityListScreen.dart';
import 'package:city_guide_app/screens/profile/profile_screen.dart';
import 'package:city_guide_app/widgets/favorite_button.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:city_guide_app/screens/attraction/AttractionDetailScreen.dart';
import '../../utils/theme.dart';
import 'package:city_guide_app/widgets/floating_bottom_nav_bar.dart';

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
  String _selectedPrice = 'Any Price';
  String _selectedRating = 'Any Rating';
  String _selectedCategory = 'All Categories';
  String _selectedCuisine = 'All Cuisines';
  String _selectedEventType = 'All Types';
  String _selectedDate = 'Upcoming';
  String _selectedFreePaid = 'All';
  String _selectedDistance = 'Any Distance';
  bool _openNow = false;

  // Data and loading states
  bool _isLoading = true;
  String? _errorMessage;
  List<AttractionItem> _items = [];
  int _currentNavIndex = 0;

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

  // Convert price string like "From $120 per adult..." to price level ($, $$, etc.)
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
// In AttractionListScreen, update the _fetchData method to properly map Firestore fields

Future<void> _fetchData() async {
  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  try {
    // 1. Get city document ID from cityName
    final cityQuery = await FirebaseFirestore.instance
        .collection('cities')
        .where('name', isEqualTo: widget.cityName)
        .limit(1)
        .get();

    if (cityQuery.docs.isEmpty) {
      throw Exception('City "${widget.cityName}" not found');
    }
    final cityId = cityQuery.docs.first.id;

    // 2. Get collection name
    final subcollection = _getCollectionName();

    if (subcollection.isEmpty) {
      throw Exception('Invalid category');
    }

    // 3. Fetch documents from subcollection
    final snapshot = await FirebaseFirestore.instance
        .collection('cities')
        .doc(cityId)
        .collection(subcollection)
        .get();

    final items = <AttractionItem>[];

    for (var doc in snapshot.docs) {
      try {
        final data = doc.data();

        // --- Map fields according to your Firestore structure ---
        final name = _safeString(data['name']) ?? 'Unnamed';
        
        // Description/details field
        final details = _safeString(data['details']) ?? 
                        _safeString(data['description']) ?? 
                        'No description available';
        
        // Extract location coordinates from location map
        double lat = 0.0, lng = 0.0;
        if (data['location'] is Map) {
          final loc = data['location'] as Map;
          lat = _safeDouble(loc['latitude']) ?? 0.0;
          lng = _safeDouble(loc['longitude']) ?? 0.0;
        }
        
        // Handle extraImages - could be an array or a map
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
        
        // Price field - could be string with price info
        final price = _safeString(data['price']) ?? '';
        
        // Rating - could be 'rating' or 'averageRating'
        final rating = _safeDouble(data['rating']) ?? 
                       _safeDouble(data['averageRating']) ?? 
                       0.0;
        
        // Review count
        final reviewCount = _safeInt(data['reviewCount']) ?? 0;
        
        // Hashtag (for categories/tags)
        final hashtag = _safeString(data['hashtag']) ?? '';
        
        // Website
        final website = _safeString(data['website']) ?? '';

        // Determine main image: first from extraImages, or empty
        final mainImage = extraImages.isNotEmpty ? extraImages.first : 'https://via.placeholder.com/400x300';

        // Price level conversion
        final priceLevel = _priceLevelFromString(price);

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
          cuisine: '', // You might need to map this from somewhere else
          location: address,
          distance: '0.5 mi', // Default or calculate later
          actions: <String>['Explore'],
          isOpen: true, // Default or determine from openHours
          reviewCount: reviewCount,
          address: address,
          latitude: lat,
          longitude: lng,
          city: widget.cityName,
        ));
      } catch (e) {
        print('Error parsing document ${doc.id}: $e');
      }
    }

    setState(() {
      _items = items;
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

  // ---------- FILTER LOGIC ----------
  List<AttractionItem> get _filteredItems {
    return _items.where((item) {
      if (_selectedRating != 'Any Rating') {
        double minRating = double.parse(_selectedRating.replaceAll('+', ''));
        if (item.rating < minRating) return false;
      }
      switch (widget.category) {
        case 'Attractions':
          if (_openNow && !item.isOpen) return false;
          break;
        case 'Restaurants':
          if (_selectedCuisine != 'All Cuisines' && item.cuisine != _selectedCuisine) return false;
          if (_selectedPrice != 'Any Price' && !_matchesPriceLevel(item.priceLevel, _selectedPrice)) return false;
          break;
        case 'Hotels':
          if (_selectedPrice != 'Any Price' && !_matchesPriceLevel(item.priceLevel, _selectedPrice)) return false;
          break;
        case 'Events':
          // No event-specific filters for now
          break;
      }
      return true;
    }).toList();
  }

  bool _matchesPriceLevel(String priceLevel, String selected) {
    if (selected == r'Budget ($)' && priceLevel == '\$') return true;
    if (selected == r'Moderate ($$)' && priceLevel == '\$\$') return true;
    if (selected == r'Luxury ($$$)' && priceLevel == '\$\$\$') return true;
    if (selected == r'Ultra Luxury ($$$$)' && priceLevel == '\$\$\$\$') return true;
    return false;
  }

  void _resetFilters() {
    setState(() {
      _selectedPrice = 'Any Price';
      _selectedRating = 'Any Rating';
      _selectedCategory = 'All Categories';
      _selectedCuisine = 'All Cuisines';
      _selectedEventType = 'All Types';
      _selectedDate = 'Upcoming';
      _selectedFreePaid = 'All';
      _selectedDistance = 'Any Distance';
      _openNow = false;
    });
  }

  // ---------- FILTER BUTTON BUILDERS ----------
  List<Widget> _buildFilterButtons() {
    switch (widget.category) {
      case 'Attractions':
        return [
          _buildDropdownButton(
            label: _selectedCategory,
            options: const ['All Categories', 'Museum', 'Park', 'Landmark', 'Beach'],
            onSelected: (value) => setState(() => _selectedCategory = value!),
          ),
          _buildDropdownButton(
            label: _selectedRating,
            options: const ['Any Rating', '4.0+', '4.5+'],
            onSelected: (value) => setState(() => _selectedRating = value!),
          ),
          _buildToggleButton(
            label: 'Open Now',
            value: _openNow,
            onChanged: (value) => setState(() => _openNow = value),
          ),
        ];
      case 'Restaurants':
        return [
          _buildDropdownButton(
            label: _selectedCuisine,
            options: const ['All Cuisines', 'Italian', 'Japanese', 'American', 'Steakhouse'],
            onSelected: (value) => setState(() => _selectedCuisine = value!),
          ),
          _buildDropdownButton(
            label: _selectedPrice,
            options: const ['Any Price', r'Budget ($)', r'Moderate ($$)', r'Luxury ($$$)'],
            onSelected: (value) => setState(() => _selectedPrice = value!),
          ),
          _buildDropdownButton(
            label: _selectedRating,
            options: const ['Any Rating', '4.0+', '4.5+'],
            onSelected: (value) => setState(() => _selectedRating = value!),
          ),
        ];
      case 'Hotels':
        return [
          _buildDropdownButton(
            label: _selectedPrice,
            options: const ['Any Price', r'Budget ($)', r'Moderate ($$)', r'Luxury ($$$)', r'Ultra Luxury ($$$$)'],
            onSelected: (value) => setState(() => _selectedPrice = value!),
          ),
          _buildDropdownButton(
            label: _selectedRating,
            options: const ['Any Rating', '4.0+', '4.5+'],
            onSelected: (value) => setState(() => _selectedRating = value!),
          ),
          _buildDropdownButton(
            label: _selectedDistance,
            options: const ['Any Distance', '<1 mi', '<2 mi', '<5 mi'],
            onSelected: (value) => setState(() => _selectedDistance = value!),
          ),
        ];
      case 'Events':
        return [
          _buildDropdownButton(
            label: _selectedEventType,
            options: const ['All Types', 'Concert', 'Festival', 'Conference'],
            onSelected: (value) => setState(() => _selectedEventType = value!),
          ),
          _buildDropdownButton(
            label: _selectedDate,
            options: const ['Today', 'This Weekend', 'Upcoming'],
            onSelected: (value) => setState(() => _selectedDate = value!),
          ),
          _buildDropdownButton(
            label: _selectedFreePaid,
            options: const ['All', 'Free', 'Paid'],
            onSelected: (value) => setState(() => _selectedFreePaid = value!),
          ),
        ];
      default:
        return [];
    }
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
            color: value ? const Color.fromARGB(255, 190, 197, 231) : Colors.grey.shade100,
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
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.grey.shade800),
            onPressed: () {},
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
                        onPressed: _fetchData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Filter row
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
                    // Content
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
                                    listingType: _getListingType(), // Pass the listing type
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
// Attraction Card - Updated to accept listingType
// ------------------------------------------------------------
class _AttractionCard extends StatefulWidget {
  final AttractionItem item;
  final String listingType; // Add this

  const _AttractionCard({
    required this.item,
    required this.listingType, // Add this
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
  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AttractionDetailScreen(
              name: item.title,
              imageUrl: item.imageUrl,
              additionalImages: item.additionalImages,
              rating: item.rating,
              reviewCount: item.reviewCount,
              priceLevel: item.priceLevel,
              description: item.description,
              address: item.address,
              city: item.city,
              website: item.website,
              latitude: item.latitude,
              longitude: item.longitude,
              listingType: widget.listingType, // Pass the correct listing type
            ),
          ),
        );
      },
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
            // ----- IMAGE WITH OVERLAYS -----
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
                // Favorite heart
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
                // Open/Closed badge
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

            // ----- CONTENT -----
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

                  // Contact & opening hours
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

                  // Rating & action button
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
                          onPressed: () {},
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
// Data Model - Added id field
// ------------------------------------------------------------
class AttractionItem {
  final String id; // Add this
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
  final double latitude;
  final double longitude;
  final String city;
  final List<String>? additionalImages;

  AttractionItem({
    required this.id, // Add this
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
    required this.latitude,
    required this.longitude,
    required this.city,
    this.additionalImages,
  });
}