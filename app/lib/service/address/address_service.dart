import 'package:app/types/address.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddressService {
  AddressService._internal();

  static final AddressService instance = AddressService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<AddressInfo> createAddress({
    required double latitude,
    required double longitude,
    required String detail,
  }) async {
    try {
      final DocumentReference<Map<String, dynamic>> docRef = _firestore
          .collection('address')
          .doc();

      final String timestamp = DateTime.now().toIso8601String();

      final Map<String, dynamic> data = <String, dynamic>{
        'latitude': latitude,
        'longtitude': longitude,
        'detail': detail,
        'created_at': timestamp,
        'updated_at': timestamp,
      };

      await docRef.set(data);

      return AddressInfo(
        addressId: docRef.id,
        latitude: latitude,
        longtitude: longitude,
        detail: detail,
        createdAt: timestamp,
        updatedAt: timestamp,
      );
    } catch (error) {
      throw Exception('Failed to create address: $error');
    }
  }
}
