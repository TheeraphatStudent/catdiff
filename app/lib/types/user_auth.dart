// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

import 'dart:convert';

User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

class User {
  String imagesUrl;
  String name;
  String phone;
  double latitude;
  double longitude;
  String detail;

  User({
    required this.imagesUrl,
    required this.name,
    required this.phone,
    required this.latitude,
    required this.longitude,
    required this.detail,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    imagesUrl: json["images_url"],
    name: json["name"],
    phone: json["phone"],
    latitude: json["latitude"]?.toDouble(),
    longitude: json["longitude"]?.toDouble(),
    detail: json["detail"],
  );

  Map<String, dynamic> toJson() => {
    "images_url": imagesUrl,
    "name": name,
    "phone": phone,
    "latitude": latitude,
    "longitude": longitude,
    "detail": detail,
  };
}
