// Make sure you have these imports at the top of your favorites_service.dart file
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoritesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Check if user is logged in
  bool get isUserLoggedIn => _auth.currentUser != null;

  // Get user's favorites collection reference
  CollectionReference _getUserFavoritesRef() {
    final userId = currentUserId;
    if (userId == null) {
      throw Exception('User not logged in');
    }
    return _firestore.collection('users').doc(userId).collection('favorites');
  }

  // Add a favorite
  Future<void> addFavorite({
    required String itemId,
    required String itemType, // 'city', 'attraction', 'hotel', 'restaurant', 'event'
    required String name,
    required String imageUrl,
    String? cityName,
    double? rating,
    String? priceLevel,
    String? address,
  }) async {
    if (!isUserLoggedIn) {
      throw Exception('Please log in to save favorites');
    }

    try {
      final favoritesRef = _getUserFavoritesRef();
      
      // Check if already exists
      final existing = await favoritesRef.doc(itemId).get();
      if (existing.exists) {
        return; // Already favorited
      }

      await favoritesRef.doc(itemId).set({
        'itemId': itemId,
        'itemType': itemType,
        'name': name,
        'imageUrl': imageUrl,
        'cityName': cityName ?? '',
        'rating': rating ?? 0.0,
        'priceLevel': priceLevel ?? '',
        'address': address ?? '',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add favorite: $e');
    }
  }

  // Remove a favorite
  Future<void> removeFavorite(String itemId) async {
    if (!isUserLoggedIn) return;

    try {
      final favoritesRef = _getUserFavoritesRef();
      await favoritesRef.doc(itemId).delete();
    } catch (e) {
      throw Exception('Failed to remove favorite: $e');
    }
  }

  // Check if item is favorited
  Future<bool> isFavorite(String itemId) async {
    if (!isUserLoggedIn) return false;

    try {
      final favoritesRef = _getUserFavoritesRef();
      final doc = await favoritesRef.doc(itemId).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // Stream favorites for real-time updates
  Stream<List<FavoriteItem>> getFavoritesStream() {
    if (!isUserLoggedIn) {
      return Stream.value([]);
    }

    return _getUserFavoritesRef()
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return FavoriteItem(
          id: doc.id,
          itemId: data['itemId'] ?? '',
          itemType: data['itemType'] ?? '',
          name: data['name'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
          cityName: data['cityName'] ?? '',
          rating: (data['rating'] ?? 0.0).toDouble(),
          priceLevel: data['priceLevel'] ?? '',
          address: data['address'] ?? '',
          timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
        );
      }).toList();
    });
  }

  // Get favorites count
  Stream<int> getFavoritesCount() {
    if (!isUserLoggedIn) {
      return Stream.value(0);
    }
    return _getUserFavoritesRef().snapshots().map((snapshot) => snapshot.docs.length);
  }
}

// Favorite Item Model - MOVE THIS OUTSIDE THE FavoritesService class
class FavoriteItem {
  final String id;
  final String itemId;
  final String itemType;
  final String name;
  final String imageUrl;
  final String cityName;
  final double rating;
  final String priceLevel;
  final String address;
  final DateTime? timestamp;

  FavoriteItem({
    required this.id,
    required this.itemId,
    required this.itemType,
    required this.name,
    required this.imageUrl,
    required this.cityName,
    required this.rating,
    required this.priceLevel,
    required this.address,
    this.timestamp,
  });

  // Helper to get icon based on type - FIX THE SYNTAX HERE
  IconData get icon {
    switch (itemType) {
      case 'city':
        return Icons.location_city;
      case 'attraction':
        return Icons.attractions;
      case 'hotel':
        return Icons.hotel;
      case 'restaurant':
        return Icons.restaurant;
      case 'event':
        return Icons.event;
      default:
        return Icons.favorite;
    }
  }

  // Helper to get color based on type - FIX THE SYNTAX HERE
  Color get color {
    switch (itemType) {
      case 'city':
        return Colors.purple;
      case 'attraction':
        return Colors.orange;
      case 'hotel':
        return Colors.blue;
      case 'restaurant':
        return Colors.green;
      case 'event':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}