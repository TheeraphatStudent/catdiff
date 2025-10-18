// To parse this JSON data, do
//
//     final geolocatorResponse = geolocatorResponseFromJson(jsonString);

import 'dart:convert';

GeolocatorResponse? geolocatorResponseFromJson(String str) {
  try {
    final dynamic decoded = json.decode(str);
    if (decoded is Map<String, dynamic>) {
      return GeolocatorResponse.fromJson(decoded);
    }
  } catch (_) {
    // caller handles null
  }
  return null;
}

String geolocatorResponseToJson(GeolocatorResponse data) =>
    json.encode(data.toJson());

class GeolocatorResponse {
  GeolocatorResponse({
    this.placeId,
    this.licence,
    this.osmType,
    this.osmId,
    this.lat,
    this.lon,
    this.geolocatorResponseClass,
    this.type,
    this.placeRank,
    this.importance,
    this.addressType,
    this.name,
    this.displayName,
    this.address,
  });

  final int? placeId;
  final String? licence;
  final String? osmType;
  final int? osmId;
  final double? lat;
  final double? lon;
  final String? geolocatorResponseClass;
  final String? type;
  final int? placeRank;
  final double? importance;
  final String? addressType;
  final String? name;
  final String? displayName;
  final Map<String, dynamic>? address;

  factory GeolocatorResponse.fromJson(Map<String, dynamic> json) =>
      GeolocatorResponse(
        placeId: json['place_id'] as int?,
        licence: json['licence'] as String?,
        osmType: json['osm_type'] as String?,
        osmId: json['osm_id'] is int
            ? json['osm_id'] as int
            : int.tryParse(json['osm_id']?.toString() ?? ''),
        lat: _tryParseDouble(json['lat']),
        lon: _tryParseDouble(json['lon']),
        geolocatorResponseClass: json['class'] as String?,
        type: json['type'] as String?,
        placeRank: json['place_rank'] is int
            ? json['place_rank'] as int
            : int.tryParse(json['place_rank']?.toString() ?? ''),
        importance: _tryParseDouble(json['importance']),
        addressType: json['addresstype'] as String?,
        name: json['name'] as String?,
        displayName: json['display_name'] as String?,
        address: json['address'] is Map
            ? Map<String, dynamic>.from(
                json['address'] as Map<dynamic, dynamic>,
              )
            : null,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'place_id': placeId,
    'licence': licence,
    'osm_type': osmType,
    'osm_id': osmId,
    'lat': lat,
    'lon': lon,
    'class': geolocatorResponseClass,
    'type': type,
    'place_rank': placeRank,
    'importance': importance,
    'addresstype': addressType,
    'name': name,
    'display_name': displayName,
    if (address != null) 'address': address,
  };
}

double? _tryParseDouble(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is num) {
    return value.toDouble();
  }
  if (value is String && value.isNotEmpty) {
    return double.tryParse(value);
  }
  return null;
}
