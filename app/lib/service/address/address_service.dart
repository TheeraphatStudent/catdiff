import 'package:app/service/helper/firebase_connection.dart';
import 'package:app/types/address/address.dart';

class AddressService {
  static Future<AddressInfo> createAddress({
    required double latitude,
    required double longitude,
    required String detail,
  }) async {
    try {
      final String timestamp = DateTime.now().toIso8601String();

      final String documentId = await FirebaseHelper().createDocument(
        collection: 'address',
        data: {
          'latitude': latitude,
          'longtitude': longitude,
          'detail': detail,
          'created_at': timestamp,
          'updated_at': timestamp,
        },
      );

      return AddressInfo(
        addressId: documentId,
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

  static Future<AddressInfo> getAddressById(String id) async {
    try {
      final response = await FirebaseHelper().getDocumentById(
        collection: 'address',
        documentId: id,
      );

      if (!response.exists) {
        throw Exception('Address document not found');
      }

      final data = response.data()!;
      return AddressInfo(
        addressId: response.id,
        latitude: data['latitude']?.toDouble() ?? 0.0,
        longtitude: data['longtitude']?.toDouble() ?? 0.0,
        detail: data['detail'] ?? '',
        createdAt: data['created_at'] ?? '',
        updatedAt: data['updated_at'] ?? '',
      );
    } catch (error) {
      throw Exception('Failed to get address: $error');
    }
  }

  static Future<AddressInfo> updateAddress({
    required String addressId,
    required double latitude,
    required double longitude,
    required String detail,
  }) async {
    try {
      final String timestamp = DateTime.now().toIso8601String();

      await FirebaseHelper().updateDocument(
        collection: 'address',
        documentId: addressId,
        data: {
          'latitude': latitude,
          'longtitude': longitude,
          'detail': detail,
          'updated_at': timestamp,
        },
      );

      return AddressInfo(
        addressId: addressId,
        latitude: latitude,
        longtitude: longitude,
        detail: detail,
        createdAt: '',
        updatedAt: timestamp,
      );
    } catch (error) {
      throw Exception('Failed to update address: $error');
    }
  }

  static Future<bool> deleteAddress(String addressId) async {
    try {
      await FirebaseHelper().deleteDocument(
        collection: 'address',
        documentId: addressId,
      );
      return true;
    } catch (error) {
      throw Exception('Failed to delete address: $error');
    }
  }
}
