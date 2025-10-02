import 'dart:convert';
import 'dart:math' as math;

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class RouteComputationException implements Exception {
  RouteComputationException(this.message, {this.statusCode, this.body});

  final String message;
  final int? statusCode;
  final String? body;

  @override
  String toString() {
    final buffer = StringBuffer('RouteComputationException: ');
    buffer.write(message);
    if (statusCode != null) {
      buffer.write(' (status: ');
      buffer.write(statusCode);
      buffer.write(')');
    }
    return buffer.toString();
  }
}

enum MapRouteTravelMode { driving, walking, bicycling, twoWheeler }

extension MapRouteTravelModeX on MapRouteTravelMode {
  String get apiValue {
    switch (this) {
      case MapRouteTravelMode.driving:
        return 'DRIVE';
      case MapRouteTravelMode.walking:
        return 'WALK';
      case MapRouteTravelMode.bicycling:
        return 'BICYCLE';
      case MapRouteTravelMode.twoWheeler:
        return 'TWO_WHEELER';
    }
  }
}

enum MapRouteRoutingPreference {
  unspecified,
  trafficAware,
  trafficAwareOptimal,
}

extension MapRouteRoutingPreferenceX on MapRouteRoutingPreference {
  String? get apiValue {
    switch (this) {
      case MapRouteRoutingPreference.unspecified:
        return null;
      case MapRouteRoutingPreference.trafficAware:
        return 'TRAFFIC_AWARE';
      case MapRouteRoutingPreference.trafficAwareOptimal:
        return 'TRAFFIC_AWARE_OPTIMAL';
    }
  }
}

enum RouteDistanceSource { routesApi, distanceMatrix, geometry }

class MapRoutesClientConfig {
  const MapRoutesClientConfig({
    this.androidPackageName,
    this.androidCertificateSha1,
    this.iosBundleId,
  });

  const MapRoutesClientConfig.android({
    required this.androidPackageName,
    required this.androidCertificateSha1,
  }) : iosBundleId = null;

  const MapRoutesClientConfig.ios({required this.iosBundleId})
    : androidPackageName = null,
      androidCertificateSha1 = null;

  final String? androidPackageName;
  final String? androidCertificateSha1;
  final String? iosBundleId;
}

enum MapRouteDistanceStrategy {
  routesApiOnly,
  distanceMatrixPreferred,
  localGeometry,
}

class MapRouteResult {
  MapRouteResult({
    required List<LatLng> polyline,
    this.distanceMeters,
    this.duration,
    this.distanceSource = RouteDistanceSource.routesApi,
  }) : polyline = List<LatLng>.unmodifiable(polyline);

  final List<LatLng> polyline;
  final double? distanceMeters;
  final Duration? duration;
  final RouteDistanceSource distanceSource;
}

class MapRoutesService {
  const MapRoutesService();

  static const String _routesEndpoint =
      'https://routes.googleapis.com/directions/v2:computeRoutes';
  static const String _distanceMatrixHost = 'maps.googleapis.com';
  static const String _distanceMatrixPath = '/maps/api/distancematrix/json';

  Future<MapRouteResult> computeRoute({
    required LatLng origin,
    required LatLng destination,
    required String apiKey,
    MapRouteTravelMode travelMode = MapRouteTravelMode.driving,
    List<LatLng> intermediates = const <LatLng>[],
    MapRouteRoutingPreference routingPreference =
        MapRouteRoutingPreference.trafficAware,
    MapRouteDistanceStrategy distanceStrategy =
        MapRouteDistanceStrategy.routesApiOnly,
    bool computeAlternativeRoutes = false,
    MapRoutesClientConfig? clientConfig,
  }) async {
    final Map<String, dynamic> requestBody = <String, dynamic>{
      'origin': _latLngToWaypoint(origin),
      'destination': _latLngToWaypoint(destination),
      'travelMode': travelMode.apiValue,
      'polylineQuality': 'HIGH_QUALITY',
    };

    final String? routingPreferenceValue = routingPreference.apiValue;
    if (routingPreferenceValue != null) {
      requestBody['routingPreference'] = routingPreferenceValue;
    }

    if (intermediates.isNotEmpty) {
      requestBody['intermediates'] = intermediates
          .map(_latLngToWaypoint)
          .toList(growable: false);
    }

    if (computeAlternativeRoutes) {
      requestBody['computeAlternativeRoutes'] = true;
    }

    final bool shouldUseDistanceMatrix =
        distanceStrategy == MapRouteDistanceStrategy.distanceMatrixPreferred &&
        intermediates.isEmpty;
    final bool forceGeometryDistance =
        distanceStrategy == MapRouteDistanceStrategy.localGeometry;

    final Map<String, String> headers = <String, String>{
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': apiKey,
      'X-Goog-FieldMask':
          'routes.distanceMeters,routes.duration,routes.polyline.encodedPolyline,'
          'routes.legs.distanceMeters,routes.legs.duration',
    };

    if (clientConfig?.androidPackageName != null &&
        clientConfig?.androidCertificateSha1 != null) {
      headers['X-Android-Package'] = clientConfig!.androidPackageName!;
      headers['X-Android-Cert'] = clientConfig.androidCertificateSha1!;
    }
    if (clientConfig?.iosBundleId != null) {
      headers['X-Ios-Bundle-Identifier'] = clientConfig!.iosBundleId!;
    }

    final http.Response response = await http.post(
      Uri.parse(_routesEndpoint),
      headers: headers,
      body: jsonEncode(requestBody),
    );

    if (response.statusCode != 200) {
      throw RouteComputationException(
        _extractErrorMessage(response.body) ?? 'Routes API request failed',
        statusCode: response.statusCode,
        body: response.body,
      );
    }

    final dynamic decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw RouteComputationException('Routes API response is invalid');
    }

    final dynamic routesRaw = decoded['routes'];
    if (routesRaw is! List || routesRaw.isEmpty) {
      throw RouteComputationException('No routes returned from Routes API');
    }

    final Map<String, dynamic> route = (routesRaw.first as Map)
        .cast<String, dynamic>();

    final Map<String, dynamic>? polylineData =
        route['polyline'] as Map<String, dynamic>?;
    final String? encodedPolyline = polylineData?['encodedPolyline'] as String?;

    final List<LatLng> polyline =
        encodedPolyline != null && encodedPolyline.isNotEmpty
        ? _decodePolyline(encodedPolyline)
        : <LatLng>[origin, destination];

    double? distanceMeters = _coerceToDouble(route['distanceMeters']);
    Duration? duration = _parseDuration(route['duration'] as String?);

    final List<dynamic>? legsRaw = route['legs'] as List<dynamic>?;
    if (legsRaw != null && legsRaw.isNotEmpty) {
      double legsDistance = 0;
      Duration legsDuration = Duration.zero;
      for (final dynamic leg in legsRaw) {
        if (leg is! Map<String, dynamic>) {
          continue;
        }
        final double? legDistance = _coerceToDouble(leg['distanceMeters']);
        if (legDistance != null) {
          legsDistance += legDistance;
        }
        final Duration? legDuration = _parseDuration(
          leg['duration'] as String?,
        );
        if (legDuration != null) {
          legsDuration += legDuration;
        }
      }
      if (legsDistance > 0 && distanceMeters == null) {
        distanceMeters = legsDistance;
      }
      if (legsDuration > Duration.zero && duration == null) {
        duration = legsDuration;
      }
    }

    RouteDistanceSource distanceSource = distanceMeters != null
        ? RouteDistanceSource.routesApi
        : RouteDistanceSource.geometry;

    if (distanceStrategy == MapRouteDistanceStrategy.distanceMatrixPreferred &&
        shouldUseDistanceMatrix) {
      try {
        final _DistanceMatrixInfo? matrix = await _fetchDistanceMatrix(
          origin: origin,
          destination: destination,
          apiKey: apiKey,
          travelMode: travelMode,
        );
        if (matrix != null) {
          distanceMeters = matrix.distanceMeters ?? distanceMeters;
          duration = matrix.duration ?? duration;
          if (matrix.distanceMeters != null) {
            distanceSource = RouteDistanceSource.distanceMatrix;
          }
        }
      } catch (_) {
        // Swallow Distance Matrix issues; fall back to Routes results.
      }
    }

    if (forceGeometryDistance) {
      distanceMeters = _distanceFromPolyline(polyline);
      distanceSource = RouteDistanceSource.geometry;
    } else if (distanceMeters == null) {
      distanceMeters = _distanceFromPolyline(polyline);
      distanceSource = RouteDistanceSource.geometry;
    }

    return MapRouteResult(
      polyline: polyline,
      distanceMeters: distanceMeters,
      duration: duration,
      distanceSource: distanceSource,
    );
  }

  Future<_DistanceMatrixInfo?> _fetchDistanceMatrix({
    required LatLng origin,
    required LatLng destination,
    required String apiKey,
    required MapRouteTravelMode travelMode,
  }) async {
    final Map<String, String> params = <String, String>{
      'origins': '${origin.latitude},${origin.longitude}',
      'destinations': '${destination.latitude},${destination.longitude}',
      'mode': _distanceMatrixMode(travelMode),
      'key': apiKey,
    };

    final uri = Uri.https(_distanceMatrixHost, _distanceMatrixPath, params);
    final http.Response response = await http.get(uri);
    if (response.statusCode != 200) {
      return null;
    }

    final dynamic decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      return null;
    }

    if ((decoded['status'] as String?) != 'OK') {
      return null;
    }

    final List<dynamic>? rows = decoded['rows'] as List<dynamic>?;
    if (rows == null || rows.isEmpty) {
      return null;
    }
    final Map<String, dynamic>? row = rows.first as Map<String, dynamic>?;
    final List<dynamic>? elements = row?['elements'] as List<dynamic>?;
    if (elements == null || elements.isEmpty) {
      return null;
    }
    final Map<String, dynamic>? element =
        elements.first as Map<String, dynamic>?;
    if (element == null || element['status'] != 'OK') {
      return null;
    }

    final Map<String, dynamic>? distanceData =
        element['distance'] as Map<String, dynamic>?;
    final Map<String, dynamic>? durationData =
        element['duration'] as Map<String, dynamic>?;

    final double? distanceMeters = _coerceToDouble(distanceData?['value']);
    final double? durationSeconds = _coerceToDouble(durationData?['value']);

    return _DistanceMatrixInfo(
      distanceMeters: distanceMeters,
      duration: durationSeconds != null
          ? Duration(milliseconds: (durationSeconds * 1000).round())
          : null,
    );
  }

  static Map<String, dynamic> _latLngToWaypoint(LatLng value) {
    return <String, dynamic>{
      'location': <String, dynamic>{
        'latLng': <String, double>{
          'latitude': value.latitude,
          'longitude': value.longitude,
        },
      },
    };
  }

  static double? _coerceToDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  static Duration? _parseDuration(String? raw) {
    if (raw == null) {
      return null;
    }
    final String normalized = raw.trim();
    if (!normalized.endsWith('s')) {
      return null;
    }
    final double? seconds = double.tryParse(
      normalized.substring(0, normalized.length - 1),
    );
    if (seconds == null) {
      return null;
    }
    return Duration(milliseconds: (seconds * 1000).round());
  }

  static List<LatLng> _decodePolyline(String encoded) {
    final List<LatLng> points = <LatLng>[];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      int result = 0;
      int shift = 0;
      int b;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      final int deltaLat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += deltaLat;

      result = 0;
      shift = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      final int deltaLng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += deltaLng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return points;
  }

  static double _distanceFromPolyline(List<LatLng> points) {
    if (points.length < 2) {
      return 0;
    }
    double total = 0;
    for (var i = 1; i < points.length; i++) {
      total += _haversine(points[i - 1], points[i]);
    }
    return total;
  }

  static double _haversine(LatLng a, LatLng b) {
    const double earthRadius = 6371000; // meters
    final double lat1 = _degToRad(a.latitude);
    final double lon1 = _degToRad(a.longitude);
    final double lat2 = _degToRad(b.latitude);
    final double lon2 = _degToRad(b.longitude);

    final double dLat = lat2 - lat1;
    final double dLon = lon2 - lon1;

    final double sinLat = math.sin(dLat / 2);
    final double sinLon = math.sin(dLon / 2);
    final double aCalc =
        sinLat * sinLat + math.cos(lat1) * math.cos(lat2) * sinLon * sinLon;
    final double c = 2 * math.atan2(math.sqrt(aCalc), math.sqrt(1 - aCalc));
    return earthRadius * c;
  }

  static double _degToRad(double value) => value * math.pi / 180;

  static String _distanceMatrixMode(MapRouteTravelMode mode) {
    switch (mode) {
      case MapRouteTravelMode.walking:
        return 'walking';
      case MapRouteTravelMode.bicycling:
        return 'bicycling';
      case MapRouteTravelMode.twoWheeler:
      case MapRouteTravelMode.driving:
        return 'driving';
    }
  }

  static String? _extractErrorMessage(String? body) {
    if (body == null || body.isEmpty) {
      return null;
    }
    try {
      final dynamic decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final dynamic error = decoded['error'];
        if (error is Map<String, dynamic>) {
          final message = error['message'];
          if (message is String && message.isNotEmpty) {
            return message;
          }
        }
      }
    } catch (_) {
      return null;
    }
    return null;
  }
}

class _DistanceMatrixInfo {
  const _DistanceMatrixInfo({this.distanceMeters, this.duration});

  final double? distanceMeters;
  final Duration? duration;
}
