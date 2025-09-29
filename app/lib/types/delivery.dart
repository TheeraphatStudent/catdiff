// To parse this JSON data, do
//
//     final delivery = deliveryFromJson(jsonString);

import 'dart:convert';

List<Delivery> deliveryFromJson(String str) =>
    List<Delivery>.from(json.decode(str).map((x) => Delivery.fromJson(x)));

String deliveryToJson(List<Delivery> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Delivery {
  String profileImageUrl;
  String name;
  String status;
  String deliveryId;
  String pickupAddressId;
  String deliveryAddressId;
  List<String> pickupPkgImagesUrl;
  String createdAt;
  String updatedAt;
  dynamic deliveredAt;
  String? pickupAt;
  String sendedPkgDetail;
  String sendedPkgImgUrl;

  Delivery({
    required this.profileImageUrl,
    required this.name,
    required this.status,
    required this.deliveryId,
    required this.pickupAddressId,
    required this.deliveryAddressId,
    required this.pickupPkgImagesUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.deliveredAt,
    required this.pickupAt,
    required this.sendedPkgDetail,
    required this.sendedPkgImgUrl,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) => Delivery(
    profileImageUrl: json["profileImageUrl"],
    name: json["name"],
    status: json["status"],
    deliveryId: json["delivery_id"],
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
  );

  Map<String, dynamic> toJson() => {
    "profileImageUrl": profileImageUrl,
    "name": name,
    "status": status,
    "delivery_id": deliveryId,
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
  };
}
