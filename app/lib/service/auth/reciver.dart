import 'dart:developer';
import 'package:app/service/address/address_service.dart';
import 'package:app/service/helper/firebase_connection.dart';
import 'package:app/types/address/address.dart';
import 'package:app/types/user/reciver/reciver.dart';

class ReciverService {
  static Future<List<ReciverList>> getReciverList([
    String query = '',
    String? excludeUserId,
  ]) async {
    try {
      log(
        'Searching for receivers with query: "$query", excluding user: "$excludeUserId"',
      );

      final response = await FirebaseHelper().getDocumentsQuery(
        collection: 'user',
        where: {'role': 'user'},
      );

      List<ReciverList> receivers = [];

      for (final doc in response) {
        final userData = doc.data()!;
        final String userName = userData['name'] ?? '';

        if (excludeUserId != null && doc.id == excludeUserId) {
          continue;
        }

        if (query.isNotEmpty &&
            !userName.toLowerCase().contains(query.toLowerCase())) {
          continue;
        }

        try {
          final String addressId = userData['address_id'] ?? '';
          AddressInfo address;

          // log("Address: $addressId");

          if (addressId.isNotEmpty) {
            address = await AddressService.getAddressById(addressId);
          } else {
            address = AddressInfo(
              addressId: '',
              latitude: 0.0,
              longtitude: 0.0,
              detail: 'ไม่มีที่อยู่',
              createdAt: '',
              updatedAt: '',
            );
          }

          final receiver = ReciverList(
            userId: doc.id,
            imageUrl: userData['images_url'] ?? '',
            name: userName,
            phoneNumber: userData['phone'] ?? '',
            address: address,
          );

          receivers.add(receiver);
        } catch (addressError) {
          log('Error getting address for user ${doc.id}: $addressError');
          final receiver = ReciverList(
            userId: doc.id,
            imageUrl: userData['images_url'] ?? '',
            name: userName,
            phoneNumber: userData['phone'] ?? '',
            address: AddressInfo(
              addressId: '',
              latitude: 0.0,
              longtitude: 0.0,
              detail: 'ไม่สามารถโหลดที่อยู่ได้',
              createdAt: '',
              updatedAt: '',
            ),
          );
          receivers.add(receiver);
        }
      }

      log('Found ${receivers.length} receivers matching query: "$query"');
      return receivers;
    } catch (error) {
      log('Error in getReciverList: $error');
      throw Exception('Failed to get receiver list: $error');
    }
  }
}
