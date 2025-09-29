import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

class FirebaseHelper {
  // Singleton instance
  static final FirebaseHelper _instance = FirebaseHelper._internal();
  factory FirebaseHelper() => _instance;
  FirebaseHelper._internal();

  // Firebase Auth instance - เชื่อมต่อไปที่ Auth เพื่อยืนยันตัวตน
  fb.FirebaseAuth get _auth => fb.FirebaseAuth.instance;

  // Firebase Firestore instance - เชื่อมตอไปที่ Firebase Database
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  /// ============== Sign out current user ============== 
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// ============== Create user with email and password ============== 
  Future<fb.UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// ============== Sign in with email and password ==============
  Future<fb.UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// ============== Set ==============
  Future<void> setDocument({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection(collection).doc(documentId).set(data);
  }

  /// ============== Get ==============
  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument({
    required String collection,
    required String documentId,
  }) async {
    return await _firestore.collection(collection).doc(documentId).get();
  }

  /// ============== Update ==============
  Future<void> updateDocument({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection(collection).doc(documentId).update(data);
  }

  /// ============== Delete ==============
  Future<void> deleteDocument({
    required String collection,
    required String documentId,
  }) async {
    await _firestore.collection(collection).doc(documentId).delete();
  }

  fb.User? get currentUser => _auth.currentUser;
}