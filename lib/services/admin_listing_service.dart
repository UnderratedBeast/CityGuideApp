import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/admin_attraction_model.dart';

class AdminAttractionService {
  final _firestore = FirebaseFirestore.instance;
  final _collection = FirebaseFirestore.instance.collection('attractions');

  // CREATE
  Future<void> addAttraction(AdminAttraction attraction) async {
    await _collection.add(attraction.toMap());
  }

  // READ
  Stream<List<AdminAttraction>> getAttractions() {
    return _collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AdminAttraction.fromDoc(doc))
            .toList());
  }

  // UPDATE
  Future<void> updateAttraction(AdminAttraction attraction) async {
    await _collection.doc(attraction.id).update(attraction.toMap());
  }

  // DELETE
  Future<void> deleteAttraction(String id) async {
    await _collection.doc(id).delete();
  }
}
