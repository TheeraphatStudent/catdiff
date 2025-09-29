import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../upload/post.dart';
import '../../types/user_auth.dart';

class AuthService {
  static Future<AuthResponse?> login(LoginRequest request) async {
    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: request.email,
            password: request.password,
          );

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data()!;
        return AuthResponse.fromJson({
          'userId': userCredential.user!.uid,
          ...data,
        });
      }
      return null;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  static Future<AuthResponse?> register(RegisterRequest request) async {
    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: request.email,
            password: request.password,
          );

      String? imageUrl;
      if (request.profileImage != null) {
        imageUrl = await UploadService.uploadProfileImage(
          request.profileImage!,
          userCredential.user!.uid,
        );
      }

      final userData = {
        'name': request.name,
        'email': request.email,
        'phoneNumber': request.phoneNumber,
        'role': request.role,
        'profileImageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userData);

      return AuthResponse(
        userId: userCredential.user!.uid,
        name: request.name,
        email: request.email,
        phoneNumber: request.phoneNumber,
        profileImageUrl: imageUrl,
        role: request.role,
      );
    } catch (e) {
      print('Register error: $e');
      return null;
    }
  }
}
