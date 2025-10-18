import 'package:app/types/address/address.dart';

class DeliveryJob {
  String deliveryId;
  String status;
  List<String> pickupPkgImagesUrl;
  AddressInfo pickupAddress;
  AddressInfo deliveryAddress;
  UserInfo sender;
  UserInfo reciver;

  DeliveryJob({
    required this.deliveryId,
    required this.status,
    required this.pickupPkgImagesUrl,
    required this.pickupAddress,
    required this.deliveryAddress,
    required this.sender,
    required this.reciver,
  });
}

class UserInfo {
  String userId;
  String name;
  String imagesUrl;

  UserInfo({required this.userId, required this.name, required this.imagesUrl});
}
