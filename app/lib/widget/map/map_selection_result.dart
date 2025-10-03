import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapSelectionResult {
  const MapSelectionResult({
    required this.position,
    this.address,
    this.rawGeocode,
  });

  final LatLng position;
  final String? address;
  final Map<String, dynamic>? rawGeocode;
}
