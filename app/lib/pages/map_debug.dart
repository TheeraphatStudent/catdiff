import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:app/config/secret/api_data.dart';
import 'package:app/service/map/routes_service.dart';
import 'package:app/widget/map/map_destination.dart';
import 'package:app/widget/map/map_placeholder.dart';
import 'package:app/widget/map/map_route_info.dart';
import 'package:app/widget/map/map_selection_result.dart';

class MapDebugPage extends StatefulWidget {
  const MapDebugPage({super.key});

  @override
  State<MapDebugPage> createState() => _MapDebugPageState();
}

class _MapDebugPageState extends State<MapDebugPage> {
  // ignore: unused_field
  MapSelectionResult? _selectorResult;
  // ignore: unused_field
  MapRouteInfo? _pathRouteInfo;
  MapSelectionResult? _markerTapResult;
  final ApiData _apiData = ApiData();

  // 16.291610, 102.616036
  // ignore: unused_field
  static const LatLng _debugOrigin = LatLng(16.291610, 102.616036);

  // ignore: unused_field
  static const MapDestination _singleDestination = MapDestination(
    latitude: 16.291610,
    longitude: 102.616036,
    label: 'Home',
  );

  // ignore: unused_field
  static const List<MapDestination> _multipleDestinations = <MapDestination>[
    MapDestination(latitude: 16.291610, longitude: 102.616036, label: 'Home'),
    MapDestination(
      latitude: 13.7466,
      longitude: 100.5329,
      label: 'Siam Square',
    ),
    MapDestination(latitude: 13.7204, longitude: 100.4767, label: 'ICONSIAM'),
  ];

  // ignore: unused_field
  static const List<MapDestination> _pathDestinations = <MapDestination>[
    // MapDestination(
    //   latitude: 13.7466,
    //   longitude: 100.5329,
    //   label: 'Siam Square',
    // ),
    MapDestination(
      latitude: 16.291610,
      longitude: 102.615900,
      label: 'Bangkok Old Town',
    ),
  ];

  // ignore: unused_element
  String _formatSelection(MapSelectionResult? result) {
    if (result == null) {
      return 'Tap on the selector map to choose a location.';
    }
    final lat = result.position.latitude.toStringAsFixed(6);
    final lng = result.position.longitude.toStringAsFixed(6);
    final address = result.address;
    if (address == null || address.isEmpty) {
      return 'Selected position: ($lat, $lng)';
    }
    return 'Selected position: ($lat, $lng)\n$address';
  }

  MapRoutesClientConfig? get _routesClientConfig {
    final pkg = _apiData.routesAndroidPackageName.trim();
    final sha1 = _apiData.routesAndroidCertificateSha1.trim();
    if (pkg.isEmpty || sha1.isEmpty) {
      return null;
    }
    return MapRoutesClientConfig.android(
      androidPackageName: pkg,
      androidCertificateSha1: sha1,
    );
  }

  String _formatRouteSummary(MapRouteInfo? info) {
    if (info == null) {
      return 'Route distance: waiting for route...';
    }
    final double meters = info.distanceMeters;
    final String distance = meters < 1000
        ? '${meters.toStringAsFixed(0)} m'
        : '${(meters / 1000).toStringAsFixed(2)} km';
    String source;
    switch (info.distanceSource) {
      case MapRouteDistanceSource.distanceMatrix:
        source = 'Distance Matrix';
        break;
      case MapRouteDistanceSource.api:
        source = 'Routes API';
        break;
      case MapRouteDistanceSource.computed:
        source = 'polyline estimate';
        break;
    }
    final Duration? duration = info.duration;
    final String eta = duration != null
        ? ' | ETA ${_formatDuration(duration)}'
        : '';
    return 'Route distance: $distance ($source)$eta';
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

  String _formatMarkerTap(MapSelectionResult? result) {
    if (result == null) {
      return 'Tap any marker to inspect its location details.';
    }
    final String lat = result.position.latitude.toStringAsFixed(6);
    final String lng = result.position.longitude.toStringAsFixed(6);
    final StringBuffer buffer = StringBuffer('Marker: ($lat, $lng)');
    if (result.address != null && result.address!.isNotEmpty) {
      buffer.write('\n');
      buffer.write(result.address);
    }
    return buffer.toString();
  }

  void _handleMarkerTapped(MapSelectionResult result) {
    log(result.address.toString());
    log(result.position.latitude.toString());
    log(result.position.longitude.toString());

    setState(() {
      _markerTapResult = result;
    });
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map Debug')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // _buildSectionTitle('1. Map view'),
          // AspectRatio(
          //   aspectRatio: 1.4,
          //   child: ClipRRect(
          //     borderRadius: BorderRadius.circular(12),
          //     child: const MapPlaceholder(
          //       mode: MapPlaceholderMode.view,
          //       viewerType: MapViewerType.single,
          //       destinations: <MapDestination>[_singleDestination],
          //     ),
          //   ),
          // ),
          // const SizedBox(height: 16),
          _buildSectionTitle('2. Map selector'),
          AspectRatio(
            aspectRatio: 1.4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: MapPlaceholder(
                mode: MapPlaceholderMode.selector,
                onSelectionChanged: (MapSelectionResult result) {
                  log("Map selector work");
                  log(result.address.toString());
                  log(result.rawGeocode.toString());

                  setState(() {
                    _selectorResult = result;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Text(_formatSelection(_selectorResult)),
          // const SizedBox(height: 16),
          // _buildSectionTitle('3. Map viewer - single point'),
          // AspectRatio(
          //   aspectRatio: 1.4,
          //   child: ClipRRect(
          //     borderRadius: BorderRadius.circular(12),
          //     child: const MapPlaceholder(
          //       mode: MapPlaceholderMode.viewer,
          //       viewerType: MapViewerType.single,
          //       destinations: <MapDestination>[_singleDestination],
          //     ),
          //   ),
          // ),
          // const SizedBox(height: 16),
          _buildSectionTitle('4. Map viewer - multiple points'),
          AspectRatio(
            aspectRatio: 1.4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: MapPlaceholder(
                mode: MapPlaceholderMode.viewer,
                viewerType: MapViewerType.multiple,
                destinations: _multipleDestinations,
                onMarkerTapped: _handleMarkerTapped,
                fetchGeocodeOnMarkerTap: true,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(_formatMarkerTap(_markerTapResult)),
          const SizedBox(height: 16),
          // _buildSectionTitle('5. Map viewer - path finder'),
          // AspectRatio(
          //   aspectRatio: 9 / 16,
          //   child: ClipRRect(
          //     borderRadius: BorderRadius.circular(12),
          //     child: MapPlaceholder(
          //       mode: MapPlaceholderMode.viewer,
          //       viewerType: MapViewerType.path,
          //       destinations: _pathDestinations,
          //       initialPosition: _pathDestinations.first.latLng,
          //       initialUserLocation: _debugOrigin,
          //       showMyLocation: false,
          //       showMyLocationButton: false,
          //       enableLiveLocation: false,
          //       routesApiKey: _apiData.apiKey,
          //       routesClientConfig: _routesClientConfig,
          //       distanceStrategy:
          //           MapRouteDistanceStrategy.distanceMatrixPreferred,
          //       onRouteChanged: (info) {
          //         setState(() {
          //           _pathRouteInfo = info;
          //         });
          //       },
          //     ),
          //   ),
          // ),
          // const SizedBox(height: 8),
          // Text(_formatRouteSummary(_pathRouteInfo)),
          // const SizedBox(height: 24),
        ],
      ),
    );
  }
}
