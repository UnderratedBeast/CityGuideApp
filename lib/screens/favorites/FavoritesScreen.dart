// lib/screens/favorites/favorites_screen.dart
import 'package:city_guide_app/screens/attraction/AttractionDetailScreen.dart';
import 'package:city_guide_app/screens/CityguideHome/CityDetailScreen.dart';
import 'package:city_guide_app/services/favorites_service.dart';
import 'package:city_guide_app/utils/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoritesService _favoritesService = FavoritesService();
  String? _selectedFilter = 'All';

  final List<String> _filters = [
    'All',
    'Cities',
    'Attractions',
    'Restaurants',
    'Hotels',
    'Events',
  ];

  @override
  Widget build(BuildContext context) {
    // Check if user is logged in
    if (!_favoritesService.isUserLoggedIn) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Favorites'),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite_border,
                size: 80,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'Sign in to see your favorites',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Navigate to login screen
                  // You'll need to implement your login screen navigation
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                child: const Text('Sign In'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Favorites'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          // Filter button
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) {
              return _filters.map((filter) {
                return PopupMenuItem(
                  value: filter,
                  child: Row(
                    children: [
                      if (_selectedFilter == filter)
                        const Icon(Icons.check, size: 18, color: AppTheme.primaryBlue),
                      if (_selectedFilter == filter) const SizedBox(width: 8),
                      Text(filter),
                    ],
                  ),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: StreamBuilder<List<FavoriteItem>>(
        stream: _favoritesService.getFavoritesStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading favorites',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final favorites = snapshot.data!;
          
          // Apply filter
          final filteredFavorites = _selectedFilter == 'All'
              ? favorites
              : favorites.where((item) {
                  String type = item.itemType;
                  if (_selectedFilter == 'Cities') return type == 'city';
                  if (_selectedFilter == 'Attractions') return type == 'attraction';
                  if (_selectedFilter == 'Restaurants') return type == 'restaurant';
                  if (_selectedFilter == 'Hotels') return type == 'hotel';
                  if (_selectedFilter == 'Events') return type == 'event';
                  return true;
                }).toList();

          if (filteredFavorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _selectedFilter == 'All'
                        ? 'No favorites yet'
                        : 'No ${_selectedFilter?.toLowerCase()} in favorites',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Items you favorite will appear here',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredFavorites.length,
            itemBuilder: (context, index) {
              final favorite = filteredFavorites[index];
              return _FavoriteCard(favorite: favorite);
            },
          );
        },
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final FavoriteItem favorite;

  const _FavoriteCard({required this.favorite});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to appropriate detail screen
        _navigateToDetail(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              child: Image.network(
                favorite.imageUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey.shade300,
                  child: Icon(
                    favorite.icon,
                    color: favorite.color,
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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: favorite.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                favorite.icon,
                                size: 12,
                                color: favorite.color,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                favorite.itemType.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: favorite.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      favorite.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (favorite.cityName.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        favorite.cityName,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (favorite.rating > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            favorite.rating.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // Remove button
            IconButton(
              icon: const Icon(Icons.close, color: Colors.grey),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Remove from favorites?'),
                    content: Text('Remove ${favorite.name} from your favorites?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Remove'),
                      ),
                    ],
                  ),
                );
                
                if (confirm == true) {
                  await FavoritesService().removeFavorite(favorite.itemId);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context) {
    switch (favorite.itemType) {
      case 'city':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CityDetailScreen(
              cityName: favorite.name,
              country: favorite.cityName, // You might need to store country separately
              heroImageUrl: favorite.imageUrl,
            ),
          ),
        );
        break;
      case 'attraction':
      case 'restaurant':
      case 'hotel':
      case 'event':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AttractionDetailScreen(
              name: favorite.name,
              imageUrl: favorite.imageUrl,
              rating: favorite.rating,
              reviewCount: 0, // You might want to store this
              priceLevel: favorite.priceLevel,
              description: '', // You might want to store this
              address: favorite.address,
              city: favorite.cityName,
              website: '', // You might want to store this
              listingType: favorite.itemType == 'attraction' ? 'attractions' :
                          favorite.itemType == 'restaurant' ? 'dining' :
                          favorite.itemType == 'hotel' ? 'hotels' : 'events',
            ),
          ),
        );
        break;
    }
  }
}