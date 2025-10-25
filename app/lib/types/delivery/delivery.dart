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
  String pickupPkgImagesUrl;
  String? deliveredPkgImgUrl;

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
    this.deliveredPkgImgUrl,
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
    profileImageUrl: json["profileImageUrl"] as String?,
    name: json["name"] as String?,
    status: StatusTypes().getStatusTypeEnum((json["status"] as String?) ?? ''),
    deliveryId: (json["delivery_id"] as String?) ?? '',
    sendedId: (json["sended_id"] as String?) ?? '',
    receivedId: (json["received_id"] as String?) ?? '',
    pickupAddressId: json["pickup_address_id"] as String?,
    deliveryAddressId: json["delivery_address_id"] as String?,
    pickupPkgImagesUrl: (json["pickup_pkg_images_url"] as String?) ?? '',
    deliveredPkgImgUrl: json["delivered_pkg_img_url"] as String?,
    createdAt: json["created_at"] as String?,
    updatedAt:
        (json["updated_at"] as String?) ?? DateTime.now().toIso8601String(),
    deliveredAt: json["delivered_at"] as String?,
    pickupAt: json["pickup_at"] as String?,
    sendedPkgDetail: (json["sended_pkg_detail"] as String?) ?? '',
    sendedPkgImgUrl: (json["sended_pkg_img_url"] as String?) ?? '',
    riderInfo: json["rider_info"] is Map<String, dynamic>
        ? User.fromJson(json["rider_info"] as Map<String, dynamic>)
        : null,
  );

  Map<String, dynamic> toJson() => {
    "profileImageUrl": profileImageUrl,
    "name": name,
    "status": StatusTypes().getStatusTypeString(status),
    "delivery_id": deliveryId,
    "sended_id": sendedId,
    "received_id": receivedId,
    "pickup_address_id": pickupAddressId,
    "delivery_address_id": deliveryAddressId,
    "pickup_pkg_images_url": pickupPkgImagesUrl,
    "created_at": createdAt,
    "updated_at": updatedAt,
    "delivered_at": deliveredAt,
    "pickup_at": pickupAt,
    "sended_pkg_detail": sendedPkgDetail,
    "sended_pkg_img_url": sendedPkgImgUrl,
    "rider_info": riderInfo?.toJson(),
  };
}
