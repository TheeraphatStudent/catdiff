// To parse this JSON data, do
//
//     final senderJob = senderJobFromJson(jsonString);

import 'dart:convert';

SenderJob senderJobFromJson(String str) => SenderJob.fromJson(json.decode(str));

String senderJobToJson(SenderJob data) => json.encode(data.toJson());

class SenderJob {
  String deliveryId;
  List<String> pickupPkgImagesUrl;
  String pickupAddressId;
  String deliveryAddressId;
  String sendedPkgImgUrl;
  String sendedPkgDetail;
  Address pickupAddress;
  Address deliveryAddress;

  SenderJob({
    required this.deliveryId,
    required this.pickupPkgImagesUrl,
    required this.pickupAddressId,
    required this.deliveryAddressId,
    required this.sendedPkgImgUrl,
    required this.sendedPkgDetail,
    required this.pickupAddress,
    required this.deliveryAddress,
  });

  factory SenderJob.fromJson(Map<String, dynamic> json) => SenderJob(
    deliveryId: json["delivery_id"],
    pickupPkgImagesUrl: List<String>.from(
      json["pickup_pkg_images_url"].map((x) => x),
    ),
    pickupAddressId: json["pickup_address_id"],
    deliveryAddressId: json["delivery_address_id"],
    sendedPkgImgUrl: json["sended_pkg_img_url"],
    sendedPkgDetail: json["sended_pkg_detail"],
    pickupAddress: Address.fromJson(json["pickup_address"]),
    deliveryAddress: Address.fromJson(json["delivery_address"]),
  );

  Map<String, dynamic> toJson() => {
    "delivery_id": deliveryId,
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

class Address {
  String addressId;
  double latitude;
  double longtitude;
  String detail;
  String createdAt;
  String updatedAt;

  Address({
    required this.addressId,
    required this.latitude,
    required this.longtitude,
    required this.detail,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    addressId: json["address_id"],
    latitude: json["latitude"]?.toDouble(),
    longtitude: json["longtitude"]?.toDouble(),
    detail: json["detail"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "address_id": addressId,
    "latitude": latitude,
    "longtitude": longtitude,
    "detail": detail,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}
