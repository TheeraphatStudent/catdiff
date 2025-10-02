import 'package:app/widget/map/map_destination.dart';

class MapPathSegment {
  const MapPathSegment({required this.target, required this.destination});

  final MapDestination target;
  final MapDestination destination;
}
