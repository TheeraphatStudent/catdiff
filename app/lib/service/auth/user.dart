import 'dart:convert';
import 'dart:developer';
import 'package:app/config/share/app_data.dart';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;
import 'package:app/service/helper/firebase_connection.dart';
import 'package:app/types/user/role.dart';
import 'package:app/types/user/user_auth.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class AuthService {
  static String _hashPassword(String password) {
    const salt = 'catdiff_salt';
    final saltedPassword = password + salt;

    final bytes = utf8.encode(saltedPassword);
    final digest = sha256.convert(bytes);

    return digest.toString();
  }

  // Logout
  static Future<void> logout() async {
    try {
      final context = Get.context;
      if (context != null) {
        final appData = Provider.of<AppData>(context, listen: false);
        appData.clearCurrentUser();
        log('AppData cleared successfully');
      }

      await FirebaseHelper().signOut();
      log('User logged out successfully');
    } catch (e) {
      log('Error during logout: $e');
      await FirebaseHelper().signOut();
    }
  }

  static Future<Map<String, dynamic>> createUser({
    required String userId, // ใช้เป็น username
    required String phone,
    required String address,
    required String password,
    required UserRole role, // Use UserRole enum instead of string
    String? profileImageUrl,
    String? vehicleImageUrl,
  }) async {
    try {
      // Format phone number as email for Firebase Auth compatibility
      final phoneEmail =
          "${phone.replaceAll(RegExp(r'[^\d]'), '')}@catdiff.app";

      // สร้าง Firebase Auth user
      final userCredential = await FirebaseHelper()
          .createUserWithEmailAndPassword(
            email: phoneEmail,
            password: password,
          );

      log("User credentiaL: $userCredential");

      // ข้อมูลพื้นฐาน - different structure for User vs Raider
      final Map<String, dynamic> userData;

      if (role == UserRole.rider) {
        userData = {
          'user_id': userCredential.user!.uid,
          'name': userId,
          'phone': phone,
          'address_id': address,
          'role': role.name,
          'images_url': profileImageUrl ?? '',
          'verhicle': {
            'drive_image_url': vehicleImageUrl ?? '',
            'licence_plate': '',
            'type': '',
          },
          'createdAt': FieldValue.serverTimestamp(),
        };
      } else {
        final hashedPassword = _hashPassword(password);

        userData = {
          'user_id': userCredential.user!.uid,
          'name': userId,
          'phone': phone,
          'password': hashedPassword,
          'address_id': address,
          'role': role.name,
          'images_url': profileImageUrl ?? '',
          'verhicle': {
            'drive_image_url': vehicleImageUrl ?? '',
            'licence_plate': '',
            'type': '',
          },
          'createdAt': FieldValue.serverTimestamp(),
        };
      }

      // บันทึกลง Firestore
      final String collectionName = role == UserRole.rider ? 'rider' : 'user';
      await FirebaseHelper().setDocument(
        collection: collectionName,
        documentId: userCredential.user!.uid,
        data: userData,
      );

      // แปลงเป็น object
      final userObject = User.fromJson(userData);

      return {
        'success': true,
        'message': 'สร้าง $role สำเร็จ',
        'userId': userCredential.user!.uid,
        'user': userObject,
      };
    } on FirebaseAuth.FirebaseAuthException catch (e) {
      String message = '';
      switch (e.code) {
        case 'weak-password':
          message = 'รหัสผ่านไม่ปลอดภัย';
          break;
        case 'email-already-in-use':
          message = 'user_id นี้มีผู้ใช้งานแล้ว';
          break;
        case 'invalid-email':
          message = 'รูปแบบข้อมูลไม่ถูกต้อง';
          break;
        default:
          message = 'เกิดข้อผิดพลาด: ${e.message}';
      }
      return {'success': false, 'message': message, 'error': e.code};
    } catch (e) {
      return {
        'success': false,
        'message': 'เกิดข้อผิดพลาดในการเชื่อมต่อ',
        'error': e.toString(),
      };
    }
  }

  /// ล็อคอิน (User / Raider)
  static Future<Map<String, dynamic>> loginUser({
    required String user_id,
    required String password,
    required UserRole role, // Use UserRole enum instead of string
  }) async {
    try {
      // Format phone number as email for Firebase Auth compatibility
      // This is a workaround since full phone auth requires SMS verification
      final phoneEmail =
          "${user_id.replaceAll(RegExp(r'[^\d]'), '')}@catdiff.app";

      // ล็อคอิน Firebase Auth using email/password format
      final userCredential = await FirebaseHelper().signInWithEmailAndPassword(
        email: phoneEmail,
        password: password,
      );

      // ดึงข้อมูลจาก Firestore
      final String collectionName = role == UserRole.rider ? 'rider' : 'user';
      final doc = await FirebaseHelper().getDocumentById(
        collection: collectionName,
        documentId: userCredential.user!.uid,
      );

      if (!doc.exists) {
        return {'success': false, 'message': 'ไม่พบข้อมูลผู้ใช้งาน'};
      }

      final userData = doc.data()!;
      final userObject = User.fromJson(userData);

      return {'success': true, 'message': 'ล็อคอินสำเร็จ', 'user': userObject};
    } on FirebaseAuth.FirebaseAuthException catch (e) {
      String message = '';
      switch (e.code) {
        case 'user-not-found':
          message = 'ไม่พบผู้ใช้งาน';
          break;
        case 'wrong-password':
          message = 'รหัสผ่านไม่ถูกต้อง';
          break;
        default:
          message = 'เกิดข้อผิดพลาด: ${e.message}';
      }
      return {'success': false, 'message': message, 'error': e.code};
    } catch (e) {
      return {
        'success': false,
        'message': 'เกิดข้อผิดพลาดในการเชื่อมต่อ',
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> updateUserProfileById({
    required String userId,
    required String name,
    required String phone,
    String? imagesUrl,
    String? addressId,
  }) async {
    try {
      Map<String, dynamic> updateData = {'name': name, 'phone': phone};

      if (imagesUrl != null) {
        updateData['images_url'] = imagesUrl;
      }
      if (addressId != null) {
        updateData['address_id'] = addressId;
      }

      await FirebaseHelper().updateDocument(
        collection: 'user',
        documentId: userId,
        data: updateData,
      );

      return {'success': true, 'message': 'อัปเดตข้อมูลโปรไฟล์สำเร็จ'};
    } catch (e) {
      return {
        'success': false,
        'message': 'เกิดข้อผิดพลาดในการอัปเดตข้อมูล',
        'error': e.toString(),
      };
    }
  }
}
