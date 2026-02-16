import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAttraction {
  final String id;
  final String name;
  final String description;
  final String category;
  final String location;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  AdminAttraction({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.location,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdminAttraction.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return AdminAttraction(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      location: data['location'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'location': location,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
