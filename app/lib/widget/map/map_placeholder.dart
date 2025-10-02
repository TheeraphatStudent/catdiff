import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:app/service/map/geolocator.dart' as map_service;
import 'package:app/service/map/routes_service.dart';
import 'package:app/widget/map/map_destination.dart';
import 'package:app/widget/map/map_route_info.dart';
import 'package:app/widget/map/map_selection_result.dart';

enum MapPlaceholderMode { view, selector, viewer }
/*
view: ดูได้อย่างเดัยว
selector: เลือกจุด
viewer: ดูได้หลายจุด
*/

enum MapViewerType { single, multiple, path }
/*
single: ดูได้จุดเดียว
multiple: ดูได้หลายจุด
path: ดูได้เส้นทาง
*/

class MapPlaceholder extends StatefulWidget {
  const MapPlaceholder({
    super.key,
    this.mode = MapPlaceholderMode.view,
    this.viewerType,
    this.destinations = const <MapDestination>[],
    this.initialPosition,
    this.initialUserLocation,
    this.initialSelection,
    this.initialZoom = 15,
    this.onSelectionChanged,
    this.fetchGeocodeOnSelection = true,
    this.zoomGesturesEnabled = true,
    this.scrollGesturesEnabled = true,
    this.showMyLocation = true,
    this.showMyLocationButton = true,
    this.mapPadding = EdgeInsets.zero,
    this.routesApiKey,
    this.routesClientConfig,
    this.onRouteChanged,
    this.routeTravelMode = MapRouteTravelMode.driving,
    this.distanceStrategy = MapRouteDistanceStrategy.routesApiOnly,
    this.enableLiveLocation = true,
  });

  final MapPlaceholderMode mode;
  final MapViewerType? viewerType;
  final List<MapDestination> destinations;
  final LatLng? initialPosition;
  final LatLng? initialUserLocation;
  final LatLng? initialSelection;
  final double initialZoom;
  final ValueChanged<MapSelectionResult>? onSelectionChanged;
  final bool fetchGeocodeOnSelection;
  final bool zoomGesturesEnabled;
  final bool scrollGesturesEnabled;
  final bool showMyLocation;
  final bool showMyLocationButton;
  final EdgeInsets mapPadding;
  final String? routesApiKey;
  final MapRoutesClientConfig? routesClientConfig;
  final ValueChanged<MapRouteInfo>? onRouteChanged;
  final MapRouteTravelMode routeTravelMode;
  final MapRouteDistanceStrategy distanceStrategy;
  final bool enableLiveLocation;

  @override
  State<MapPlaceholder> createState() => _MapPlaceholderState();
}

class _MapPlaceholderState extends State<MapPlaceholder> {
  static const LatLng _defaultCenter = LatLng(16.2467, 103.2521);

  final map_service.GeolocatorService _geocodeService =
      map_service.GeolocatorService();

  final MapRoutesService _routesService = const MapRoutesService();

  GoogleMapController? _mapController;
  LatLng? _currentLocation;
  LatLng? _selection;

  MapSelectionResult? _selectionResult;

  bool _isLoadingLocation = false;
  bool _isFetchingSelectionDetail = false;
  bool _locationDenied = false;

  List<LatLng> _routePoints = <LatLng>[];
  MapRouteInfo? _routeInfo;
  bool _isFetchingRoute = false;
  String? _routeError;
  int _routeComputationId = 0;

  @override
  void initState() {
    super.initState();
    _selection = widget.initialSelection;
    if (_currentLocation == null &&
        widget.mode == MapPlaceholderMode.viewer &&
        widget.viewerType == MapViewerType.path &&
        widget.initialUserLocation != null) {
      _currentLocation = widget.initialUserLocation;
    }
    if (_initialLocation) {
      _initLocation();
    }
    if (widget.mode == MapPlaceholderMode.viewer &&
        widget.viewerType == MapViewerType.path) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _updateRoute());
    }
  }

  @override
  void didUpdateWidget(MapPlaceholder oldWidget) {
    super.didUpdateWidget(oldWidget);
    final bool destinationsChanged = !_listEquals(
      oldWidget.destinations,
      widget.destinations,
    );
    final bool viewerTypeChanged =
        oldWidget.viewerType != widget.viewerType ||
        oldWidget.mode != widget.mode;

    if (destinationsChanged) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _fitMapToData());
    }
    if (oldWidget.initialSelection != widget.initialSelection &&
        widget.initialSelection != null) {
      _selection = widget.initialSelection;
      WidgetsBinding.instance.addPostFrameCallback((_) => _fitMapToData());
    }
    if (widget.initialUserLocation != oldWidget.initialUserLocation &&
        widget.initialUserLocation != null &&
        (_currentLocation == null ||
            _currentLocation == oldWidget.initialUserLocation)) {
      _currentLocation = widget.initialUserLocation;
    }

    if (widget.mode == MapPlaceholderMode.viewer &&
        widget.viewerType == MapViewerType.path) {
      final bool shouldRefreshRoute =
          destinationsChanged ||
          viewerTypeChanged ||
          oldWidget.routesApiKey != widget.routesApiKey ||
          oldWidget.routeTravelMode != widget.routeTravelMode ||
          oldWidget.initialUserLocation != widget.initialUserLocation ||
          oldWidget.distanceStrategy != widget.distanceStrategy ||
          oldWidget.routesClientConfig != widget.routesClientConfig;
      if (shouldRefreshRoute) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _updateRoute());
      }
    } else if (oldWidget.viewerType == MapViewerType.path &&
        widget.viewerType != MapViewerType.path) {
      if (_routePoints.isNotEmpty ||
          _routeInfo != null ||
          _routeError != null) {
        setState(() {
          _routePoints = <LatLng>[];
          _routeInfo = null;
          _routeError = null;
          _isFetchingRoute = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  bool get _initialLocation {
    if (!widget.enableLiveLocation) {
      return false;
    }
    if (!widget.showMyLocation &&
        widget.mode != MapPlaceholderMode.selector &&
        !(widget.mode == MapPlaceholderMode.viewer &&
            widget.viewerType == MapViewerType.path)) {
      return false;
    }
    return true;
  }

  Future<void> _initLocation() async {
    if (_isLoadingLocation) {
      return;
    }
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final bool permissionGranted = await _grentLocationPermission();
      if (!permissionGranted) {
        setState(() {
          _isLoadingLocation = false;
          _locationDenied = true;
        });
        return;
      }

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      final LatLng current = LatLng(position.latitude, position.longitude);
      setState(() {
        _currentLocation = current;
        _locationDenied = false;
      });

      if (widget.mode == MapPlaceholderMode.selector && _selection == null) {
        unawaited(_handleSelection(current));
      } else {
        _fitMapToData();
      }

      if (widget.mode == MapPlaceholderMode.viewer &&
          widget.viewerType == MapViewerType.path) {
        unawaited(_updateRoute());
      }
    } catch (_) {
      final LatLng? fallback =
          widget.initialUserLocation ?? widget.initialPosition;
      setState(() {
        _locationDenied = true;
        _currentLocation ??= fallback;
      });
      if (widget.mode == MapPlaceholderMode.viewer &&
          widget.viewerType == MapViewerType.path &&
          (_currentLocation ?? fallback) != null) {
        unawaited(_updateRoute());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  Future<bool> _grentLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Future<void> _updateRoute() async {
    if (!mounted ||
        widget.mode != MapPlaceholderMode.viewer ||
        widget.viewerType != MapViewerType.path) {
      return;
    }

    final List<LatLng> destinationPoints = widget.destinations
        .map((e) => e.latLng)
        .toList(growable: false);

    if (destinationPoints.isEmpty) {
      if (_routePoints.isNotEmpty ||
          _routeInfo != null ||
          _routeError != null) {
        setState(() {
          _routePoints = <LatLng>[];
          _routeInfo = null;
          _routeError = null;
          _isFetchingRoute = false;
        });
      }
      return;
    }

    final LatLng? origin =
        _currentLocation ??
        widget.initialUserLocation ??
        widget.initialPosition;
    if (origin == null) {
      return;
    }

    final LatLng destination = destinationPoints.last;
    final List<LatLng> intermediates = destinationPoints.length > 1
        ? destinationPoints.sublist(0, destinationPoints.length - 1)
        : const <LatLng>[];
    final List<LatLng> fallbackWaypoints = _dedupeSequentialPoints(<LatLng>[
      origin,
      ...destinationPoints,
    ]);

    List<LatLng> resolvedPoints = fallbackWaypoints;
    MapRouteInfo resolvedInfo = MapRouteInfo(
      points: resolvedPoints,
      distanceMeters: _computePolylineDistance(resolvedPoints),
      distanceSource: MapRouteDistanceSource.computed,
    );
    String? errorMessage;

    final String? apiKey = widget.routesApiKey;
    if (apiKey == null || apiKey.isEmpty) {
      setState(() {
        _routePoints = resolvedPoints;
        _routeInfo = resolvedInfo;
        _routeError = 'Somethine went wront on _updateRoute';
        _isFetchingRoute = false;
      });
      widget.onRouteChanged?.call(resolvedInfo);
      WidgetsBinding.instance.addPostFrameCallback((_) => _fitMapToData());
      return;
    }

    final int requestId = ++_routeComputationId;

    setState(() {
      _isFetchingRoute = true;
      _routeError = null;
      _routePoints = <LatLng>[];
    });

    try {
      final MapRouteResult result = await _routesService.computeRoute(
        origin: origin,
        destination: destination,
        intermediates: intermediates,
        apiKey: apiKey,
        travelMode: widget.routeTravelMode,
        routingPreference: MapRouteRoutingPreference.trafficAware,
        distanceStrategy: widget.distanceStrategy,
        clientConfig: widget.routesClientConfig,
      );

      resolvedPoints = result.polyline.isNotEmpty
          ? List<LatLng>.from(result.polyline)
          : fallbackWaypoints;

      final double distanceMeters =
          result.distanceMeters ?? _computePolylineDistance(resolvedPoints);

      resolvedInfo = MapRouteInfo(
        points: resolvedPoints,
        distanceMeters: distanceMeters,
        duration: result.duration,
        distanceSource: _mapDistanceSource(result.distanceSource),
      );

      errorMessage = null;
    } on RouteComputationException catch (error) {
      errorMessage = error.message;
      resolvedPoints = fallbackWaypoints;

      resolvedInfo = MapRouteInfo(
        points: resolvedPoints,
        distanceMeters: _computePolylineDistance(resolvedPoints),
        distanceSource: MapRouteDistanceSource.computed,
      );
    } catch (_) {
      errorMessage = 'Unable to compute route';
      resolvedPoints = fallbackWaypoints;

      resolvedInfo = MapRouteInfo(
        points: resolvedPoints,
        distanceMeters: _computePolylineDistance(resolvedPoints),
        distanceSource: MapRouteDistanceSource.computed,
      );
    }

    if (!mounted || requestId != _routeComputationId) {
      return;
    }

    setState(() {
      _routePoints = resolvedPoints;
      _routeInfo = resolvedInfo;
      _routeError = errorMessage;
      _isFetchingRoute = false;
    });

    widget.onRouteChanged?.call(resolvedInfo);
    WidgetsBinding.instance.addPostFrameCallback((_) => _fitMapToData());
  }

  Future<void> _handleSelection(LatLng position) async {
    setState(() {
      _selection = position;
      _selectionResult = MapSelectionResult(position: position);
      _isFetchingSelectionDetail = widget.fetchGeocodeOnSelection;
    });

    if (_mapController != null) {
      //ไม่ต้องรอให้เสร็จ บังคับอัพเดทเลย

      log('_mapController not null -> Animate camera to selection');

      unawaited(
        _mapController!.animateCamera(CameraUpdate.newLatLng(position)),
      );
    }

    MapSelectionResult result = MapSelectionResult(position: position);

    if (widget.fetchGeocodeOnSelection) {
      try {
        final response = await _geocodeService.getInfoGeoCode(
          position.latitude,
          position.longitude,
        );

        if (response.statusCode == 200 && response.body.isNotEmpty) {
          final dynamic decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic>) {
            result = MapSelectionResult(
              position: position,
              address: decoded['display_name'] as String?,
              rawGeocode: decoded,
            );
          }
        }
      } catch (e) {
        log(e.toString());
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _selectionResult = result;
      _isFetchingSelectionDetail = false;
    });

    widget.onSelectionChanged?.call(result);
  }

  void _onRouteOriginDragged(LatLng position) {
    setState(() {
      _currentLocation = position;
    });
    if (_mapController != null) {
      unawaited(
        _mapController!.animateCamera(CameraUpdate.newLatLng(position)),
      );
    }
    unawaited(_updateRoute());
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};

    if (widget.mode == MapPlaceholderMode.selector) {
      final LatLng? markerPosition =
          _selection ?? _currentLocation ?? widget.initialPosition;
      if (markerPosition != null) {
        markers.add(
          Marker(
            markerId: const MarkerId('map_selector'),
            position: markerPosition,
            draggable: true,
            onDragEnd: (value) => _handleSelection(value),
            infoWindow: const InfoWindow(title: 'Selected location'),
          ),
        );
      }
      return markers;
    }

    for (int i = 0; i < widget.destinations.length; i++) {
      final MapDestination destination = widget.destinations[i];
      markers.add(
        Marker(
          markerId: MarkerId(destination.markerId ?? 'dest_$i'),
          position: destination.latLng,
          infoWindow: destination.label != null
              ? InfoWindow(title: destination.label)
              : const InfoWindow(),
          icon: destination.icon ?? BitmapDescriptor.defaultMarker,
        ),
      );
    }

    if (widget.mode == MapPlaceholderMode.viewer &&
        widget.viewerType == MapViewerType.path &&
        _currentLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: _currentLocation!,
          infoWindow: const InfoWindow(title: 'Start location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
          draggable: true,
          onDragEnd: _onRouteOriginDragged,
        ),
      );
    }

    return markers;
  }

  Set<Polyline> _buildPolylines() {
    if (widget.mode != MapPlaceholderMode.viewer ||
        widget.viewerType != MapViewerType.path ||
        _routePoints.length < 2) {
      return <Polyline>{};
    }

    return {
      Polyline(
        polylineId: const PolylineId('path_polyline'),
        color: Colors.blueAccent,
        width: 5,
        points: _routePoints,
      ),
    };
  }

  LatLng _initialCenter() {
    if (widget.initialPosition != null) {
      return widget.initialPosition!;
    }
    if (widget.mode == MapPlaceholderMode.selector) {
      if (_selection != null) {
        return _selection!;
      }
      if (_currentLocation != null) {
        return _currentLocation!;
      }
    }
    if (widget.destinations.isNotEmpty) {
      return widget.destinations.first.latLng;
    }
    if (_currentLocation != null) {
      return _currentLocation!;
    }
    return _defaultCenter;
  }

  Future<void> _fitMapToData() async {
    if (_mapController == null) {
      return;
    }

    final points = <LatLng>[];

    if (widget.mode == MapPlaceholderMode.selector) {
      if (_selection != null) {
        points.add(_selection!);
      } else if (_currentLocation != null) {
        points.add(_currentLocation!);
      }
    } else {
      if (widget.destinations.isNotEmpty) {
        points.addAll(widget.destinations.map((e) => e.latLng));
      }
      if (widget.viewerType == MapViewerType.path && _currentLocation != null) {
        points.add(_currentLocation!);
      }
      if (widget.viewerType == MapViewerType.path && _routePoints.isNotEmpty) {
        points.addAll(_routePoints);
      }
    }

    if (points.isEmpty) {
      return;
    }

    if (points.length == 1) {
      await _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: points.first, zoom: widget.initialZoom),
        ),
      );
      return;
    }

    final bounds = _boundsFromLatLngList(points);
    await _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 64),
    );
  }

  LatLngBounds _boundsFromLatLngList(List<LatLng> points) {
    double? minLat, maxLat, minLng, maxLng;

    for (final LatLng point in points) {
      if (minLat == null) {
        minLat = maxLat = point.latitude;
        minLng = maxLng = point.longitude;
      } else {
        minLat = math.min(minLat, point.latitude);
        maxLat = math.max(maxLat!, point.latitude);
        minLng = math.min(minLng!, point.longitude);
        maxLng = math.max(maxLng!, point.longitude);
      }
    }

    if (minLat == maxLat) {
      minLat = minLat! - 0.0008;
      maxLat = maxLat! + 0.0008;
    }
    if (minLng == maxLng) {
      minLng = minLng! - 0.0008;
      maxLng = maxLng! + 0.0008;
    }

    return LatLngBounds(
      southwest: LatLng(minLat!, minLng!),
      northeast: LatLng(maxLat!, maxLng!),
    );
  }

  double _computePolylineDistance(List<LatLng> points) {
    if (points.length < 2) {
      return 0;
    }
    double total = 0;
    for (var i = 1; i < points.length; i++) {
      total += Geolocator.distanceBetween(
        points[i - 1].latitude,
        points[i - 1].longitude,
        points[i].latitude,
        points[i].longitude,
      );
    }
    return total;
  }

  List<LatLng> _dedupeSequentialPoints(List<LatLng> points) {
    if (points.isEmpty) {
      return <LatLng>[];
    }
    final List<LatLng> output = <LatLng>[points.first];
    for (var i = 1; i < points.length; i++) {
      final LatLng current = points[i];
      final LatLng previous = output.last;
      if (current.latitude != previous.latitude ||
          current.longitude != previous.longitude) {
        output.add(current);
      }
    }
    return output;
  }

  MapRouteDistanceSource _mapDistanceSource(RouteDistanceSource source) {
    switch (source) {
      case RouteDistanceSource.distanceMatrix:
        return MapRouteDistanceSource.distanceMatrix;
      case RouteDistanceSource.routesApi:
        return MapRouteDistanceSource.api;
      case RouteDistanceSource.geometry:
        return MapRouteDistanceSource.computed;
    }
  }

  Widget _buildSelectorOverlay(BuildContext context) {
    final theme = Theme.of(context);
    final LatLng? selection = _selectionResult?.position ?? _selection;
    final String coordinates = selection != null
        ? '${selection.latitude.toStringAsFixed(6)}, '
              '${selection.longitude.toStringAsFixed(6)}'
        : 'Tap on the map to choose a location';

    return Positioned(
      left: 16,
      right: 16,
      bottom: 16,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Selected location', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(coordinates, style: theme.textTheme.bodyMedium),
              if (_isFetchingSelectionDetail) ...[
                const SizedBox(height: 8),
                const LinearProgressIndicator(),
              ] else if (_selectionResult?.address != null) ...[
                const SizedBox(height: 8),
                Text(
                  _selectionResult!.address!,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewerOverlay(BuildContext context) {
    if (widget.destinations.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final Iterable<Widget> rows = widget.destinations.map((destination) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            const Icon(Icons.location_on, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                destination.label ??
                    '${destination.latitude.toStringAsFixed(4)}, '
                        '${destination.longitude.toStringAsFixed(4)}',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      );
    });

    String title = 'Locations';
    if (widget.viewerType == MapViewerType.single) {
      title = 'Destination';
    } else if (widget.viewerType == MapViewerType.path) {
      title = 'Route';
    }

    return Positioned(
      left: 16,
      right: 16,
      bottom: 16,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              ...rows,
              if (widget.viewerType == MapViewerType.path) ...[
                const SizedBox(height: 12),
                if (_isFetchingRoute)
                  Row(
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Calculating route...',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  )
                else if (_routeInfo != null) ...[
                  Text(
                    'Distance: ${_formatDistance(_routeInfo!.distanceMeters)}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  if (_routeInfo!.duration != null)
                    Text(
                      'ETA: ${_formatDuration(_routeInfo!.duration!)}',
                      style: theme.textTheme.bodySmall,
                    ),
                  Text(
                    'Source: ${_distanceSourceLabel(_routeInfo!.distanceSource)}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
                if (_routeError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      _routeError!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                if (!_isFetchingRoute && _routeInfo == null)
                  Text(
                    _currentLocation == null
                        ? 'Waiting for current location... drag the blue marker to set a start.'
                        : 'Drag the blue marker to update the route.',
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    }
    final double kilometers = meters / 1000;
    return kilometers >= 10
        ? '${kilometers.toStringAsFixed(1)} km'
        : '${kilometers.toStringAsFixed(2)} km';
  }

  String _formatDuration(Duration duration) {
    final int hours = duration.inHours;
    final int minutes = duration.inMinutes.remainder(60);
    final int seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      if (minutes > 0) {
        return '${hours}h ${minutes}m';
      }
      return '${hours}h';
    }
    if (minutes > 0) {
      if (seconds > 0) {
        return '${minutes}m ${seconds}s';
      }
      return '${minutes}m';
    }
    return '${seconds}s';
  }

  String _distanceSourceLabel(MapRouteDistanceSource source) {
    switch (source) {
      case MapRouteDistanceSource.distanceMatrix:
        return 'Distance Matrix API';
      case MapRouteDistanceSource.api:
        return 'Routes API response';
      case MapRouteDistanceSource.computed:
        return 'Polyline geometry estimate';
    }
  }

  Widget? _buildStatusBanner() {
    if (_isLoadingLocation) {
      return Positioned(
        top: 16,
        right: 16,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 8),
              Text('Loading location', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      );
    }

    if (_locationDenied) {
      return Positioned(
        top: 16,
        right: 16,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.redAccent.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Location unavailable',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final statusBanner = _buildStatusBanner();

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _initialCenter(),
            zoom: widget.initialZoom,
          ),
          onMapCreated: (controller) {
            _mapController = controller;
            _fitMapToData();
          },
          markers: _buildMarkers(),
          polylines: _buildPolylines(),
          myLocationEnabled:
              widget.showMyLocation &&
              !_locationDenied &&
              _currentLocation != null,
          myLocationButtonEnabled: widget.showMyLocationButton,
          zoomGesturesEnabled: widget.zoomGesturesEnabled,
          scrollGesturesEnabled: widget.scrollGesturesEnabled,
          mapToolbarEnabled: false,
          compassEnabled: true,
          onTap: widget.mode == MapPlaceholderMode.selector
              ? (position) => _handleSelection(position)
              : null,
          padding: widget.mapPadding,
        ),
        if (statusBanner != null) statusBanner,
        if (widget.mode == MapPlaceholderMode.selector)
          _buildSelectorOverlay(context),
        if (widget.mode == MapPlaceholderMode.viewer)
          _buildViewerOverlay(context),
      ],
    );
  }

  bool _listEquals(List<MapDestination> a, List<MapDestination> b) {
    return listEquals<MapDestination>(a, b);
  }
}
