// To parse this JSON data, do
//
//     final senderJob = senderJobFromJson(jsonString);

import 'dart:convert';

import 'package:app/types/address/address.dart';

SenderJob senderJobFromJson(String str) => SenderJob.fromJson(json.decode(str));

String senderJobToJson(SenderJob data) => json.encode(data.toJson());

class SenderJob {
  String sendedName;
  List<String> pickupPkgImagesUrl;
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
    pickupPkgImagesUrl: List<String>.from(
      json["pickup_pkg_images_url"].map((x) => x),
    ),
    pickupAddressId: json["pickup_address_id"],
    deliveryAddressId: json["delivery_address_id"],
    sendedPkgImgUrl: json["sended_pkg_img_url"],
    sendedPkgDetail: json["sended_pkg_detail"],
    pickupAddress: AddressInfo.fromJson(json["pickup_address"]),
    deliveryAddress: AddressInfo.fromJson(json["delivery_address"]),
  );

  Map<String, dynamic> toJson() => {
    "sended_name": sendedName,
    "pickup_pkg_images_url": List<dynamic>.from(
      pickupPkgImagesUrl.map((x) => x),
    ),
    "pickup_address_id": pickupAddressId,
    "delivery_address_id": deliveryAddressId,
    "sended_pkg_img_url": sendedPkgImgUrl,
    "sended_pkg_detail": sendedPkgDetail,
    "pickup_address": pickupAddress.toJson(),
    "delivery_address": deliveryAddress.toJson(),
  };
}
