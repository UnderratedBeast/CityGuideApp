import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ActivityService {
  static Future<void> log({
    required String type,
    required String title,
    required String body,
    String? refId,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    await FirebaseFirestore.instance.collection('activities').add({
      'type': type,
      'title': title,
      'body': body,
      'refId': refId,
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': user?.uid,
    });
  }
}