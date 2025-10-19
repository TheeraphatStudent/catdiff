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
      final response = await FirebaseHelper().getDocumentsQuery(
        collection: 'address',
        where: {'id': id},
      );

      final data = response.first.data()!;
      return AddressInfo(
        addressId: response.first.id,
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
}
