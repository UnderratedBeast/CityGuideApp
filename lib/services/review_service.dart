// lib/services/review_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/review_model.dart';
import 'activity_service.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ActivityService _activityService = ActivityService();

  // Submit a new review
  Future<String> submitReview({
    required String cityId,
    required String listingId,
    required String listingType,
    required int rating,
    required String reviewText,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Check if user already reviewed this listing
      final existingReview = await _firestore
          .collection('reviews')
          .where('userId', isEqualTo: user.uid)
          .where('listingId', isEqualTo: listingId)
          .where('cityId', isEqualTo: cityId)
          .limit(1)
          .get();

      if (existingReview.docs.isNotEmpty) {
        throw Exception('You have already reviewed this listing');
      }

      // Get user data from users collection
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userName = userDoc.data()?['fullName'] ?? user.displayName ?? 'Anonymous';
      final userProfileImage = userDoc.data()?['profileImage'] ?? user.photoURL ?? '';

      // Create review object with likes/likedBy
      final review = ReviewModel(
        id: '', // will be assigned by Firestore
        cityId: cityId,
        listingId: listingId,
        listingType: listingType,
        userId: user.uid,
        userName: userName,
        userProfileImage: userProfileImage,
        rating: rating,
        reviewText: reviewText,
        status: 'pending',
        createdAt: DateTime.now(),
        likes: 0,
        likedBy: [],
      );

      // Save to Firestore
      final docRef = await _firestore.collection('reviews').add(review.toMap());

      // LOG ACTIVITY - Review submitted
      await _activityService.log(
        type: 'review',
        title: 'New Review Submitted',
        body: '$userName added a $rating-star review',
        refId: listingId,
      );

      return docRef.id;
    } catch (e) {
      if (kDebugMode) debugPrint('Error submitting review: $e');
      rethrow;
    }
  }

  // --- LIKE / UNLIKE METHODS ---

  /// Like a review. Adds current user ID to `likedBy` and increments `likes`.
  Future<void> likeReview(String reviewId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final reviewRef = _firestore.collection('reviews').doc(reviewId);

    await _firestore.runTransaction((transaction) async {
      final reviewSnap = await transaction.get(reviewRef);
      if (!reviewSnap.exists) {
        throw Exception('Review not found');
      }

      final data = reviewSnap.data()!;
      List<String> likedBy = List<String>.from(data['likedBy'] ?? []);
      int likes = data['likes'] ?? 0;

      if (!likedBy.contains(user.uid)) {
        likedBy.add(user.uid);
        likes++;
        transaction.update(reviewRef, {
          'likedBy': likedBy,
          'likes': likes,
        });
      }
    });
  }

  /// Unlike a review. Removes current user ID from `likedBy` and decrements `likes`.
  Future<void> unlikeReview(String reviewId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final reviewRef = _firestore.collection('reviews').doc(reviewId);

    await _firestore.runTransaction((transaction) async {
      final reviewSnap = await transaction.get(reviewRef);
      if (!reviewSnap.exists) {
        throw Exception('Review not found');
      }

      final data = reviewSnap.data()!;
      List<String> likedBy = List<String>.from(data['likedBy'] ?? []);
      int likes = data['likes'] ?? 0;

      if (likedBy.contains(user.uid)) {
        likedBy.remove(user.uid);
        likes--;
        transaction.update(reviewRef, {
          'likedBy': likedBy,
          'likes': likes,
        });
      }
    });
  }

  // Approve review (admin only) with transaction to update listing stats
  Future<void> approveReview(String reviewId, int rating, {
    required String cityId,
    required String listingId,
    required String listingType,
  }) async {
    final db = FirebaseFirestore.instance;
    final reviewRef = db.collection('reviews').doc(reviewId);

    try {
      // Get the review data first to know who wrote it
      final reviewDoc = await reviewRef.get();
      if (!reviewDoc.exists) {
        throw Exception('Review not found');
      }
      
      final reviewData = reviewDoc.data();
      final userName = reviewData?['userName'] ?? 'A user';

      // Get listing reference
      final listingRef = db
          .collection('cities')
          .doc(cityId)
          .collection(listingType)
          .doc(listingId);

      await db.runTransaction((transaction) async {
        // Get listing document
        final listingSnap = await transaction.get(listingRef);

        if (!listingSnap.exists) {
          throw Exception('Listing not found');
        }

        final listingData = listingSnap.data() ?? {};
        
        final currentCount = (listingData['reviewCount'] as num?)?.toInt() ?? 0;
        final currentTotal = (listingData['totalRating'] as num?)?.toInt() ?? 0;
        
        final newCount = currentCount + 1;
        final newTotal = currentTotal + rating;
        final newAverage = newTotal / newCount;

        transaction.update(listingRef, {
          'reviewCount': newCount,
          'totalRating': newTotal,
          'averageRating': newAverage,
        });

        transaction.update(reviewRef, {
          'status': 'approved',
          'adminId': FirebaseAuth.instance.currentUser!.uid,
          'adminReviewedAt': FieldValue.serverTimestamp(),
        });
      });

      // LOG ACTIVITY - Review approved
      await _activityService.log(
        type: 'review',
        title: 'Review Approved',
        body: 'Review by $userName has been approved',
        refId: reviewId,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error approving review: $e');
      rethrow;
    }
  }

  // Reject review (admin only)
  Future<void> rejectReview(String reviewId) async {
    try {
      final reviewDoc = await _firestore.collection('reviews').doc(reviewId).get();
      if (!reviewDoc.exists) throw Exception('Review not found');
      
      final reviewData = reviewDoc.data();
      final userName = reviewData?['userName'] ?? 'A user';

      await _firestore
          .collection('reviews')
          .doc(reviewId)
          .update({
        'status': 'rejected',
        'adminId': FirebaseAuth.instance.currentUser!.uid,
        'adminReviewedAt': FieldValue.serverTimestamp(),
      });

      await _activityService.log(
        type: 'review',
        title: 'Review Rejected',
        body: 'Review by $userName has been rejected',
        refId: reviewId,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error rejecting review: $e');
      rethrow;
    }
  }

  // Delete a review (admin only)
  Future<void> deleteReview(String reviewId) async {
    try {
      final reviewDoc = await _firestore.collection('reviews').doc(reviewId).get();
      if (!reviewDoc.exists) throw Exception('Review not found');
      
      final reviewData = reviewDoc.data();
      final userName = reviewData?['userName'] ?? 'A user';

      await _firestore.collection('reviews').doc(reviewId).delete();

      await _activityService.log(
        type: 'review',
        title: 'Review Deleted',
        body: 'Review by $userName was deleted',
        refId: reviewId,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error deleting review: $e');
      rethrow;
    }
  }

  // Get listing details for preview (admin panel)
  Future<Map<String, dynamic>?> getListingDetails({
    required String cityId,
    required String listingId,
    required String listingType,
  }) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('cities')
          .doc(cityId)
          .collection(listingType)
          .doc(listingId)
          .get();
      return doc.data();
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting listing: $e');
      return null;
    }
  }

  // Get review statistics (admin dashboard)
  Future<Map<String, int>> getReviewStats() async {
    try {
      final batch = await _firestore.collection('reviews').get();
      int pending = 0, approved = 0, rejected = 0;
      for (var doc in batch.docs) {
        final status = doc.data()['status'] ?? 'pending';
        if (status == 'pending') pending++;
        else if (status == 'approved') approved++;
        else if (status == 'rejected') rejected++;
      }
      return {
        'pending': pending,
        'approved': approved,
        'rejected': rejected,
        'total': batch.docs.length,
      };
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting review stats: $e');
      return {'pending': 0, 'approved': 0, 'rejected': 0, 'total': 0};
    }
  }

  // Get all pending reviews (admin)
  Stream<List<ReviewModel>> getPendingReviews() {
    return _firestore
        .collection('reviews')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReviewModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Get all approved reviews (admin)
  Stream<List<ReviewModel>> getApprovedReviews() {
    return _firestore
        .collection('reviews')
        .where('status', isEqualTo: 'approved')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReviewModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Get all rejected reviews (admin)
  Stream<List<ReviewModel>> getRejectedReviews() {
    return _firestore
        .collection('reviews')
        .where('status', isEqualTo: 'rejected')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReviewModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Get approved reviews for a specific listing
  Stream<List<ReviewModel>> getListingReviews({
    required String cityId,
    required String listingId,
    required String listingType,
  }) {
    return _firestore
        .collection('reviews')
        .where('cityId', isEqualTo: cityId)
        .where('listingId', isEqualTo: listingId)
        .where('listingType', isEqualTo: listingType)
        .where('status', isEqualTo: 'approved')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReviewModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Check if user has already reviewed this listing
  Future<bool> hasUserReviewed(String listingId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final query = await _firestore
          .collection('reviews')
          .where('userId', isEqualTo: user.uid)
          .get();
      return query.docs.any((doc) => doc.data()['listingId'] == listingId);
    } catch (e) {
      if (kDebugMode) debugPrint('Error checking reviews: $e');
      return false;
    }
  }

  // Get user's pending reviews
  Stream<List<ReviewModel>> getUserPendingReviews() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('reviews')
        .where('userId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReviewModel.fromMap(doc.id, doc.data()))
            .toList());
  }
}