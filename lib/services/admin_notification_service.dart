// lib/services/notification_service.dart
//
// ┌─────────────────────────────────────────────────────────────────────────┐
// │  HOW THE WHOLE SYSTEM WORKS                                             │
// │                                                                         │
// │  1. Admin adds a listing to any collection                              │
// │     (attractions / dining / events / hotels)                            │
// │                                                                         │
// │  2. Admin panel calls NotificationService.pushNew___()                  │
// │     → creates one doc in notifications/{autoId}                         │
// │                                                                         │
// │  3. Every user's NotificationsScreen streams that collection            │
// │     → new card appears in REAL-TIME for all users                       │
// │                                                                         │
// │  4. User taps a card → read state saved to                              │
// │     users/{uid}/notifications/{notifId}  {readAt: Timestamp}            │
// │     so read/unread is tracked per user, not globally                    │
// └─────────────────────────────────────────────────────────────────────────┘
//
// ── Firestore Security Rules to add ───────────────────────────────────────
//
//   match /notifications/{id} {
//     allow read:  if request.auth != null;
//     allow write: if false;   // admin SDK / Cloud Functions only
//   }
//   match /users/{uid}/notifications/{id} {
//     allow read, write: if request.auth.uid == uid;
//   }
//
// ── Firestore data shape ───────────────────────────────────────────────────
//
//   notifications/{id}
//   ├── category   : "hotel"    ← attraction | dining | event | hotel
//   ├── title      : "New Hotel: The Grand Royale"
//   ├── body       : "Luxury 5-star now open in Midtown"
//   ├── imageUrl   : "https://..."
//   ├── listingId  : "docId in its own collection"
//   └── createdAt  : Timestamp
//
//   users/{uid}/notifications/{notifId}
//   ├── readAt     : Timestamp
//   └── dismissed  : bool
//
// ── Optional Cloud Function (auto-trigger on listing creation) ─────────────
//
//   // functions/index.js
//   exports.onNewHotel = functions.firestore
//     .document('hotels/{hotelId}')
//     .onCreate(async (snap, ctx) => {
//       const d = snap.data();
//       await admin.firestore().collection('notifications').add({
//         category : 'hotel',
//         title    : `🏨 New Hotel: ${d.name}`,
//         body     : d.description || '',
//         imageUrl : d.imageUrl    || '',
//         listingId: ctx.params.hotelId,
//         createdAt: admin.firestore.FieldValue.serverTimestamp(),
//       });
//     });
//   // Repeat for attractions, dining, events

import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> pushNotification({
    required String category,
    required String title,
    required String body,
    required String cityId,
    required String listingId,
    String? imageUrl,
  }) async {
    await _db.collection('notifications').add({
      'category': category,
      'title': title,
      'body': body,
      'cityId': cityId,
      'listingId': listingId,
      'imageUrl': imageUrl ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Convenience wrappers

  static Future<void> newAttraction({
    required String cityId,
    required String name,
    required String description,
    required String listingId,
    String? imageUrl,
  }) =>
      pushNotification(
        category: 'attraction',
        title: '🏛️ New Attraction: $name',
        body: description,
        cityId: cityId,
        listingId: listingId,
        imageUrl: imageUrl,
      );

  static Future<void> newHotel({
    required String cityId,
    required String name,
    required String description,
    required String listingId,
    String? imageUrl,
  }) =>
      pushNotification(
        category: 'hotel',
        title: '🏨 New Hotel: $name',
        body: description,
        cityId: cityId,
        listingId: listingId,
        imageUrl: imageUrl,
      );

  static Future<void> newDining({
    required String cityId,
    required String name,
    required String description,
    required String listingId,
    String? imageUrl,
  }) =>
      pushNotification(
        category: 'dining',
        title: '🍽️ New Restaurant: $name',
        body: description,
        cityId: cityId,
        listingId: listingId,
        imageUrl: imageUrl,
      );

  static Future<void> newEvent({
    required String cityId,
    required String name,
    required String description,
    required String listingId,
    String? imageUrl,
  }) =>
      pushNotification(
        category: 'event',
        title: '🎉 New Event: $name',
        body: description,
        cityId: cityId,
        listingId: listingId,
        imageUrl: imageUrl,
      );
}