import 'dart:developer';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class UploadService {
  static Future<String?> uploadProfileImage(
    File imageFile,
    String userId,
  ) async {
    try {
      // Create a unique filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${timestamp}_${userId}_profile.jpg';

      // Use the correct Firebase Storage path for catdiff app
      // The path structure: catdiff/profiles/{userId}/{filename}
      final storageRef = FirebaseStorage.instance.ref();
      final imageRef = storageRef.child('catdiff/profiles/$userId/$fileName');

      // Set metadata for better organization
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uploadedBy': userId,
          'uploadedAt': timestamp.toString(),
          'app': 'catdiff',
        },
      );

      // Upload with metadata
      final uploadTask = imageRef.putFile(imageFile, metadata);

      // Monitor upload progress and handle errors
      uploadTask.snapshotEvents.listen(
        (TaskSnapshot snapshot) {
          print(
            'Upload progress: ${snapshot.bytesTransferred}/${snapshot.totalBytes}',
          );
        },
        onError: (Object e) {
          print('Upload error during transfer: $e');
        },
      );

      // Wait for upload to complete
      final snapshot = await uploadTask.whenComplete(() => null);

      // Check if upload was successful
      if (snapshot.state == TaskState.success) {
        // Get the download URL
        final downloadUrl = await snapshot.ref.getDownloadURL();
        print('Upload successful! Download URL: $downloadUrl');
        return downloadUrl;
      } else {
        print('Upload failed with state: ${snapshot.state}');
        return null;
      }
    } catch (e) {
      print('Error uploading image: $e');

      // Provide more specific error messages
      if (e.toString().contains('permission-denied')) {
        print('Permission denied: Check Firebase Storage security rules');
      } else if (e.toString().contains('object-not-found')) {
        print('Object not found: The storage bucket or path may not exist');
      } else if (e.toString().contains('quota-exceeded')) {
        print('Quota exceeded: Storage quota has been exceeded');
      } else if (e.toString().contains('unauthenticated')) {
        print('Unauthenticated: User is not authenticated');
      }

      return null;
    }
  }

  // Alternative upload method with retry logic
  static Future<String?> uploadProfileImageWithRetry(
    File imageFile,
    String userId, {
    int maxRetries = 3,
  }) async {
    int attempts = 0;

    while (attempts < maxRetries) {
      attempts++;
      print('Upload attempt $attempts/$maxRetries');

      try {
        final result = await uploadProfileImage(imageFile, userId);
        if (result != null) {
          return result;
        }
      } catch (e) {
        print('Attempt $attempts failed: $e');
        if (attempts == maxRetries) {
          throw e;
        }
        // Wait before retry
        await Future.delayed(Duration(seconds: attempts));
      }
    }

    return null;
  }

  // Method to check if storage bucket exists and is accessible
  static Future<bool> checkStorageAccess() async {
    try {
      final storageRef = FirebaseStorage.instance.ref();

      log(storageRef.toString());

      final testRef = storageRef.child('catdiff/test.txt');

      // Try to get metadata of a test file (this will fail if bucket doesn't exist)
      await testRef.getMetadata();
      return true;
    } catch (e) {
      print('Storage access check failed: $e');
      return false;
    }
  }
}
