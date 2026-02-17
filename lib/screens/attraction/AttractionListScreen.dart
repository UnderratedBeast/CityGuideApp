import 'package:flutter/material.dart';
import 'package:city_guide_app/screens/attraction/AttractionDetailScreen.dart';
import '../../utils/theme.dart';
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

  // Original items getter
  List<AttractionItem> get _allItems => _getItemsForCategory();

  List<AttractionItem> _getItemsForCategory() {
    switch (widget.category) {
      case 'Attractions':
        return [
          AttractionItem(
            title: 'The Big Ben',
            imageUrl: 'https://picsum.photos/id/1043/400/300',
            additionalImages: [],
            description: 'Iconic clock tower at the Palace of Westminster.',
            phone: '+44 20 1234 5678',
            website: 'parliament.uk/bigben',
            openingHours: 'Mon–Sun 09:00–17:00',
            rating: 4.8,
            priceLevel: '££',
            popularity: 'Most Visited',
            cuisine: 'Landmark',
            location: 'Westminster',
            distance: '0.8 mi',
            actions: ['Book Tour'],
            isOpen: true,
            reviewCount: 12400,
            address: 'Westminster, London SW1A 0AA',
            latitude: 51.5007,
            longitude: -0.1246,
            city: widget.cityName,
          ),
          AttractionItem(
            title: 'London Eye',
            imageUrl: 'https://picsum.photos/id/1043/400/300?random=2',
            additionalImages: [],
            description: 'Giant Ferris wheel on the South Bank.',
            phone: '+44 20 1234 5679',
            website: 'londoneye.com',
            openingHours: 'Mon–Sun 10:00–20:30',
            rating: 4.7,
            priceLevel: '£££',
            popularity: 'Very Popular',
            cuisine: 'Landmark',
            location: 'Lambeth',
            distance: '1.2 mi',
            actions: ['Buy Tickets'],
            isOpen: true,
            reviewCount: 8900,
            address: 'Riverside Building, County Hall, London SE1 7PB',
            latitude: 51.5033,
            longitude: -0.1195,
            city: widget.cityName,
          ),
        ];
      case 'Restaurants':
        return [
          AttractionItem(
            title: "L'Osteria Urbano",
            imageUrl: 'https://picsum.photos/id/30/400/300',
            additionalImages: [],
            description: 'Authentic Italian pasta and wood‑fired pizza.',
            phone: '+1 212-555-1234',
            website: 'losteria.com',
            openingHours: 'Mon–Sun 11:00–23:00',
            rating: 4.8,
            priceLevel: '\$\$\$',
            popularity: 'Very Popular',
            cuisine: 'Italian',
            location: 'Downtown',
            distance: '0.8 mi',
            actions: ['Book Table'],
            isOpen: true,
            reviewCount: 1240,
            address: '42nd Ave, Stay Tower',
            latitude: 40.7580,
            longitude: -73.9855,
            city: widget.cityName,
          ),
          AttractionItem(
            title: 'The Blue Grill',
            imageUrl: 'https://picsum.photos/id/26/400/300',
            additionalImages: [],
            description: 'Premium steaks and seafood with panoramic waterfront views.',
            phone: '+1 212-555-5678',
            website: 'bluegrill.nyc',
            openingHours: 'Tue–Sun 17:00–23:00',
            rating: 4.5,
            priceLevel: '\$\$\$\$',
            popularity: 'Fine Dining',
            cuisine: 'Steakhouse',
            location: 'Waterfront',
            distance: '1.2 mi',
            actions: ['View Menu'],
            isOpen: true,
            reviewCount: 890,
            address: '1 Waterfront Plaza, NYC',
            latitude: 40.7050,
            longitude: -74.0130,
            city: widget.cityName,
          ),
        ];
      case 'Hotels':
        return [
          AttractionItem(
            title: 'The Ritz London',
            imageUrl: 'https://picsum.photos/id/1081/400/300',
            additionalImages: [],
            description: 'Luxury hotel in the heart of London.',
            phone: '+44 20 1234 5680',
            website: 'theritzlondon.com',
            openingHours: '24/7',
            rating: 4.9,
            priceLevel: '££££',
            popularity: 'Luxury',
            cuisine: 'Hotel',
            location: 'Mayfair',
            distance: '0.4 mi',
            actions: ['Book Now'],
            isOpen: true,
            reviewCount: 3400,
            address: '150 Piccadilly, London W1J 9BR',
            latitude: 51.5074,
            longitude: -0.1419,
            city: widget.cityName,
          ),
        ];
      case 'Events':
        return [
          AttractionItem(
            title: 'Hyde Park Music Festival',
            imageUrl: 'https://picsum.photos/id/15/400/300',
            additionalImages: [],
            description: 'Outdoor music festival with top artists.',
            phone: '+44 20 1234 5681',
            website: 'hydeparkfestival.com',
            openingHours: '19:00–23:00',
            rating: 4.6,
            priceLevel: '££',
            popularity: 'Trending',
            cuisine: 'Festival',
            location: 'Hyde Park',
            distance: '2.0 mi',
            actions: ['Get Tickets'],
            isOpen: true,
            reviewCount: 3200,
            address: 'Hyde Park, London W2 2UH',
            latitude: 51.5074,
            longitude: -0.1657,
            city: widget.cityName,
          ),
        ];
      default:
        return [];
    }
  }

  List<AttractionItem> get _filteredItems {
    return _allItems.where((item) {
      if (_selectedRating != 'Any Rating') {
        double minRating = double.parse(_selectedRating.replaceAll('+', ''));
        if (item.rating < minRating) return false;
      }
      switch (widget.category) {
        case 'Attractions':
          if (_selectedCategory != 'All Categories' && item.cuisine != _selectedCategory) return false;
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
          if (_selectedEventType != 'All Types' && item.cuisine != _selectedEventType) return false;
          if (_selectedFreePaid == 'Free' && item.priceLevel != 'Free') return false;
          if (_selectedFreePaid == 'Paid' && item.priceLevel == 'Free') return false;
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

  // Reset all filters to default
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
              color: value ? AppTheme.primaryBlue: Colors.grey.shade300,
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

  @override
  Widget build(BuildContext context) {
    final items = _filteredItems;

    return Scaffold(
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
      body: Column(
        children: [
          // Filter row – always visible
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
          // Content area – either list or empty state
          Expanded(
            child: items.isEmpty
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
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _AttractionCard(item: item),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppTheme.primaryBlue,
        unselectedItemColor: Colors.grey.shade500,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: "Explore"),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: "General"),
          BottomNavigationBarItem(icon: Icon(Icons.info_outline), label: "About"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------
// Attraction Card (unchanged)
// ------------------------------------------------------------
class _AttractionCard extends StatefulWidget {
  final AttractionItem item;
  const _AttractionCard({required this.item});

  @override
  State<_AttractionCard> createState() => _AttractionCardState();
}

class _AttractionCardState extends State<_AttractionCard> {
  bool isFavorited = false;

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
                // Favorite heart (toggle)
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () => setState(() => isFavorited = !isFavorited),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorited ? Icons.favorite : Icons.favorite_border,
                        color: isFavorited ? Colors.red : Colors.grey.shade700,
                        size: 20,
                      ),
                    ),
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
                  // Name
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Cuisine • location • distance
                  Text(
                    "${item.cuisine} • ${item.location} • ${item.distance}",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Description (2 lines max)
                  Text(
                    item.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade800,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),

                  // ----- CONTACT & OPENING HOURS -----
                  Row(
                    children: [
                      Icon(Icons.phone, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.phone,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade800,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
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
                  const SizedBox(height: 8),
                  // Opening hours
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.openingHours,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade800,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ----- RATING & ACTION BUTTON -----
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Rating with stars
                      Row(
                        children: [
                          Text(
                            item.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
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
                      // Action button – fixed width
                      SizedBox(
                        width: 100,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: item.actions.contains("Map") || item.actions.contains("Directions")
                                ? Colors.grey.shade100
                                : AppTheme.primaryBlue,
                            foregroundColor: item.actions.contains("Map") || item.actions.contains("Directions")
                                ? Colors.grey.shade800
                                : Colors.white,
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
// Data Model
// ------------------------------------------------------------
class AttractionItem {
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