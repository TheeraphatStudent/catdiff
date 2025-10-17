// To parse this JSON data, do
//
//     final riderReviewJob = riderReviewJobFromJson(jsonString);

import 'dart:convert';

RiderReviewJob riderReviewJobFromJson(String str) =>
    RiderReviewJob.fromJson(json.decode(str));

String riderReviewJobToJson(RiderReviewJob data) => json.encode(data.toJson());

class RiderReviewJob {
  String deliveryId;
  String status;
  SenderInfo senderInfo;
  ReciverInfo reciverInfo;

  RiderReviewJob({
    required this.deliveryId,
    required this.status,
    required this.senderInfo,
    required this.reciverInfo,
  });

  factory RiderReviewJob.fromJson(Map<String, dynamic> json) => RiderReviewJob(
    deliveryId: json["delivery_id"],
    status: json["status"],
    senderInfo: SenderInfo.fromJson(json["sender_info"]),
    reciverInfo: ReciverInfo.fromJson(json["reciver_info"]),
  );

  Map<String, dynamic> toJson() => {
    "delivery_id": deliveryId,
    "status": status,
    "sender_info": senderInfo.toJson(),
    "reciver_info": reciverInfo.toJson(),
  };
}

class ReciverInfo {
  String imageUrl;
  Address address;

  ReciverInfo({required this.imageUrl, required this.address});

  factory ReciverInfo.fromJson(Map<String, dynamic> json) => ReciverInfo(
    imageUrl: json["image_url"],
    address: Address.fromJson(json["address"]),
  );

  Map<String, dynamic> toJson() => {
    "image_url": imageUrl,
    "address": address.toJson(),
  };
}

class Address {
  String addressesId;
  String detail;
  double latitude;
  double longitude;
  String createdAt;
  String updatedAt;

  Address({
    required this.addressesId,
    required this.detail,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    addressesId: json["addresses_id"],
    detail: json["detail"],
    latitude: json["latitude"]?.toDouble(),
    longitude: json["longitude"]?.toDouble(),
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "addresses_id": addressesId,
    "detail": detail,
    "latitude": latitude,
    "longitude": longitude,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}

class SenderInfo {
  String name;
  String imageUrl;

  SenderInfo({required this.name, required this.imageUrl});

  factory SenderInfo.fromJson(Map<String, dynamic> json) =>
      SenderInfo(name: json["name"], imageUrl: json["image_url"]);

  Map<String, dynamic> toJson() => {"name": name, "image_url": imageUrl};
}
