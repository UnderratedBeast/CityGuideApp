import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadProfileImage(String userId, File imageFile) async {
    final ref = _storage.ref().child('profile_pics').child('$userId.jpg');
    await ref.putFile(imageFile);
    final url = await ref.getDownloadURL();
    return url;
  }
}