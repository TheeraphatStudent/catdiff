// To parse this JSON data, do
//
//     final dataRaider = dataRaiderFromJson(jsonString);

import 'dart:convert';

DataRaider dataRaiderFromJson(String str) =>
    DataRaider.fromJson(json.decode(str));

String dataRaiderToJson(DataRaider data) => json.encode(data.toJson());

class DataRaider {
  String imageurl;
  String name;
  String phone;

  DataRaider({required this.imageurl, required this.name, required this.phone});

  factory DataRaider.fromJson(Map<String, dynamic> json) => DataRaider(
    imageurl: json["imageurl"],
    name: json["name"],
    phone: json["phone"],
  );

  Map<String, dynamic> toJson() => {
    "image": imageurl,
    "name": name,
    "phone": phone,
  };
}
