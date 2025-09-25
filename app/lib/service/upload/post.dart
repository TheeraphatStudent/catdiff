import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class UploadService {
  static Future<String?> uploadProfileImage(File imageFile, String userId) async {
    try {
      final storageRef = FirebaseStorage.instance.ref();
      final imageRef = storageRef.child('profile_images/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg');

      final uploadTask = imageRef.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() => null);

      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
}