import 'package:app/types/address/address.dart';
import 'package:app/types/status.dart';

class DeliveryJob {
  String deliveryId;
  StatusType status;

  String pickupPkgImagesUrl;
  String sendedPkgImgUrl = '';
  String? deliveredPkgImgUrl = '';

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
    required this.sendedPkgImgUrl,
    this.deliveredPkgImgUrl = '',
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
    'sended_pkg_img_url': sendedPkgImgUrl,
    'delivered_pkg_img_url': deliveredPkgImgUrl,
  };
}

class UserInfo {
  String userId;
  String name;
  String imagesUrl;

  UserInfo({required this.userId, required this.name, required this.imagesUrl});
}
