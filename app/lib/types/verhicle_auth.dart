// To parse this JSON data, do
//
//     final dataRaider = dataRaiderFromJson(jsonString);

import 'dart:convert';

DataRaider dataRaiderFromJson(String str) =>
    DataRaider.fromJson(json.decode(str));

String dataRaiderToJson(DataRaider data) => json.encode(data.toJson());

class DataRaider {
  String imageurl;
  String verhicle;
  String licencePlate;
  String type;

  DataRaider({
    required this.imageurl,
    required this.verhicle,
    required this.licencePlate,
    required this.type,
  });

  factory DataRaider.fromJson(Map<String, dynamic> json) => DataRaider(
    imageurl: json["imageurl"],
    verhicle: json["verhicle"],
    licencePlate: json["licence_plate"],
    type: json["type"],
  );

  Map<String, dynamic> toJson() => {
    "imageurl": imageurl,
    "verhicle": verhicle,
    "licence_plate": licencePlate,
    "type": type,
  };
}
