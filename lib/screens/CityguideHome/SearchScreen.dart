// lib/screens/CityguideHome/SearchScreen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:city_guide_app/screens/attraction/AttractionDetailScreen.dart';
import 'package:city_guide_app/utils/theme.dart';

class SearchScreen extends StatefulWidget {
  final String cityName;
  final String cityId;

  const SearchScreen({
    super.key,
    required this.cityName,
    required this.cityId,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All';
  bool _isLoading = false;

  final List<String> _filters = [
    'All',
    'Attractions',
    'Restaurants',
    'Hotels',
    'Events',
  ];

  // Search results
  List<Map<String, dynamic>> _allResults = [];
  List<Map<String, dynamic>> _filteredResults = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
    _performSearch();
  }

  Future<void> _performSearch() async {
    if (_searchQuery.isEmpty) {
      setState(() {
        _filteredResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Determine which collections to search based on filter
      List<String> collectionsToSearch = [];
      switch (_selectedFilter) {
        case 'All':
          collectionsToSearch = ['attractions', 'dining', 'hotels', 'events'];
          break;
        case 'Attractions':
          collectionsToSearch = ['attractions'];
          break;
        case 'Restaurants':
          collectionsToSearch = ['dining'];
          break;
        case 'Hotels':
          collectionsToSearch = ['hotels'];
          break;
        case 'Events':
          collectionsToSearch = ['events'];
          break;
      }

      List<Map<String, dynamic>> results = [];

      // Search each collection
      for (String collection in collectionsToSearch) {
        final snapshot = await FirebaseFirestore.instance
            .collection('cities')
            .doc(widget.cityId)
            .collection(collection)
            .get();

        for (var doc in snapshot.docs) {
          final data = doc.data();
          final name = data['name'] ?? '';
          
          // Case-insensitive search
          if (name.toLowerCase().contains(_searchQuery.toLowerCase())) {
            results.add({
              'id': doc.id,
              'name': name,
              'type': collection,
              'imageUrl': data['imageUrl'] ?? '',
              'rating': data['rating'] ?? 0.0,
              'reviewCount': data['reviewCount'] ?? 0,
              'priceLevel': data['priceLevel'] ?? 
                           (collection == 'attractions' ? 'Attraction' :
                            collection == 'dining' ? 'Restaurant' :
                            collection == 'hotels' ? 'Hotel' : 'Event'),
              'address': data['address'] ?? '',
              'description': data['details'] ?? data['description'] ?? '',
              'latitude': data['latitude'] ?? 
                         (data['location'] != null ? data['location']['latitude'] : null),
              'longitude': data['longitude'] ?? 
                          (data['location'] != null ? data['location']['longitude'] : null),
              'website': data['website'] ?? '',
              'additionalImages': data['extraImages'] != null 
                  ? List<String>.from(data['extraImages']) 
                  : [],
            });
          }
        }
      }

      setState(() {
        _allResults = results;
        _filteredResults = results;
        _isLoading = false;
      });
    } catch (e) {
      print('Search error: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Search failed: $e')),
      );
    }
  }

  String _getListingType(String collectionName) {
    switch (collectionName) {
      case 'attractions':
        return 'attractions';
      case 'dining':
        return 'dining';
      case 'hotels':
        return 'hotels';
      case 'events':
        return 'events';
      default:
        return 'attractions';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.grey.shade800),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Search in ${widget.cityName}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search attractions, restaurants, hotels...',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey.shade600),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),

          // Filter Chips
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = filter == _selectedFilter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                      _performSearch();
                    },
                    backgroundColor: Colors.grey.shade100,
                    selectedColor: AppTheme.primaryBlue.withOpacity(0.2),
                    checkmarkColor: AppTheme.primaryBlue,
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade700,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(
                        color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Results Count
          if (_searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '${_filteredResults.length} results found',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          // Results List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _searchQuery.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search,
                              size: 80,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Start typing to search',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : _filteredResults.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 80,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No results found for "$_searchQuery"',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Try different keywords or filters',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredResults.length,
                            itemBuilder: (context, index) {
                              final item = _filteredResults[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AttractionDetailScreen(
                                        name: item['name'],
                                        imageUrl: item['imageUrl'],
                                        rating: item['rating'].toDouble(),
                                        reviewCount: item['reviewCount'],
                                        priceLevel: item['priceLevel'],
                                        description: item['description'],
                                        address: item['address'],
                                        city: widget.cityName,
                                        website: item['website'],
                                        latitude: item['latitude'] != null 
                                            ? item['latitude'].toDouble() 
                                            : null,
                                        longitude: item['longitude'] != null 
                                            ? item['longitude'].toDouble() 
                                            : null,
                                        additionalImages: item['additionalImages'],
                                        listingType: _getListingType(item['type']),
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.shade200,
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      // Image
                                      ClipRRect(
                                        borderRadius: const BorderRadius.horizontal(
                                          left: Radius.circular(16),
                                        ),
                                        child: Image.network(
                                          item['imageUrl'],
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            width: 100,
                                            height: 100,
                                            color: Colors.grey.shade300,
                                            child: Icon(
                                              _getIconForType(item['type']),
                                              color: Colors.grey.shade600,
                                              size: 40,
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Content
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // Type badge
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: _getColorForType(item['type'])
                                                      .withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  _getDisplayType(item['type']),
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                    color: _getColorForType(item['type']),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              // Name
                                              Text(
                                                item['name'],
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              // Rating
                                              if (item['rating'] > 0)
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.star,
                                                      color: Colors.amber,
                                                      size: 14,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      item['rating'].toStringAsFixed(1),
                                                      style: const TextStyle(fontSize: 13),
                                                    ),
                                                    if (item['reviewCount'] > 0)
                                                      Text(
                                                        ' (${item['reviewCount']})',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey.shade600,
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              const SizedBox(height: 4),
                                              // Address
                                              if (item['address'].isNotEmpty)
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.location_on,
                                                      size: 12,
                                                      color: Colors.grey.shade500,
                                                    ),
                                                    const SizedBox(width: 2),
                                                    Expanded(
                                                      child: Text(
                                                        item['address'],
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey.shade600,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'attractions':
        return Icons.attractions;
      case 'dining':
        return Icons.restaurant;
      case 'hotels':
        return Icons.hotel;
      case 'events':
        return Icons.event;
      default:
        return Icons.place;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'attractions':
        return Colors.orange;
      case 'dining':
        return Colors.green;
      case 'hotels':
        return Colors.blue;
      case 'events':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getDisplayType(String type) {
    switch (type) {
      case 'attractions':
        return 'ATTRACTION';
      case 'dining':
        return 'RESTAURANT';
      case 'hotels':
        return 'HOTEL';
      case 'events':
        return 'EVENT';
      default:
        return type.toUpperCase();
    }
  }
}