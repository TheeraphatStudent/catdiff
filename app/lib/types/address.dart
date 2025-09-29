// To parse this JSON data, do
//
//     final userHome = userHomeFromJson(jsonString);

import 'dart:convert';

UserHome userHomeFromJson(String str) => UserHome.fromJson(json.decode(str));

String userHomeToJson(UserHome data) => json.encode(data.toJson());

class UserHome {
  String addressId;
  double latitude;
  double longtitude;
  String detail;
  String createdAt;
  String updatedAt;

  UserHome({
    required this.addressId,
    required this.latitude,
    required this.longtitude,
    required this.detail,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserHome.fromJson(Map<String, dynamic> json) => UserHome(
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
