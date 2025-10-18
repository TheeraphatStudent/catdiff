// To parse this JSON data, do
//
//     final addressInfo = userHomeFromJson(jsonString);

import 'dart:convert';

AddressInfo addressInfoFromJson(String str) =>
    AddressInfo.fromJson(json.decode(str));

String userHomeToJson(AddressInfo data) => json.encode(data.toJson());

class AddressInfo {
  String addressId;
  double latitude;
  double longtitude;
  String detail;
  String createdAt;
  String updatedAt;

  AddressInfo({
    required this.addressId,
    required this.latitude,
    required this.longtitude,
    required this.detail,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AddressInfo.fromJson(Map<String, dynamic> json) => AddressInfo(
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
