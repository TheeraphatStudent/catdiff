import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http show get;

// https://maps.googleapis.com/maps/api/geocode/json?latlng=15,100&key=AIzaSyCK3UAtqWx2NprxrJoLh0n5gDw3G_DpNdk

class GeolocatorService {
  Future getInfoGeoCode(lat, lon) async {
    return await http.get(Uri.parse('https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=json'));

  }

}