import 'package:google_maps_flutter/google_maps_flutter.dart';

enum MapRouteDistanceSource { api, distanceMatrix, computed }

class MapRouteInfo {
  MapRouteInfo({
    required List<LatLng> points,
    required this.distanceMeters,
    this.duration,
    this.distanceSource = MapRouteDistanceSource.api,
  }) : points = List<LatLng>.unmodifiable(points);

  final List<LatLng> points;
  final double distanceMeters;
  final Duration? duration;
  final MapRouteDistanceSource distanceSource;
}
