import 'dart:convert';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class JwtHelper {
  static Map<String, dynamic>? decodeToken(String token) {
    try {
      if (token.isEmpty) {
        return null;
      }

      final jwt = JWT.decode(token);
      return jwt.payload as Map<String, dynamic>;
    } catch (e) {
      // Return null if decoding fails
      return null;
    }
  }

  static Map<String, dynamic>? decodeTokenWithLogging(
    String token, {
    String? context,
  }) {
    try {
      if (token.isEmpty) {
        print('${context ?? 'JWT'}: Token is empty');
        return null;
      }

      final jwt = JWT.decode(token);
      final payload = jwt.payload as Map<String, dynamic>;

      print('${context ?? 'JWT'}: Successfully decoded token');
      return payload;
    } catch (e) {
      print('${context ?? 'JWT'}: Failed to decode token - $e');
      return null;
    }
  }

  static T? extractField<T>(String token, String fieldName) {
    final payload = decodeToken(token);
    if (payload == null) return null;

    final value = payload[fieldName];
    return value is T ? value : null;
  }

  static bool isValidToken(String token) {
    try {
      JWT.decode(token);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Map<String, dynamic>? getHeader(String token) {
    try {
      final jwt = JWT.decode(token);
      return jwt.header as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }
}
