// lib/widgets/favorite_button.dart
import 'package:city_guide_app/services/favorites_service.dart';
import 'package:flutter/material.dart';

class FavoriteButton extends StatefulWidget {
  final String itemId;
  final String itemType;
  final String name;
  final String imageUrl;
  final String? cityName;
  final double? rating;
  final String? priceLevel;
  final String? address;
  final String? description;
  final double? latitude;
  final double? longitude;
  final List<String>? additionalImages;
  final String? website;
  final String? phoneNumber;
  final double size;
  final Color? color;
  final bool initialFavoriteState; // New parameter

  const FavoriteButton({
    super.key,
    required this.itemId,
    required this.itemType,
    required this.name,
    required this.imageUrl,
    this.cityName,
    this.rating,
    this.priceLevel,
    this.address,
    this.description,
    this.latitude,
    this.longitude,
    this.additionalImages,
    this.website,
    this.phoneNumber,
    this.size = 24,
    this.color,
    this.initialFavoriteState = false, // Default to false
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  final FavoritesService _favoritesService = FavoritesService();
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    // Use the initial state passed from parent
    _isFavorite = widget.initialFavoriteState;
    
    // Still check the actual favorite status in the background
    // but don't show loading state
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final isFav = await _favoritesService.isFavorite(widget.itemId);
    if (mounted && _isFavorite != isFav) {
      setState(() {
        _isFavorite = isFav;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (!_favoritesService.isUserLoggedIn) {
      _showLoginDialog();
      return;
    }

    try {
      if (_isFavorite) {
        await _favoritesService.removeFavorite(widget.itemId);
        if (mounted) {
          setState(() => _isFavorite = false);
          _showSnackBar('Removed from favorites');
        }
      } else {
        await _favoritesService.addFavorite(
          itemId: widget.itemId,
          itemType: widget.itemType,
          name: widget.name,
          imageUrl: widget.imageUrl,
          cityName: widget.cityName,
          rating: widget.rating,
          priceLevel: widget.priceLevel,
          address: widget.address,
          description: widget.description,
          latitude: widget.latitude,
          longitude: widget.longitude,
          additionalImages: widget.additionalImages,
          website: widget.website,
          phoneNumber: widget.phoneNumber,
        );
        if (mounted) {
          setState(() => _isFavorite = true);
          _showSnackBar('Added to favorites');
        }
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    }
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign in required'),
        content: const Text('Please sign in to save favorites'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to login screen
            },
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleFavorite,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color.fromARGB(55, 10, 10, 10).withOpacity(0.4),
          shape: BoxShape.circle,
        ),
        child: Icon(
          _isFavorite ? Icons.favorite : Icons.favorite_border,
          color: _isFavorite ? Colors.red : (widget.color ?? const Color.fromARGB(255, 255, 255, 255)),
          size: widget.size,
        ),
      ),
    );
  }
}