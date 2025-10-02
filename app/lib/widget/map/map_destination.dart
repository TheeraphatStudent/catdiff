import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapDestination {
  const MapDestination({
    required this.latitude,
    required this.longitude,
    this.label,
    this.markerId,
    this.icon,
  });

  final double latitude;
  final double longitude;
  final String? label;
  final String? markerId;
  final BitmapDescriptor? icon;

  LatLng get latLng => LatLng(latitude, longitude);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is MapDestination &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.label == label &&
        other.markerId == markerId;
  }

  @override
  int get hashCode => Object.hash(latitude, longitude, label, markerId);
}
