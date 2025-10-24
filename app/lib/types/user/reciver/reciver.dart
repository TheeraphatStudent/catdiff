import 'package:app/types/address/address.dart';

class ReciverList {
  String userId;
  String imageUrl;
  String name;
  String phoneNumber;
  AddressInfo address;

  ReciverList({
    required this.userId,
    required this.imageUrl,
    required this.name,
    required this.phoneNumber,
    required this.address,
  });
}
