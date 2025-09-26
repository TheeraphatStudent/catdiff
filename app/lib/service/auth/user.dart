import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:app/types/role.dart';
import 'package:app/types/user_auth.dart'; // import User และ Verhicle
import 'package:app/types/raider_auth.dart' hide User; // import Raider

class AuthService {
  // Logout
  static Future<void> logout() async {
    await fb.FirebaseAuth.instance.signOut();
  }

  /// สมัครสมาชิก (User / Raider)
  static Future<Map<String, dynamic>> createUser({
    required String user_id, // ใช้เป็น username
    required String phone,
    required String address,
    required String password,
    required UserRole role, // Use UserRole enum instead of string
  }) async {
    try {
      // Format phone number as email for Firebase Auth compatibility
      final phoneEmail =
          "${phone.replaceAll(RegExp(r'[^\d]'), '')}@catdiff.app";

      // สร้าง Firebase Auth user
      final userCredential = await fb.FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: phoneEmail,
            password: password,
          );

      // ข้อมูลพื้นฐาน - different structure for User vs Raider
      final Map<String, dynamic> userData;
      
      if (role == UserRole.rider) {
        // Raider structure: no password, no user_id
        userData = {
          'name': user_id,
          'phone': phone,
          'address_id': address,
          'role': role.name,
          'images_url': '',
          'verhicle': {
            'drive_image_url': '',
            'licence_plate': '',
            'type': '',
          },
          'createdAt': FieldValue.serverTimestamp(),
        };
      } else {
        // User structure: includes password and user_id
        userData = {
          'name': user_id,
          'phone': phone,
          'password': password,
          'address_id': address,
          'role': role.name,
          'images_url': '',
          'verhicle': {
            'drive_image_url': '',
            'licence_plate': '',
            'type': '',
          },
          'createdAt': FieldValue.serverTimestamp(),
        };
      }

      // บันทึกลง Firestore
      final String collectionName = role == UserRole.rider ? 'rider' : 'user';
      await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(userCredential.user!.uid)
          .set(userData);

      // แปลงเป็น object
      final userObject = role == UserRole.rider
          ? Raider.fromJson(userData) // Raider doesn't need user_id
          : User.fromJson({
              ...userData,
              'user_id': userCredential.user!.uid, // User needs user_id
            });

      return {
        'success': true,
        'message': 'สร้าง $role สำเร็จ',
        'userId': userCredential.user!.uid,
        'user': userObject,
      };
    } on fb.FirebaseAuthException catch (e) {
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
      final userCredential = await fb.FirebaseAuth.instance
          .signInWithEmailAndPassword(email: phoneEmail, password: password);

      // ดึงข้อมูลจาก Firestore
      final String collectionName = role == UserRole.rider ? 'rider' : 'user';
      final doc = await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(userCredential.user!.uid)
          .get();

      if (!doc.exists) {
        return {'success': false, 'message': 'ไม่พบข้อมูลผู้ใช้งาน'};
      }

      final userData = doc.data()!;
      final userObject = role == UserRole.rider
          ? Raider.fromJson(userData) // Raider doesn't need user_id
          : User.fromJson({
              ...userData,
              'user_id': userCredential.user!.uid, // User needs user_id
            });

      return {'success': true, 'message': 'ล็อคอินสำเร็จ', 'user': userObject};
    } on fb.FirebaseAuthException catch (e) {
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
}
