import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:app/service/upload/post.dart';
import 'package:app/firebase_options.dart';

class StorageTest {
  static Future<Map<String, dynamic>> runFullDiagnostic() async {
    print('🔍 Starting Firebase Storage Diagnostic...');
    final results = <String, dynamic>{};

    try {
      // 1. Test Firebase Initialization
      print('1️⃣ Testing Firebase initialization...');
      results['firebase_init'] = await _testFirebaseInit();

      // 2. Test Storage Instance
      print('2️⃣ Testing Storage instance...');
      results['storage_instance'] = await _testStorageInstance();

      // 3. Test Bucket Access
      print('3️⃣ Testing bucket access...');
      results['bucket_access'] = await _testBucketAccess();

      // 4. Test Path Creation
      print('4️⃣ Testing path creation...');
      results['path_creation'] = await _testPathCreation();

      // 5. Test Simple Upload
      print('5️⃣ Testing simple upload...');
      results['simple_upload'] = await _testSimpleUpload();

      print('✅ Diagnostic completed');
      return {'success': true, 'results': results};
    } catch (e) {
      print('❌ Diagnostic failed: $e');
      return {'success': false, 'error': e.toString(), 'results': results};
    }
  }

  static Future<Map<String, dynamic>> _testFirebaseInit() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      final app = Firebase.app();
      return {
        'success': true,
        'project_id': app.options.projectId,
        'app_name': app.name,
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> _testStorageInstance() async {
    try {
      final storage = FirebaseStorage.instance;
      final bucket = storage.bucket; // Default bucket
      return {
        'success': true,
        'bucket': bucket,
        'maxDownloadRetryTime': storage.maxDownloadRetryTime.inSeconds,
        'maxUploadRetryTime': storage.maxUploadRetryTime.inSeconds,
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> _testBucketAccess() async {
    try {
      final storage = FirebaseStorage.instance;

      // Try to create a reference to a non-existent test file
      // This will work if the bucket exists, even if the file doesn't
      final testRef = storage.ref('__firebase_storage_test__/test.txt');

      // Try to get download URL for a non-existent file (this should fail gracefully)
      try {
        await testRef.getDownloadURL();
        // If this succeeds unexpectedly, return success
        return {
          'success': true,
          'bucket_exists': true,
          'bucket': storage.bucket,
          'note': 'Bucket accessible',
        };
      } catch (e) {
        // If it fails with "object-not-found", bucket exists but file doesn't (expected)
        if (e.toString().contains('object-not-found')) {
          return {
            'success': true,
            'bucket_exists': true,
            'bucket': storage.bucket,
            'note': 'Bucket exists but test file does not (expected)',
          };
        }
        // If it fails with other errors, it might indicate bucket issues
        return {
          'success': false,
          'error': e.toString(),
          'error_type': _classifyError(e.toString()),
          'bucket': storage.bucket,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'error_type': _classifyError(e.toString()),
      };
    }
  }

  static Future<Map<String, dynamic>> _testPathCreation() async {
    try {
      final storage = FirebaseStorage.instance;

      // Test different paths
      final paths = [
        '',
        'catdiff',
        'catdiff/profiles',
        'catdiff/profiles/test',
      ];

      final pathResults = <String, dynamic>{};

      for (final path in paths) {
        try {
          final ref = storage.ref(path);
          // Try to get metadata (will fail if path doesn't exist)
          await ref.getMetadata();
          pathResults[path] = {'exists': true};
        } catch (e) {
          pathResults[path] = {
            'exists': false,
            'error': e.toString(),
            'error_type': _classifyError(e.toString()),
          };
        }
      }

      return {'success': true, 'paths': pathResults};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> _testSimpleUpload() async {
    try {
      // Create a simple test file
      final testContent = 'Test file - ${DateTime.now().toIso8601String()}';
      final tempDir = Directory.systemTemp;
      final testFile = File('${tempDir.path}/firebase_test.txt');
      await testFile.writeAsString(testContent);

      // Try upload to a simple path
      final storage = FirebaseStorage.instance;
      final ref = storage.ref(
        'test/firebase_test_${DateTime.now().millisecondsSinceEpoch}.txt',
      );

      final uploadTask = ref.putString(testContent);
      final snapshot = await uploadTask.whenComplete(() => null);

      if (snapshot.state == TaskState.success) {
        final downloadUrl = await snapshot.ref.getDownloadURL();

        // Clean up test file
        await testFile.delete();
        // Clean up uploaded test file
        await snapshot.ref.delete();

        return {
          'success': true,
          'download_url': downloadUrl,
          'file_size': testContent.length,
        };
      } else {
        // Clean up test file
        await testFile.delete();

        return {
          'success': false,
          'state': snapshot.state.toString(),
          'error': 'Upload task did not complete successfully',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'error_type': _classifyError(e.toString()),
      };
    }
  }

  static String _classifyError(String errorMessage) {
    if (errorMessage.contains('permission-denied')) {
      return 'PERMISSION_DENIED';
    } else if (errorMessage.contains('object-not-found')) {
      return 'OBJECT_NOT_FOUND';
    } else if (errorMessage.contains('bucket-not-found')) {
      return 'BUCKET_NOT_FOUND';
    } else if (errorMessage.contains('unauthenticated')) {
      return 'UNAUTHENTICATED';
    } else if (errorMessage.contains('network')) {
      return 'NETWORK_ERROR';
    } else if (errorMessage.contains('quota')) {
      return 'QUOTA_EXCEEDED';
    } else {
      return 'UNKNOWN_ERROR';
    }
  }

  // Legacy methods for backward compatibility
  static Future<bool> testStorageConnection() async {
    final result = await runFullDiagnostic();
    return result['success'] ?? false;
  }

  static Future<String?> testUpload(String userId) async {
    try {
      final testContent = 'Test file for catdiff storage - ${DateTime.now()}';
      final tempFile = File('${Directory.systemTemp.path}/test_upload.txt');
      await tempFile.writeAsString(testContent);

      final result = await UploadService.uploadProfileImage(tempFile, userId);

      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      return result;
    } catch (e) {
      print('Upload test failed: $e');
      return null;
    }
  }
}
