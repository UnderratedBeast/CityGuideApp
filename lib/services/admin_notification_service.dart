// lib/services/notification_service.dart
//
// ┌─────────────────────────────────────────────────────────────────────────┐
// │  HOW THE WHOLE SYSTEM WORKS                                             │
// │                                                                         │
// │  1. Admin adds a listing to any collection                              │
// │     (attractions / dining / events / hotels)                            │
// │                                                                         │
// │  2. Admin panel calls NotificationService.pushNew___()                  │
// │     → creates one doc in  notifications/{autoId}                        │
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
  static final _db = FirebaseFirestore.instance;

  // ── Category constants ─────────────────────────────────────────────────────
  static const String catAttraction = 'attraction';
  static const String catDining     = 'dining';
  static const String catEvent      = 'event';
  static const String catHotel      = 'hotel';

  // ── Core push method ───────────────────────────────────────────────────────
  static Future<DocumentReference> pushListingNotification({
    required String category,
    required String title,
    required String body,
    String? imageUrl,
    String? listingId,
    Map<String, dynamic> extra = const {},
  }) {
    return _db.collection('notifications').add({
      'category' : category,
      'title'    : title,
      'body'     : body,
      'imageUrl' : imageUrl  ?? '',
      'listingId': listingId ?? '',
      'createdAt': FieldValue.serverTimestamp(),
      ...extra,
    });
  }

  // ── Convenience wrappers for each listing type ────────────────────────────

  static Future<void> newAttraction({
    required String name,
    required String description,
    String? imageUrl,
    String? listingId,
  }) =>
      pushListingNotification(
        category : catAttraction,
        title    : '🏛️ New Attraction: $name',
        body     : description,
        imageUrl : imageUrl,
        listingId: listingId,
      );

  static Future<void> newDining({
    required String name,
    required String description,
    String? imageUrl,
    String? listingId,
  }) =>
      pushListingNotification(
        category : catDining,
        title    : '🍽️ New Restaurant: $name',
        body     : description,
        imageUrl : imageUrl,
        listingId: listingId,
      );

  static Future<void> newEvent({
    required String name,
    required String description,
    String? imageUrl,
    String? listingId,
  }) =>
      pushListingNotification(
        category : catEvent,
        title    : '🎉 New Event: $name',
        body     : description,
        imageUrl : imageUrl,
        listingId: listingId,
      );

  static Future<void> newHotel({
    required String name,
    required String description,
    String? imageUrl,
    String? listingId,
  }) =>
      pushListingNotification(
        category : catHotel,
        title    : '🏨 New Hotel: $name',
        body     : description,
        imageUrl : imageUrl,
        listingId: listingId,
      );

  // ── Unread count stream (use for bell badge anywhere in the app) ───────────
  //
  //   StreamBuilder<int>(
  //     stream: NotificationService.unreadCountStream(uid),
  //     builder: (ctx, snap) {
  //       final n = snap.data ?? 0;
  //       return Badge(label: Text('$n'), child: Icon(Icons.notifications));
  //     },
  //   )
  static Stream<int> unreadCountStream(String uid) {
    return _db.collection('notifications').snapshots().asyncMap((global) async {
      final read = await _db
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .get();
      final readIds = read.docs.map((d) => d.id).toSet();
      return global.docs.where((d) => !readIds.contains(d.id)).length;
    });
  }

  // ── Admin: delete a notification ───────────────────────────────────────────
  static Future<void> deleteNotification(String notifId) =>
      _db.collection('notifications').doc(notifId).delete();
}