import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String? id;
  final String cityId;
  final String listingId;
  final String listingType;
  final String userId;
  final String userName;
  final String userProfileImage;
  final int rating;
  final String reviewText;
  final DateTime? createdAt;
  final String status;
  final String? adminId;
  final DateTime? adminReviewedAt;
  final int likes;                // new field
  final List<String> likedBy;     // new field

  ReviewModel({
    this.id,
    required this.cityId,
    required this.listingId,
    required this.listingType,
    required this.userId,
    required this.userName,
    required this.userProfileImage,
    required this.rating,
    required this.reviewText,
    this.createdAt,
    required this.status,
    this.adminId,
    this.adminReviewedAt,
    this.likes = 0,                // default
    this.likedBy = const [],       // default
  });

  // Convert to JSON for Firestore
  Map<String, dynamic> toMap() {
    return {
      'cityId': cityId,
      'listingId': listingId,
      'listingType': listingType,
      'userId': userId,
      'userName': userName,
      'userProfileImage': userProfileImage,
      'rating': rating,
      'reviewText': reviewText,
      'createdAt': createdAt != null 
          ? Timestamp.fromDate(createdAt!) 
          : FieldValue.serverTimestamp(),
      'status': status,
      'adminId': adminId,
      'adminReviewedAt': adminReviewedAt != null 
          ? Timestamp.fromDate(adminReviewedAt!) 
          : null,
      'likes': likes,
      'likedBy': likedBy,
    };
  }

  // Create from Firestore document
  factory ReviewModel.fromMap(String id, Map<String, dynamic> map) {
    return ReviewModel(
      id: id,
      cityId: map['cityId'] ?? '',
      listingId: map['listingId'] ?? '',
      listingType: map['listingType'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Anonymous',
      userProfileImage: map['userProfileImage'] ?? '',
      rating: map['rating'] ?? 0,
      reviewText: map['reviewText'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      status: map['status'] ?? 'pending',
      adminId: map['adminId'],
      adminReviewedAt: (map['adminReviewedAt'] as Timestamp?)?.toDate(),
      likes: map['likes'] ?? 0,
      likedBy: List<String>.from(map['likedBy'] ?? []),
    );
  }
}