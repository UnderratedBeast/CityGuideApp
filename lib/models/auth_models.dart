import 'package:cloud_firestore/cloud_firestore.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a copy of the user with updated fields
  UserModel copyWith({
    String? uid,
    String? email,
    String? fullName,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert UserModel to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Create UserModel from a Firestore DocumentSnapshot
  factory UserModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: data['uid'] ?? doc.id,
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      photoUrl: data['photoUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Create UserModel from Firebase Auth User + additional data
  factory UserModel.fromFirebaseUser(
    String uid,
    String email,
    String fullName, {
    String? photoUrl,
  }) {
    final now = DateTime.now();
    return UserModel(
      uid: uid,
      email: email,
      fullName: fullName,
      photoUrl: photoUrl,
      createdAt: now,
      updatedAt: now,
    );
  }
}