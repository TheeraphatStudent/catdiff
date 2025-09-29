import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:app/config/secret/api_data.dart';
import 'package:app/types/upload.dart';
import 'package:app/service/helper/jwt.dart';

class ApiUploadService {
  static final String _baseUrl = ApiData().apiUpload;

  /// Upload profile image to API
  static Future<String?> uploadProfileImage(
    File imageFile,
    String userId,
  ) async {
    return _uploadImage(imageFile, userId, 'profile');
  }

  /// Upload vehicle image to API
  static Future<String?> uploadVehicleImage(
    File imageFile,
    String userId,
  ) async {
    return _uploadImage(imageFile, userId, 'vehicle');
  }

  /// Generic image upload method
  static Future<String?> _uploadImage(
    File imageFile,
    String userId,
    String imageType,
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
        'file',
        imageFile.path,
        filename: fileName,
      );

      log("Multipart file: $multipartFile");

      request.files.add(multipartFile);

      log('Sending request to: $_baseUrl/upload');
      log('Request headers: ${request.headers}');
      log('Request fields: ${request.fields}');
      log('File: $fileName, Size: ${await imageFile.length()} bytes');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      log('Response status: ${response.statusCode}');
      log('Response headers: ${response.headers}');
      log('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final initialResponse = json.decode(response.body);
          final jwtToken = initialResponse['data'] as String;

          if (jwtToken.isEmpty) {
            log('JWT token is empty in response');
            return null;
          }

          final payload = JwtHelper.decodeTokenWithLogging(jwtToken, context: 'Upload API');

          if (payload == null) {
            log('Failed to decode JWT token');
            return null;
          }

          final uploadResponse = UploadRespone.fromJson(payload);

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
          log('Failed to parse JWT response: $parseError');
          log('Raw response: ${response.body}');

          try {
            final responseData = json.decode(response.body);
            if (responseData['data'] is Map) {
              final uploadResponse = UploadRespone.fromJson(responseData['data']);
              if (uploadResponse.message.contains('successfully')) {
                final imageUrl = uploadResponse.data.url;
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
