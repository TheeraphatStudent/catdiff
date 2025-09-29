import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:app/config/secret/api_data.dart';
import 'package:app/types/upload.dart';

class ApiUploadService {
  static final String _baseUrl = ApiData().apiUpload;

  /// Upload profile image to API
  static Future<String?> uploadProfileImage(
    File imageFile,
    String userId,
  ) async {
    return _uploadImage(imageFile, userId, 'profile', 'profile_image');
  }

  /// Upload vehicle image to API
  static Future<String?> uploadVehicleImage(
    File imageFile,
    String userId,
  ) async {
    return _uploadImage(imageFile, userId, 'vehicle', 'vehicle_image');
  }

  /// Generic image upload method
  static Future<String?> _uploadImage(
    File imageFile,
    String userId,
    String imageType,
    String fieldName,
  ) async {
    try {
      log('Starting $imageType image upload for user: $userId');

      // Create multipart request
      final uri = Uri.parse("$_baseUrl/upload");
      final request = http.MultipartRequest('POST', uri);

      // Add user ID as form field
      request.fields['user_id'] = userId;
      request.fields['image_type'] = imageType;

      // Add image file
      final fileName =
          '${userId}_${imageType}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final multipartFile = await http.MultipartFile.fromPath(
        fieldName,
        imageFile.path,
        filename: fileName,
      );
      request.files.add(multipartFile);

      log('Sending request to: $_baseUrl');
      log('File: $fileName, Size: ${await imageFile.length()} bytes');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final uploadResponse = uploadResponeFromJson(response.body);

          if (uploadResponse.message.contains('successfully')) {
            final imageUrl = uploadResponse.data.url;
            log('Upload successful! Image URL: $imageUrl');
            log('Filename: ${uploadResponse.data.filename}');
            log('Provider: ${uploadResponse.data.provider}');
            return imageUrl;
          } else {
            log('Upload failed: ${uploadResponse.message}');
            return null;
          }
        } catch (parseError) {
          log('Failed to parse response as UploadRespone: $parseError');
          log('Raw response: ${response.body}');

          try {
            final responseData = json.decode(response.body);
            if (responseData['message'] != null &&
                responseData['message'].toString().contains('successfully')) {
              final imageUrl = responseData['data']?['url'];
              if (imageUrl != null) {
                log('Upload successful (fallback)! Image URL: $imageUrl');
                return imageUrl;
              }
            }
          } catch (fallbackError) {
            log('Fallback parsing also failed: $fallbackError');
          }

          return null;
        }
      } else {
        log('HTTP error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      log('Error uploading $imageType image: $e');
      return null;
    }
  }

  /// Upload multiple images at once (for batch operations)
  static Future<Map<String, String?>> uploadMultipleImages({
    required String userId,
    File? profileImage,
    File? vehicleImage,
  }) async {
    final results = <String, String?>{};

    if (profileImage != null) {
      results['profile'] = await uploadProfileImage(profileImage, userId);
    }

    if (vehicleImage != null) {
      results['vehicle'] = await uploadVehicleImage(vehicleImage, userId);
    }

    return results;
  }

  /// Check if API endpoint is accessible
  static Future<bool> checkApiAccess() async {
    try {
      final uri = Uri.parse(_baseUrl);
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      log('API access check: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      log('API access check failed: $e');
      return false;
    }
  }
}
