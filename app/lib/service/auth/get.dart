import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }
}