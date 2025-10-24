import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http show get;

// https://maps.googleapis.com/maps/api/geocode/json?latlng=15,100&key=AIzaSyAYb0Bt02JhUMszTSW9vEsiKKIDmkTY04Y

class GeolocatorService {
  Future getInfoGeoCode(lat, lon) async {
    // log("Get info code work");

    final uri = Uri.https(
      'nominatim.openstreetmap.org',
      '/reverse',
      <String, String>{'lat': '$lat', 'lon': '$lon', 'format': 'json'},
    );

    return http.get(
      uri,
      headers: <String, String>{
        'User-Agent': 'CatdiffApp/1.0 (contact@catdiff.local)',
        'Accept': 'application/json',
      },
    );
  }
}
