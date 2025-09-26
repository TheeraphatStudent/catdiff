import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http show get;

// https://maps.googleapis.com/maps/api/geocode/json?latlng=15,100&key=AIzaSyA41Nfgldl3x9OetJGYW71moonj-OkxIv0

class GeolocatorService {
  Future getInfoGeoCode(lat, lon) async {
    return await http.get(
      Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=json',
      ),
    );
  }
}
