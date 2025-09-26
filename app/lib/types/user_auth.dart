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
  String driveImageUrl;
  String licencePlate;
  String type;

  User({
    required this.imagesUrl,
    required this.name,
    required this.phone,
    required this.latitude,
    required this.longitude,
    required this.detail,
    required this.driveImageUrl,
    required this.licencePlate,
    required this.type,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    imagesUrl: json["images_url"],
    name: json["name"],
    phone: json["phone"],
    latitude: json["latitude"]?.toDouble(),
    longitude: json["longitude"]?.toDouble(),
    detail: json["detail"],
    driveImageUrl: json["drive_image_url"],
    licencePlate: json["licence_plate"],
    type: json["type"],
  );

  Map<String, dynamic> toJson() => {
    "images_url": imagesUrl,
    "name": name,
    "phone": phone,
    "latitude": latitude,
    "longitude": longitude,
    "detail": detail,
    "drive_image_url": driveImageUrl,
    "licence_plate": licencePlate,
    "type": type,
  };
}
