// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

import 'dart:convert';

import 'role.dart';

User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

class User {
  String imagesUrl;
  String name;
  String userId;
  String password;
  String phone;
  String addressId;
  UserRole role;
  Verhicle verhicle;

  User({
    required this.imagesUrl,
    required this.name,
    required this.userId,
    required this.password,
    required this.phone,
    required this.addressId,
    required this.role,
    required this.verhicle,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    imagesUrl: json["images_url"],
    name: json["name"],
    userId: json["user_id"],
    password: json["password"],
    phone: json["phone"],
    addressId: json["address_id"],
    role: UserRole.values.firstWhere((e) => e.name == json["role"]),
    verhicle: Verhicle.fromJson(json["verhicle"]),
  );

  Map<String, dynamic> toJson() => {
    "images_url": imagesUrl,
    "name": name,
    "user_id": userId,
    "password": password,
    "phone": phone,
    "address_id": addressId,
    "role": role.name,
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
