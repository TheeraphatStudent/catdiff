import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
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

class _RouteCache {
  static const int _maxCacheSize = 50;
  static const Duration _cacheExpiry = Duration(minutes: 10);

  final Map<String, _CachedRoute> _cache = {};

  String _generateKey(
    LatLng origin,
    LatLng destination,
    List<LatLng> intermediates,
    MapRouteTravelMode travelMode,
    MapRouteDistanceStrategy strategy,
  ) {
    final originStr =
        '${origin.latitude.toStringAsFixed(6)},${origin.longitude.toStringAsFixed(6)}';
    final destStr =
        '${destination.latitude.toStringAsFixed(6)},${destination.longitude.toStringAsFixed(6)}';
    final intermediatesStr = intermediates
        .map(
          (p) =>
              '${p.latitude.toStringAsFixed(6)},${p.longitude.toStringAsFixed(6)}',
        )
        .join('|');
    return '$originStr->$destStr|$intermediatesStr|${travelMode.name}|${strategy.name}';
  }

  MapRouteResult? get(String key) {
    final cached = _cache[key];
    if (cached == null) return null;

    if (DateTime.now().difference(cached.timestamp) > _cacheExpiry) {
      _cache.remove(key);
      return null;
    }

    return cached.result;
  }

  void put(String key, MapRouteResult result) {
    if (_cache.length >= _maxCacheSize) {
      // Remove oldest entry
      final oldestKey = _cache.keys.first;
      _cache.remove(oldestKey);
    }

    _cache[key] = _CachedRoute(result, DateTime.now());
  }

  void clear() {
    _cache.clear();
  }
}

class _CachedRoute {
  final MapRouteResult result;
  final DateTime timestamp;

  _CachedRoute(this.result, this.timestamp);
}

class _ThrottleEntry {
  _ThrottleEntry({required this.request, required this.completer});

  Future<MapRouteResult> Function() request;
  final Completer<MapRouteResult> completer;
  late Timer timer;
}

class _RequestThrottler {
  static const Duration _throttleDelay = Duration(milliseconds: 500);

  final Map<String, _ThrottleEntry> _pending = <String, _ThrottleEntry>{};

  Future<MapRouteResult> throttle(
    String key,
    Future<MapRouteResult> Function() request,
  ) {
    final _ThrottleEntry? existing = _pending[key];
    if (existing != null) {
      existing.timer.cancel();
      existing.request = request;
      existing.timer = _createTimer(key, existing);
      return existing.completer.future;
    }

    final Completer<MapRouteResult> completer = Completer<MapRouteResult>();
    final _ThrottleEntry entry = _ThrottleEntry(
      request: request,
      completer: completer,
    );
    entry.timer = _createTimer(key, entry);
    _pending[key] = entry;
    return completer.future;
  }

  Timer _createTimer(String key, _ThrottleEntry entry) {
    return Timer(_throttleDelay, () async {
      try {
        final MapRouteResult result = await entry.request();
        if (!entry.completer.isCompleted) {
          entry.completer.complete(result);
        }
      } catch (error, stackTrace) {
        if (!entry.completer.isCompleted) {
          entry.completer.completeError(error, stackTrace);
        }
      } finally {
        // Only clear the entry if it still maps to this key.
        if (_pending[key] == entry) {
          _pending.remove(key);
        }
      }
    });
  }

  void cancel() {
    final List<_ThrottleEntry> entries = _pending.values.toList();
    _pending.clear();
    for (final _ThrottleEntry entry in entries) {
      entry.timer.cancel();
      if (!entry.completer.isCompleted) {
        entry.completer.completeError(Exception('Request cancelled'));
      }
    }
  }

  bool get hasPending => _pending.isNotEmpty;
}

class MapRoutesService {
  const MapRoutesService();

  static final _RouteCache _cache = _RouteCache();
  static final _RequestThrottler _throttler = _RequestThrottler();
  static bool _debugLogging = false;

  static void _logDebug(String message) {
    if (_debugLogging) {
      debugPrint('[MapRoutesService] $message');
    }
  }

  static const String _routesEndpoint =
      'https://routes.googleapis.com/directions/v2:computeRoutes';
  static const String _distanceMatrixHost = 'maps.googleapis.com';
  static const String _distanceMatrixPath = '/maps/api/distancematrix/json';
  static const String _directionsPath = '/maps/api/directions/json';

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
    final cacheKey = _cache._generateKey(
      origin,
      destination,
      intermediates,
      travelMode,
      distanceStrategy,
    );

    final cachedResult = _cache.get(cacheKey);
    if (cachedResult != null) {
      return cachedResult;
    }

    return _throttler.throttle(
      cacheKey,
      () => _performRouteRequest(
        origin: origin,
        destination: destination,
        apiKey: apiKey,
        travelMode: travelMode,
        intermediates: intermediates,
        routingPreference: routingPreference,
        distanceStrategy: distanceStrategy,
        computeAlternativeRoutes: computeAlternativeRoutes,
        clientConfig: clientConfig,
        cacheKey: cacheKey,
      ),
    );
  }

  Future<MapRouteResult> _performRouteRequest({
    required LatLng origin,
    required LatLng destination,
    required String apiKey,
    required MapRouteTravelMode travelMode,
    required List<LatLng> intermediates,
    required MapRouteRoutingPreference routingPreference,
    required MapRouteDistanceStrategy distanceStrategy,
    required bool computeAlternativeRoutes,
    required MapRoutesClientConfig? clientConfig,
    required String cacheKey,
  }) async {
    try {
      return await _performRoutesApiRequest(
        origin: origin,
        destination: destination,
        apiKey: apiKey,
        travelMode: travelMode,
        intermediates: intermediates,
        routingPreference: routingPreference,
        distanceStrategy: distanceStrategy,
        computeAlternativeRoutes: computeAlternativeRoutes,
        clientConfig: clientConfig,
        cacheKey: cacheKey,
      );
    } on RouteComputationException catch (e) {
      if (_debugLogging) {
        _logDebug(
          'Routes API request failed (status: ${e.statusCode ?? 'unknown'}): ${e.message}',
        );
      }
      return await _performFallbackRoute(
        origin: origin,
        destination: destination,
        apiKey: apiKey,
        travelMode: travelMode,
        intermediates: intermediates,
        distanceStrategy: distanceStrategy,
        cacheKey: cacheKey,
        cause: e,
      );
    }
  }

  Future<MapRouteResult> _performRoutesApiRequest({
    required LatLng origin,
    required LatLng destination,
    required String apiKey,
    required MapRouteTravelMode travelMode,
    required List<LatLng> intermediates,
    required MapRouteRoutingPreference routingPreference,
    required MapRouteDistanceStrategy distanceStrategy,
    required bool computeAlternativeRoutes,
    required MapRoutesClientConfig? clientConfig,
    required String cacheKey,
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

    // Debug logging
    if (_debugLogging) {
      _logDebug('Routes API Request: ${jsonEncode(requestBody)}');
      _logDebug('Routes API Response Status: ${response.statusCode}');
      _logDebug('Routes API Response Body: ${response.body}');
    }

    if (response.statusCode != 200) {
      final errorMessage =
          _extractErrorMessage(response.body) ?? 'Routes API request failed';

      // Check for specific Android client blocking error
      if (response.body.contains('blocked') ||
          response.body.contains('BLOCKED')) {
        if (_debugLogging) {
          _logDebug(
            'WARNING: Android client blocked - API key may need Android app restrictions configured',
          );
        }
        // For now, we'll throw the error but could implement a fallback here
      }

      throw RouteComputationException(
        errorMessage,
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

    // Debug polyline data
    if (_debugLogging) {
      _logDebug('Polyline data: $polylineData');
      _logDebug('Encoded polyline: $encodedPolyline');
      _logDebug('Encoded polyline length: ${encodedPolyline?.length ?? 0}');
    }

    final List<LatLng> polyline =
        encodedPolyline != null && encodedPolyline.isNotEmpty
        ? _decodePolyline(encodedPolyline)
        : <LatLng>[origin, destination];

    if (_debugLogging) {
      _logDebug('Decoded polyline points: ${polyline.length}');
      if (polyline.length <= 2) {
        _logDebug('WARNING: Using fallback polyline (straight line)');
      }
    }

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

    final result = MapRouteResult(
      polyline: polyline,
      distanceMeters: distanceMeters,
      duration: duration,
      distanceSource: distanceSource,
    );

    // Cache the result
    _cache.put(cacheKey, result);

    return result;
  }

  Future<MapRouteResult> _performFallbackRoute({
    required LatLng origin,
    required LatLng destination,
    required String apiKey,
    required MapRouteTravelMode travelMode,
    required List<LatLng> intermediates,
    required MapRouteDistanceStrategy distanceStrategy,
    required String cacheKey,
    RouteComputationException? cause,
  }) async {
    if (_debugLogging) {
      final String reason = cause != null && cause.message.isNotEmpty
          ? ' (reason: ${cause.message})'
          : '';
      _logDebug('Using fallback route calculation$reason');
    }

    _DirectionsRouteInfo? directions;
    try {
      directions = await _fetchDirectionsRoute(
        origin: origin,
        destination: destination,
        intermediates: intermediates,
        apiKey: apiKey,
        travelMode: travelMode,
      );
      if (_debugLogging && directions != null) {
        _logDebug(
          'Directions API fallback succeeded with ${directions.polyline.length} points',
        );
      }
    } catch (e) {
      if (_debugLogging) {
        _logDebug('Directions API fallback failed: $e');
      }
    }

    final List<LatLng> interpolated = _createInterpolatedPolyline([
      origin,
      ...intermediates,
      destination,
    ]);

    List<LatLng> polyline = directions != null && directions.polyline.isNotEmpty
        ? directions.polyline
        : interpolated;
    double? distanceMeters = directions?.distanceMeters;
    Duration? duration = directions?.duration;
    RouteDistanceSource distanceSource = directions != null
        ? RouteDistanceSource.routesApi
        : RouteDistanceSource.geometry;

    if (distanceStrategy == MapRouteDistanceStrategy.localGeometry) {
      distanceMeters = _distanceFromPolyline(polyline);
      distanceSource = RouteDistanceSource.geometry;
      duration = null;
    } else if (distanceStrategy ==
        MapRouteDistanceStrategy.distanceMatrixPreferred) {
      try {
        final _DistanceMatrixInfo? matrix = await _fetchDistanceMatrix(
          origin: origin,
          destination: destination,
          apiKey: apiKey,
          travelMode: travelMode,
        );
        if (matrix != null) {
          if (matrix.distanceMeters != null) {
            distanceMeters = matrix.distanceMeters;
            distanceSource = RouteDistanceSource.distanceMatrix;
          }
          duration ??= matrix.duration;
        }
      } catch (e) {
        if (_debugLogging) {
          _logDebug('Distance Matrix API also failed: $e');
        }
      }
    }

    if (distanceMeters == null) {
      distanceMeters = _distanceFromPolyline(polyline);
      if (distanceSource != RouteDistanceSource.distanceMatrix) {
        distanceSource = RouteDistanceSource.geometry;
      }
    }

    final result = MapRouteResult(
      polyline: polyline,
      distanceMeters: distanceMeters,
      duration: duration,
      distanceSource: distanceSource,
    );

    _cache.put(cacheKey, result);

    return result;
  }

  Future<_DirectionsRouteInfo?> _fetchDirectionsRoute({
    required LatLng origin,
    required LatLng destination,
    required List<LatLng> intermediates,
    required String apiKey,
    required MapRouteTravelMode travelMode,
  }) async {
    final Map<String, String> params = <String, String>{
      'origin': '${origin.latitude},${origin.longitude}',
      'destination': '${destination.latitude},${destination.longitude}',
      'key': apiKey,
      'mode': _directionsMode(travelMode),
    };

    if (intermediates.isNotEmpty) {
      params['waypoints'] = intermediates
          .map((point) => '${point.latitude},${point.longitude}')
          .join('|');
    }

    final Uri uri = Uri.https(_distanceMatrixHost, _directionsPath, params);
    final http.Response response = await http.get(uri);
    if (response.statusCode != 200) {
      return null;
    }

    final dynamic decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      return null;
    }

    final String? status = decoded['status'] as String?;
    if (status != 'OK') {
      if (_debugLogging) {
        final String? message = decoded['error_message'] as String?;
        final String suffix = message != null ? ': $message' : '';
        _logDebug('Directions API status $status$suffix');
      }
      return null;
    }

    final List<dynamic>? routes = decoded['routes'] as List<dynamic>?;
    if (routes == null || routes.isEmpty) {
      return null;
    }

    final Map<String, dynamic>? route = routes.first as Map<String, dynamic>?;
    if (route == null) {
      return null;
    }

    final Map<String, dynamic>? overview =
        route['overview_polyline'] as Map<String, dynamic>?;
    final String? encoded = overview?['points'] as String?;
    final List<LatLng> polyline = encoded != null && encoded.isNotEmpty
        ? _decodePolyline(encoded)
        : <LatLng>[];

    double? totalDistance;
    Duration? totalDuration;
    final List<dynamic>? legs = route['legs'] as List<dynamic>?;
    if (legs != null && legs.isNotEmpty) {
      double distanceAccumulator = 0;
      double durationAccumulator = 0;
      for (final dynamic leg in legs) {
        if (leg is! Map<String, dynamic>) {
          continue;
        }
        final Map<String, dynamic>? distanceData =
            leg['distance'] as Map<String, dynamic>?;
        final Map<String, dynamic>? durationData =
            leg['duration'] as Map<String, dynamic>?;
        final double? legDistance = _coerceToDouble(distanceData?['value']);
        final double? legDurationSeconds = _coerceToDouble(
          durationData?['value'],
        );
        if (legDistance != null) {
          distanceAccumulator += legDistance;
        }
        if (legDurationSeconds != null) {
          durationAccumulator += legDurationSeconds;
        }
      }
      if (distanceAccumulator > 0) {
        totalDistance = distanceAccumulator;
      }
      if (durationAccumulator > 0) {
        totalDuration = Duration(
          milliseconds: (durationAccumulator * 1000).round(),
        );
      }
    }

    return _DirectionsRouteInfo(
      polyline: polyline,
      distanceMeters: totalDistance,
      duration: totalDuration,
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

  static List<LatLng> _createInterpolatedPolyline(List<LatLng> waypoints) {
    if (waypoints.length < 2) return waypoints;

    final List<LatLng> interpolated = [];

    for (int i = 0; i < waypoints.length - 1; i++) {
      final LatLng start = waypoints[i];
      final LatLng end = waypoints[i + 1];

      interpolated.add(start);

      // Add intermediate points for longer segments
      final double distance = _calculateDistance(start, end);
      if (distance > 1000) {
        // If segment is longer than 1km, add intermediate points
        final int segments = (distance / 500).ceil(); // One point every 500m
        for (int j = 1; j < segments; j++) {
          final double ratio = j / segments;
          final double lat =
              start.latitude + (end.latitude - start.latitude) * ratio;
          final double lng =
              start.longitude + (end.longitude - start.longitude) * ratio;
          interpolated.add(LatLng(lat, lng));
        }
      }
    }

    // Add the final waypoint
    interpolated.add(waypoints.last);

    return interpolated;
  }

  static double _calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371000; // Earth's radius in meters
    final double lat1Rad = point1.latitude * (math.pi / 180);
    final double lat2Rad = point2.latitude * (math.pi / 180);
    final double deltaLatRad =
        (point2.latitude - point1.latitude) * (math.pi / 180);
    final double deltaLngRad =
        (point2.longitude - point1.longitude) * (math.pi / 180);

    final double a =
        math.sin(deltaLatRad / 2) * math.sin(deltaLatRad / 2) +
        math.cos(lat1Rad) *
            math.cos(lat2Rad) *
            math.sin(deltaLngRad / 2) *
            math.sin(deltaLngRad / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
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

  static String _directionsMode(MapRouteTravelMode mode) {
    switch (mode) {
      case MapRouteTravelMode.walking:
        return 'walking';
      case MapRouteTravelMode.bicycling:
        return 'bicycling';
      case MapRouteTravelMode.twoWheeler:
        return 'driving';
      case MapRouteTravelMode.driving:
        return 'driving';
    }
  }

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

  static void clearCache() {
    _cache.clear();
  }

  /// Get cache statistics for debugging
  static Map<String, dynamic> getCacheStats() {
    return {
      'cacheSize': _cache._cache.length,
      'maxCacheSize': _RouteCache._maxCacheSize,
      'cacheExpiry': _RouteCache._cacheExpiry.inMinutes,
      'hasPendingRequest': _throttler.hasPending,
      'debugLogging': _debugLogging,
    };
  }

  /// Enable or disable debug logging
  static void setDebugLogging(bool enabled) {
    _debugLogging = enabled;
  }
}

class _DirectionsRouteInfo {
  const _DirectionsRouteInfo({
    required this.polyline,
    this.distanceMeters,
    this.duration,
  });

  final List<LatLng> polyline;
  final double? distanceMeters;
  final Duration? duration;
}

class _DistanceMatrixInfo {
  const _DistanceMatrixInfo({this.distanceMeters, this.duration});
  final double? distanceMeters;
  final Duration? duration;
}
