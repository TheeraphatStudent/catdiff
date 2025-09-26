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
  String role;
  String addressId;
  Verhicle verhicle;

  User({
    required this.imagesUrl,
    required this.name,
    required this.phone,
    required this.role,
    required this.addressId,
    required this.verhicle,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    imagesUrl: json["images_url"],
    name: json["name"],
    phone: json["phone"],
    role: json["role"],
    addressId: json["address_id"],
    verhicle: Verhicle.fromJson(json["verhicle"]),
  );

  Map<String, dynamic> toJson() => {
    "images_url": imagesUrl,
    "name": name,
    "phone": phone,
    "role": role,
    "address_id": addressId,
    "verhicle": verhicle.toJson(),
  };
}

class Verhicle {
  String driveImageUrl;
  String licencePlate;
  String type;

  Verhicle({
    required this.driveImageUrl,
    required this.licencePlate,
    required this.type,
  });

  factory Verhicle.fromJson(Map<String, dynamic> json) => Verhicle(
    driveImageUrl: json["drive_image_url"],
    licencePlate: json["licence_plate"],
    type: json["type"],
  );

  Map<String, dynamic> toJson() => {
    "drive_image_url": driveImageUrl,
    "licence_plate": licencePlate,
    "type": type,
  };
}
