// To parse this JSON data, do
//
//     final delivery = deliveryFromJson(jsonString);

import 'dart:convert';
import 'package:app/types/status.dart';
import 'package:app/types/user/user_auth.dart';

List<Delivery> deliveryFromJson(String str) =>
    List<Delivery>.from(json.decode(str).map((x) => Delivery.fromJson(x)));

String deliveryToJson(List<Delivery> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Delivery {
  String? profileImageUrl;
  String? name;
  StatusType status;

  String deliveryId;
  String sendedId;
  String receivedId;

  String? pickupAddressId;
  String? deliveryAddressId;
  List<String> pickupPkgImagesUrl;

  String? createdAt;
  String updatedAt;

  String? deliveredAt;
  String? pickupAt;

  String? sendedPkgDetail;
  String? sendedPkgImgUrl;

  User? riderInfo;

  Delivery({
    this.profileImageUrl,
    this.name,
    required this.status,
    required this.deliveryId,
    required this.sendedId,
    required this.receivedId,
    this.pickupAddressId,
    this.deliveryAddressId,
    required this.pickupPkgImagesUrl,
    this.createdAt,
    required this.updatedAt,
    this.deliveredAt,
    this.pickupAt,
    required this.sendedPkgDetail,
    required this.sendedPkgImgUrl,
    this.riderInfo,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) => Delivery(
    profileImageUrl: json["profileImageUrl"],
    name: json["name"],
    status: StatusTypes().getStatusTypeEnum(json["status"]),
    deliveryId: json["delivery_id"],
    sendedId: json["sended_id"],
    receivedId: json["receiver_id"],
    pickupAddressId: json["pickup_address_id"],
    deliveryAddressId: json["delivery_address_id"],
    pickupPkgImagesUrl: List<String>.from(
      json["pickup_pkg_images_url"].map((x) => x),
    ),
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
    deliveredAt: json["delivered_at"],
    pickupAt: json["pickup_at"],
    sendedPkgDetail: json["sended_pkg_detail"],
    sendedPkgImgUrl: json["sended_pkg_img_url"],
    riderInfo: json["rider_info"] != null
        ? User.fromJson(json["rider_info"])
        : null,
  );

  Map<String, dynamic> toJson() => {
    "profileImageUrl": profileImageUrl,
    "name": name,
    "status": StatusTypes().getStatusTypeString(status),
    "delivery_id": deliveryId,
    "sended_id": sendedId,
    "receiver_id": receivedId,
    "pickup_address_id": pickupAddressId,
    "delivery_address_id": deliveryAddressId,
    "pickup_pkg_images_url": List<dynamic>.from(
      pickupPkgImagesUrl.map((x) => x),
    ),
    "created_at": createdAt,
    "updated_at": updatedAt,
    "delivered_at": deliveredAt,
    "pickup_at": pickupAt,
    "sended_pkg_detail": sendedPkgDetail,
    "sended_pkg_img_url": sendedPkgImgUrl,
    "rider_info": riderInfo?.toJson(),
  };
}
