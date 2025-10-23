// To parse this JSON data, do
//
//     final userHome = userHomeFromJson(jsonString);

import 'dart:convert';

import 'package:app/types/user/user_auth.dart';

RiderJob riderJobFromJson(String str) => RiderJob.fromJson(json.decode(str));

String riderJobToJson(RiderJob data) => json.encode(data.toJson());

class RiderJob {
  User riderInfo;
  double latitude;
  double longtitude;
  String createdAt;
  String updatedAt;

  RiderJob({
    required this.riderInfo,
    required this.latitude,
    required this.longtitude,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RiderJob.fromJson(Map<String, dynamic> json) => RiderJob(
    riderInfo: json["rider_info"],
    latitude: json["latitude"]?.toDouble(),
    longtitude: json["longtitude"]?.toDouble(),
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "rider_info": riderInfo,
    "latitude": latitude,
    "longtitude": longtitude,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}
