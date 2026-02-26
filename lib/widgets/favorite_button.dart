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
  final double size;
  final Color? color;

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
    this.size = 24,
    this.color,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  final FavoritesService _favoritesService = FavoritesService();
  bool _isFavorite = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final isFav = await _favoritesService.isFavorite(widget.itemId);
    if (mounted) {
      setState(() {
        _isFavorite = isFav;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (!_favoritesService.isUserLoggedIn) {
      _showLoginDialog();
      return;
    }

    setState(() => _isLoading = true);

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
        );
        if (mounted) {
          setState(() => _isFavorite = true);
          _showSnackBar('Added to favorites');
        }
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
    if (_isLoading) {
      return SizedBox(
        height: widget.size,
        width: widget.size,
        child: const CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return GestureDetector(
      onTap: _toggleFavorite,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(
          _isFavorite ? Icons.favorite : Icons.favorite_border,
          color: _isFavorite ? Colors.red : (widget.color ?? Colors.grey.shade700),
          size: widget.size,
        ),
      ),
    );
  }
}