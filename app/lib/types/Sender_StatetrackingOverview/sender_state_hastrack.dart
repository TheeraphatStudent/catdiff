// To parse this JSON data, do
//
//     final homeGame = homeGameFromJson(jsonString);

import 'dart:convert';

HomeGame homeGameFromJson(String str) => HomeGame.fromJson(json.decode(str));

String homeGameToJson(HomeGame data) => json.encode(data.toJson());

class HomeGame {
  String id;
  String title;
  String location;
  String dateTime;
  String phone;

  HomeGame({
    required this.id,
    required this.title,
    required this.location,
    required this.dateTime,
    required this.phone,
  });

  factory HomeGame.fromJson(Map<String, dynamic> json) => HomeGame(
    id: json["id"],
    title: json["title"],
    location: json["location"],
    dateTime: json["dateTime"],
    phone: json["phone"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "location": location,
    "dateTime": dateTime,
    "phone": phone,
  };
}
