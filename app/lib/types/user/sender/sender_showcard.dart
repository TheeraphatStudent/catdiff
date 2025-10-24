// To parse this JSON data, do
//
//     final senderJob = senderJobFromJson(jsonString);

import 'dart:convert';

import 'package:app/types/address/address.dart';

SenderJob senderJobFromJson(String str) => SenderJob.fromJson(json.decode(str));

String senderJobToJson(SenderJob data) => json.encode(data.toJson());

String _parsePickupPkgImage(dynamic value) {
  if (value is String) {
    return value;
  }

  if (value is List && value.isNotEmpty) {
    final first = value.first;
    if (first is String) {
      return first;
    }
  }

  return '';
}

class SenderJob {
  String sendedName;
  String pickupPkgImagesUrl;
  String pickupAddressId;
  String deliveryAddressId;
  String sendedPkgImgUrl;
  String sendedPkgDetail;
  AddressInfo pickupAddress;
  AddressInfo deliveryAddress;

  SenderJob({
    required this.sendedName,
    required this.pickupPkgImagesUrl,
    required this.pickupAddressId,
    required this.deliveryAddressId,
    required this.sendedPkgImgUrl,
    required this.sendedPkgDetail,
    required this.pickupAddress,
    required this.deliveryAddress,
  });

  factory SenderJob.fromJson(Map<String, dynamic> json) => SenderJob(
    sendedName: json["sended_name"],
    pickupPkgImagesUrl: _parsePickupPkgImage(json["pickup_pkg_images_url"]),
    pickupAddressId: json["pickup_address_id"],
    deliveryAddressId: json["delivery_address_id"],
    sendedPkgImgUrl: json["sended_pkg_img_url"],
    sendedPkgDetail: json["sended_pkg_detail"],
    pickupAddress: AddressInfo.fromJson(json["pickup_address"]),
    deliveryAddress: AddressInfo.fromJson(json["delivery_address"]),
  );

  Map<String, dynamic> toJson() => {
    "sended_name": sendedName,
    "pickup_pkg_images_url": pickupPkgImagesUrl,
    "pickup_address_id": pickupAddressId,
    "delivery_address_id": deliveryAddressId,
    "sended_pkg_img_url": sendedPkgImgUrl,
    "sended_pkg_detail": sendedPkgDetail,
    "pickup_address": pickupAddress.toJson(),
    "delivery_address": deliveryAddress.toJson(),
  };
}
