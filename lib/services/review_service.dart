// // lib/services/review_service.dart
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../models/review_model.dart'; 

// class ReviewService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   // Submit a new review
//   Future<String> submitReview({
//     required String cityId,
//     required String listingId,
//     required String listingType,
//     required int rating,
//     required String reviewText,
//   }) async {
//     try {
//       final user = _auth.currentUser;
//       if (user == null) throw Exception('User not logged in');

//       // Check if user already reviewed this listing
//       final existingReview = await _firestore
//           .collection('reviews')
//           .where('userId', isEqualTo: user.uid)
//           .where('listingId', isEqualTo: listingId)
//           .where('cityId', isEqualTo: cityId)
//           .limit(1)
//           .get();

//       if (existingReview.docs.isNotEmpty) {
//         throw Exception('You have already reviewed this listing');
//       }

//       // Get user data from users collection
//       final userDoc = await _firestore.collection('users').doc(user.uid).get();
//       final userName = userDoc.data()?['fullName'] ?? user.displayName ?? 'Anonymous';
//       print('User data from Firestore: ${userDoc.data()}');
//       print('profileImage field: ${userDoc.data()?['profileImage']}');
//       print('user.photoURL: ${user.photoURL}');

//       final userProfileImage = userDoc.data()?['profileImage'] ?? user.photoURL ?? '';
//       print('Final profile image URL: $userProfileImage');

//       // Create review object
//       final review = ReviewModel(
//         cityId: cityId,
//         listingId: listingId,
//         listingType: listingType,
//         userId: user.uid,
//         userName: userName,
//         userProfileImage: userProfileImage,
//         rating: rating,
//         reviewText: reviewText,
//         status: 'pending', // Always pending for moderation
//       );

//       // Save to Firestore
//       final docRef = await _firestore.collection('reviews').add(review.toMap());
      
//       return docRef.id;
//     } catch (e) {
//       print('Error submitting review: $e');
//       rethrow;
//     }
//   }

//   // Get approved reviews for a specific listing
//   Stream<List<ReviewModel>> getListingReviews({
//     required String cityId,
//     required String listingId,
//     required String listingType,
//   }) {
//     return _firestore
//         .collection('reviews')
//         .where('cityId', isEqualTo: cityId)
//         .where('listingId', isEqualTo: listingId)
//         .where('listingType', isEqualTo: listingType)
//         .where('status', isEqualTo: 'approved')
//         .orderBy('createdAt', descending: true)
//         .snapshots()
//         .map((snapshot) {
//           return snapshot.docs
//               .map((doc) => ReviewModel.fromMap(doc.id, doc.data()))
//               .toList();
//         });
//   }

//   // Check if user has already reviewed this listing
//   Future<bool> hasUserReviewed(String listingId) async {
//     final user = _auth.currentUser;
//     if (user == null) return false;

//     try {
//       // Try to get the user's reviews
//       final query = await _firestore
//           .collection('reviews')
//           .where('userId', isEqualTo: user.uid)
//           .get();
      
//       // Check if any match this listing
//       return query.docs.any((doc) => 
//           doc.data()['listingId'] == listingId);
//     } catch (e) {
//       // If permission denied, assume they haven't reviewed
//       print('Error checking reviews: $e');
//       return false;
//     }
//   }

//   // Get user's pending reviews
//   Stream<List<ReviewModel>> getUserPendingReviews() {
//     final user = _auth.currentUser;
//     if (user == null) return Stream.value([]);

//     return _firestore
//         .collection('reviews')
//         .where('userId', isEqualTo: user.uid)
//         .where('status', isEqualTo: 'pending')
//         .orderBy('createdAt', descending: true)
//         .snapshots()
//         .map((snapshot) {
//           return snapshot.docs
//               .map((doc) => ReviewModel.fromMap(doc.id, doc.data()))
//               .toList();
//         });
//   }

//   // ============= ADMIN METHODS =============

//   // Get all pending reviews (for admin)
//   Stream<List<ReviewModel>> getPendingReviews() {
//     return _firestore
//         .collection('reviews')
//         .where('status', isEqualTo: 'pending')
//         .orderBy('createdAt', descending: true)
//         .snapshots()
//         .map((snapshot) {
//           return snapshot.docs
//               .map((doc) => ReviewModel.fromMap(doc.id, doc.data()))
//               .toList();
//         });
//   }

//   // Get all approved reviews (for admin)
//   Stream<List<ReviewModel>> getApprovedReviews() {
//     return _firestore
//         .collection('reviews')
//         .where('status', isEqualTo: 'approved')
//         .orderBy('createdAt', descending: true)
//         .snapshots()
//         .map((snapshot) {
//           return snapshot.docs
//               .map((doc) => ReviewModel.fromMap(doc.id, doc.data()))
//               .toList();
//         });
//   }

//   // Get all rejected reviews (for admin)
//   Stream<List<ReviewModel>> getRejectedReviews() {
//     return _firestore
//         .collection('reviews')
//         .where('status', isEqualTo: 'rejected')
//         .orderBy('createdAt', descending: true)
//         .snapshots()
//         .map((snapshot) {
//           return snapshot.docs
//               .map((doc) => ReviewModel.fromMap(doc.id, doc.data()))
//               .toList();
//         });
//   }

//   // Approve review (admin only) with transaction to update listing stats
//   Future<void> approveReview(String reviewId, int rating, {
//     required String cityId,
//     required String listingId,
//     required String listingType,
//   }) async {
//     final db = FirebaseFirestore.instance;
//     final reviewRef = db.collection('reviews').doc(reviewId);
    
//     // Get listing reference
//     final listingRef = db
//         .collection('cities')
//         .doc(cityId)
//         .collection(listingType)
//         .doc(listingId);
    
//     await db.runTransaction((transaction) async {
//       // Get listing document
//       final listingSnap = await transaction.get(listingRef);
      
//       if (!listingSnap.exists) {
//         throw Exception('Listing not found');
//       }
      
//       // Update listing stats
//       final currentCount = listingSnap.get('reviewCount') ?? 0;
//       final currentTotal = listingSnap.get('totalRating') ?? 0;
      
//       final newCount = currentCount + 1;
//       final newTotal = currentTotal + rating;
//       final newAverage = newTotal / newCount;
      
//       transaction.update(listingRef, {
//         'reviewCount': newCount,
//         'totalRating': newTotal,
//         'averageRating': newAverage,
//       });
      
//       // Update review status
//       transaction.update(reviewRef, {
//         'status': 'approved',
//         'adminId': FirebaseAuth.instance.currentUser!.uid,
//         'adminReviewedAt': FieldValue.serverTimestamp(),
//       });
//     });
//   }

//   // Reject review (admin only)
//   Future<void> rejectReview(String reviewId) async {
//     await FirebaseFirestore.instance
//         .collection('reviews')
//         .doc(reviewId)
//         .update({
//       'status': 'rejected',
//       'adminId': FirebaseAuth.instance.currentUser!.uid,
//       'adminReviewedAt': FieldValue.serverTimestamp(),
//     });
//   }

//   // Get listing details for preview (used in admin panel)
//   Future<Map<String, dynamic>?> getListingDetails({
//     required String cityId,
//     required String listingId,
//     required String listingType,
//   }) async {
//     try {
//       final doc = await FirebaseFirestore.instance
//           .collection('cities')
//           .doc(cityId)
//           .collection(listingType)
//           .doc(listingId)
//           .get();
      
//       return doc.data();
//     } catch (e) {
//       print('Error getting listing: $e');
//       return null;
//     }
//   }

//   // Delete a review (admin only - for spam/abuse)
//   Future<void> deleteReview(String reviewId) async {
//     await FirebaseFirestore.instance
//         .collection('reviews')
//         .doc(reviewId)
//         .delete();
//   }

//   // Get review statistics (admin dashboard)
//   Future<Map<String, int>> getReviewStats() async {
//     final batch = await _firestore.collection('reviews').get();
    
//     int pending = 0;
//     int approved = 0;
//     int rejected = 0;
    
//     for (var doc in batch.docs) {
//       final status = doc.data()['status'] ?? 'pending';
//       if (status == 'pending') pending++;
//       else if (status == 'approved') approved++;
//       else if (status == 'rejected') rejected++;
//     }
    
//     return {
//       'pending': pending,
//       'approved': approved,
//       'rejected': rejected,
//       'total': batch.docs.length,
//     };
//   }
// }



// lib/services/review_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // For debugPrint and kDebugMode
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
      
      if (kDebugMode) {
        debugPrint('User data from Firestore: ${userDoc.data()}');
        debugPrint('profileImage field: ${userDoc.data()?['profileImage']}');
        debugPrint('user.photoURL: ${user.photoURL}');
      }

      final userProfileImage = userDoc.data()?['profileImage'] ?? user.photoURL ?? '';
      
      if (kDebugMode) {
        debugPrint('Final profile image URL: $userProfileImage');
      }

      // Create review object
      final review = ReviewModel(
        cityId: cityId,
        listingId: listingId,
        listingType: listingType,
        userId: user.uid,
        userName: userName,
        userProfileImage: userProfileImage,
        rating: rating,
        reviewText: reviewText,
        status: 'pending', // Always pending for moderation
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
      if (kDebugMode) {
        debugPrint('Error submitting review: $e');
      }
      rethrow;
    }
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

        // SAFELY get the data - handle case where fields don't exist
        final listingData = listingSnap.data() ?? {};
        
        // Get current stats with null checking
        final currentCount = (listingData['reviewCount'] as num?)?.toInt() ?? 0;
        final currentTotal = (listingData['totalRating'] as num?)?.toInt() ?? 0;
        
        // Calculate new stats
        final newCount = currentCount + 1;
        final newTotal = currentTotal + rating;
        final newAverage = newTotal / newCount;

        // Update listing stats
        transaction.update(listingRef, {
          'reviewCount': newCount,
          'totalRating': newTotal,
          'averageRating': newAverage,
        });

        // Update review status
        transaction.update(reviewRef, {
          'status': 'approved',
          'adminId': FirebaseAuth.instance.currentUser!.uid,
          'adminReviewedAt': FieldValue.serverTimestamp(),
        });
      });

      // LOG ACTIVITY - Review approved (after transaction succeeds)
      await _activityService.log(
        type: 'review',
        title: 'Review Approved',
        body: 'Review by $userName has been approved',
        refId: reviewId,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error approving review: $e');
      }
      rethrow;
    }
  }

  // Reject review (admin only)
  Future<void> rejectReview(String reviewId) async {
    try {
      // Get the review data first
      final reviewDoc = await _firestore.collection('reviews').doc(reviewId).get();
      if (!reviewDoc.exists) {
        throw Exception('Review not found');
      }
      
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

      // LOG ACTIVITY - Review rejected
      await _activityService.log(
        type: 'review',
        title: 'Review Rejected',
        body: 'Review by $userName has been rejected',
        refId: reviewId,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error rejecting review: $e');
      }
      rethrow;
    }
  }

  // Delete a review (admin only - for spam/abuse)
  Future<void> deleteReview(String reviewId) async {
    try {
      // Get the review data before deleting
      final reviewDoc = await _firestore.collection('reviews').doc(reviewId).get();
      if (!reviewDoc.exists) {
        throw Exception('Review not found');
      }
      
      final reviewData = reviewDoc.data();
      final userName = reviewData?['userName'] ?? 'A user';

      await _firestore
          .collection('reviews')
          .doc(reviewId)
          .delete();

      // LOG ACTIVITY - Review deleted
      await _activityService.log(
        type: 'review',
        title: 'Review Deleted',
        body: 'Review by $userName was deleted',
        refId: reviewId,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error deleting review: $e');
      }
      rethrow;
    }
  }

  // Get listing details for preview (used in admin panel)
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
      if (kDebugMode) {
        debugPrint('Error getting listing: $e');
      }
      return null;
    }
  }

  // Get review statistics (admin dashboard)
  Future<Map<String, int>> getReviewStats() async {
    try {
      final batch = await _firestore.collection('reviews').get();

      int pending = 0;
      int approved = 0;
      int rejected = 0;

      for (var doc in batch.docs) {
        final status = doc.data()['status'] ?? 'pending';
        if (status == 'pending') {
          pending++;
        } else if (status == 'approved') {
          approved++;
        } else if (status == 'rejected') {
          rejected++;
        }
      }

      return {
        'pending': pending,
        'approved': approved,
        'rejected': rejected,
        'total': batch.docs.length,
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting review stats: $e');
      }
      return {
        'pending': 0,
        'approved': 0,
        'rejected': 0,
        'total': 0,
      };
    }
  }

  // Get all pending reviews (for admin)
  Stream<List<ReviewModel>> getPendingReviews() {
    return _firestore
        .collection('reviews')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ReviewModel.fromMap(doc.id, doc.data()))
              .toList();
        });
  }

  // Get all approved reviews (for admin)
  Stream<List<ReviewModel>> getApprovedReviews() {
    return _firestore
        .collection('reviews')
        .where('status', isEqualTo: 'approved')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ReviewModel.fromMap(doc.id, doc.data()))
              .toList();
        });
  }

  // Get all rejected reviews (for admin)
  Stream<List<ReviewModel>> getRejectedReviews() {
    return _firestore
        .collection('reviews')
        .where('status', isEqualTo: 'rejected')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ReviewModel.fromMap(doc.id, doc.data()))
              .toList();
        });
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
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ReviewModel.fromMap(doc.id, doc.data()))
              .toList();
        });
  }

  // Check if user has already reviewed this listing
  Future<bool> hasUserReviewed(String listingId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      // Try to get the user's reviews
      final query = await _firestore
          .collection('reviews')
          .where('userId', isEqualTo: user.uid)
          .get();

      // Check if any match this listing
      return query.docs.any((doc) => 
          doc.data()['listingId'] == listingId);
    } catch (e) {
      // If permission denied, assume they haven't reviewed
      if (kDebugMode) {
        debugPrint('Error checking reviews: $e');
      }
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
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ReviewModel.fromMap(doc.id, doc.data()))
              .toList();
        });
  }
}