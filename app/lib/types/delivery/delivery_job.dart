import 'package:app/types/address/address.dart';
import 'package:app/types/status.dart';

class DeliveryJob {
  String deliveryId;
  StatusType status;

  List<String> pickupPkgImagesUrl;
  AddressInfo pickupAddress;
  AddressInfo deliveryAddress;
  String sendedPkgDetail;

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
    required this.sendedPkgDetail,
  });

  Map<String, dynamic> toJson() => {
    'delivery_id': deliveryId,
    'status': status.name,
    'pickup_pkg_images_url': pickupPkgImagesUrl,
    'pickup_address_id': pickupAddress.addressId,
    'delivery_address_id': deliveryAddress.addressId,
    'sended_pkg_detail': sendedPkgDetail,
    'sended_id': sender.userId,
    'received_id': reciver.userId,
    'profileImageUrl': reciver.imagesUrl,
    'name': reciver.name,
  };
}

class UserInfo {
  String userId;
  String name;
  String imagesUrl;

  UserInfo({required this.userId, required this.name, required this.imagesUrl});
}
