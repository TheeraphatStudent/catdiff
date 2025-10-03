import 'package:app/widget/map/map_destination.dart';

class MapPathSegment {
  const MapPathSegment({required this.target, required this.destination});

  final MapDestination target;
  final MapDestination destination;

  static List<MapPathSegment> fromDestinations(
    List<MapDestination> destinations,
  ) {
    if (destinations.length < 2) {
      return const <MapPathSegment>[];
    }

    final List<MapPathSegment> segments = <MapPathSegment>[];
    for (int i = 0; i < destinations.length - 1; i++) {
      segments.add(
        MapPathSegment(
          target: destinations[i],
          destination: destinations[i + 1],
        ),
      );
    }
    return segments;
  }

  static List<MapPathSegment> fromChains(
    Iterable<List<MapDestination>> chains,
  ) {
    final List<MapPathSegment> segments = <MapPathSegment>[];
    for (final List<MapDestination> chain in chains) {
      segments.addAll(fromDestinations(chain));
    }
    return segments;
  }
}
