import 'package:latlong2/latlong.dart' as latlng;

class MapDistanceService {
  MapDistanceService._();

  static const latlng.Distance _distance = latlng.Distance();

  static double straightLine(latlng.LatLng origin, latlng.LatLng destination) {
    return _distance.as(latlng.LengthUnit.Meter, origin, destination);
  }

  static double straightLineFromCoords(
    double originLat,
    double originLng,
    double destinationLat,
    double destinationLng,
  ) {
    return straightLine(
      latlng.LatLng(originLat, originLng),
      latlng.LatLng(destinationLat, destinationLng),
    );
  }
}
