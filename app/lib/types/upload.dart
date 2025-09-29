// To parse this JSON data, do
//
//     final uploadRespone = uploadResponeFromJson(jsonString);

import 'dart:convert';

UploadRespone uploadResponeFromJson(String str) => UploadRespone.fromJson(json.decode(str));

String uploadResponeToJson(UploadRespone data) => json.encode(data.toJson());

class UploadRespone {
    String message;
    Data data;

    UploadRespone({
        required this.message,
        required this.data,
    });

    factory UploadRespone.fromJson(Map<String, dynamic> json) => UploadRespone(
        message: json["message"],
        data: Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "message": message,
        "data": data.toJson(),
    };
}

class Data {
    String filename;
    String url;
    String provider;

    Data({
        required this.filename,
        required this.url,
        required this.provider,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        filename: json["filename"],
        url: json["url"],
        provider: json["provider"],
    );

    Map<String, dynamic> toJson() => {
        "filename": filename,
        "url": url,
        "provider": provider,
    };
}
