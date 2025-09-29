// To parse this JSON data, do
//
//     final userHome = userHomeFromJson(jsonString);

import 'dart:convert';

UserHome userHomeFromJson(String str) => UserHome.fromJson(json.decode(str));

String userHomeToJson(UserHome data) => json.encode(data.toJson());

class UserHome {
  String raiderId;
  double latitude;
  double longtitude;
  String createdAt;
  String updatedAt;

  UserHome({
    required this.raiderId,
    required this.latitude,
    required this.longtitude,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserHome.fromJson(Map<String, dynamic> json) => UserHome(
    raiderId: json["raider_id"],
    latitude: json["latitude"]?.toDouble(),
    longtitude: json["longtitude"]?.toDouble(),
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "raider_id": raiderId,
    "latitude": latitude,
    "longtitude": longtitude,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}
