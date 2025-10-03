import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:app/config/secret/api_data.dart';
import 'package:app/service/map/routes_service.dart';
import 'package:app/widget/map/map_destination.dart';
import 'package:app/widget/map/map_path_segment.dart';
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
  MapRouteInfo? _multiRouteInfo;
  MapSelectionResult? _markerTapResult;
  final ApiData _apiData = ApiData();

  late final TextEditingController _multiPathController;
  final FocusNode _multiPathFocusNode = FocusNode();
  bool _suppressMultiPathListener = false;
  String _lastDefaultMultiPathConfig = '';
  String? _multiPathParseError;

  List<List<MapDestination>> _multiPathGroups = <List<MapDestination>>[];
  List<MapPathSegment> _multiPathSegments = <MapPathSegment>[];
  List<MapDestination> _multiPathStops = <MapDestination>[];

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

  static const List<MapPathSegment> _defaultMultiPathSegments =
      <MapPathSegment>[
        MapPathSegment(
          target: MapDestination(
            latitude: 13.7563,
            longitude: 100.5018,
            label: 'Bangkok Old Town',
          ),
          destination: MapDestination(
            latitude: 13.7204,
            longitude: 100.4767,
            label: 'ICONSIAM',
          ),
        ),
        MapPathSegment(
          target: MapDestination(
            latitude: 13.7204,
            longitude: 100.4767,
            label: 'ICONSIAM',
          ),
          destination: MapDestination(
            latitude: 13.7466,
            longitude: 100.5329,
            label: 'Siam Square',
          ),
        ),
      ];

  @override
  void initState() {
    super.initState();
    _multiPathController = TextEditingController();
    _multiPathController.addListener(_handleMultiPathTextChanged);
    _applyDefaultMultiPathConfig(force: true);
  }

  @override
  void dispose() {
    _multiPathController.removeListener(_handleMultiPathTextChanged);
    _multiPathController.dispose();
    _multiPathFocusNode.dispose();
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
    _applyDefaultMultiPathConfig();
  }

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

  void _applyDefaultMultiPathConfig({bool force = false}) {
    final List<List<MapDestination>> chains = _segmentsToChains(
      _defaultMultiPathSegments,
    );
    final String serialized = _serializeChainsToText(chains);
    if (!force && serialized == _lastDefaultMultiPathConfig) {
      return;
    }
    _lastDefaultMultiPathConfig = serialized;
    _setMultiPathControllerText(serialized);
    _applyMultiPathParseResult(_parseMultiPathInput(serialized));
  }

  void _setMultiPathControllerText(String value) {
    _suppressMultiPathListener = true;
    _multiPathController
      ..text = value
      ..selection = TextSelection.collapsed(offset: value.length);
    _suppressMultiPathListener = false;
  }

  void _handleMultiPathTextChanged() {
    if (_suppressMultiPathListener) {
      return;
    }
    _updateMultiPathSegmentsFromText(_multiPathController.text);
  }

  void _updateMultiPathSegmentsFromText(String raw) {
    final _MultiPathParseResult result = _parseMultiPathInput(raw);
    if (result.error != null) {
      setState(() {
        _multiPathParseError = result.error;
      });
      return;
    }

    _applyMultiPathParseResult(result);
  }

  _MultiPathParseResult _parseMultiPathInput(String raw) {
    final List<String> lines = raw.split('\n');
    final List<List<MapDestination>> groups = <List<MapDestination>>[];
    List<MapDestination> currentGroup = <MapDestination>[];
    int lineNumber = 0;
    String? error;

    for (final String entry in lines) {
      lineNumber += 1;
      final String line = entry.trim();
      if (line.isEmpty) {
        if (currentGroup.isNotEmpty) {
          groups.add(currentGroup);
          currentGroup = <MapDestination>[];
        }
        continue;
      }
      if (line.startsWith('#')) {
        continue;
      }

      final List<String> parts = line.split(',');
      if (parts.length < 2) {
        error = 'Line $lineNumber: expected "lat,lng[,label]"';
        break;
      }

      final double? latitude = double.tryParse(parts[0].trim());
      final double? longitude = double.tryParse(parts[1].trim());
      if (latitude == null || longitude == null) {
        error = 'Line $lineNumber: invalid coordinate value';
        break;
      }

      final String labelRaw = parts.length > 2
          ? parts.sublist(2).join(',').trim()
          : '';
      final String? label = labelRaw.isEmpty ? null : labelRaw;

      currentGroup.add(
        MapDestination(latitude: latitude, longitude: longitude, label: label),
      );
    }

    if (error != null) {
      return _MultiPathParseResult(
        groups: groups,
        segments: const <MapPathSegment>[],
        error: error,
      );
    }

    if (currentGroup.isNotEmpty) {
      groups.add(currentGroup);
    }

    final List<MapPathSegment> segments = MapPathSegment.fromChains(groups);

    return _MultiPathParseResult(groups: groups, segments: segments);
  }

  void _applyMultiPathParseResult(_MultiPathParseResult result) {
    setState(() {
      _multiPathParseError = result.error;
      if (result.error != null) {
        _multiPathGroups = <List<MapDestination>>[];
        _multiPathSegments = <MapPathSegment>[];
        _multiPathStops = <MapDestination>[];
      } else {
        _multiPathGroups = result.groups;
        _multiPathSegments = result.segments;
        _multiPathStops = result.flattenedStops;
      }
    });
  }

  List<List<MapDestination>> _segmentsToChains(List<MapPathSegment> segments) {
    if (segments.isEmpty) {
      return <List<MapDestination>>[];
    }

    final List<List<MapDestination>> chains = <List<MapDestination>>[];
    List<MapDestination>? currentChain;
    MapDestination? lastDestination;

    for (final MapPathSegment segment in segments) {
      final MapDestination target = segment.target;
      final MapDestination destination = segment.destination;

      if (currentChain == null ||
          lastDestination == null ||
          target != lastDestination) {
        currentChain = <MapDestination>[target, destination];
        chains.add(currentChain);
      } else {
        currentChain.add(destination);
      }

      lastDestination = destination;
    }

    return chains;
  }

  String _serializeChainsToText(List<List<MapDestination>> chains) {
    if (chains.isEmpty) {
      return '';
    }

    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < chains.length; i++) {
      final List<MapDestination> chain = chains[i];
      for (final MapDestination destination in chain) {
        buffer.writeln(_serializeDestination(destination));
      }
      if (i < chains.length - 1) {
        buffer.writeln();
      }
    }
    return buffer.toString().trimRight();
  }

  String _serializeDestination(MapDestination destination) {
    final StringBuffer buffer = StringBuffer()
      ..write(destination.latitude.toStringAsFixed(6))
      ..write(',')
      ..write(destination.longitude.toStringAsFixed(6));

    if (destination.label != null && destination.label!.isNotEmpty) {
      buffer
        ..write(',')
        ..write(destination.label);
    }

    return buffer.toString();
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
          // _buildSectionTitle('2. Map selector'),
          // AspectRatio(
          //   aspectRatio: 1.4,
          //   child: ClipRRect(
          //     borderRadius: BorderRadius.circular(12),
          //     child: MapPlaceholder(
          //       mode: MapPlaceholderMode.selector,
          //       onSelectionChanged: (MapSelectionResult result) {
          //         setState(() {
          //           _selectorResult = result;
          //         });
          //       },
          //     ),
          //   ),
          // ),
          // const SizedBox(height: 8),
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
          // _buildSectionTitle('4. Map viewer - multiple points'),
          // AspectRatio(
          //   aspectRatio: 1.4,
          //   child: ClipRRect(
          //     borderRadius: BorderRadius.circular(12),
          //     child: const MapPlaceholder(
          //       mode: MapPlaceholderMode.viewer,
          //       viewerType: MapViewerType.multiple,
          //       destinations: _multipleDestinations,
          //     ),
          //   ),
          // ),
          // const SizedBox(height: 16),
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
          const SizedBox(height: 24),
          _buildSectionTitle('6. Map viewer - multi path'),
          _buildMultiPathInput(context),
          AspectRatio(
            aspectRatio: 9 / 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: MapPlaceholder(
                mode: MapPlaceholderMode.viewer,
                viewerType: MapViewerType.multiPath,
                multiPathChains: _multiPathGroups,
                showMyLocation: false,
                showMyLocationButton: false,
                enableLiveLocation: false,
                routesApiKey: _apiData.apiKey,
                routesClientConfig: _routesClientConfig,
                distanceStrategy:
                    MapRouteDistanceStrategy.distanceMatrixPreferred,
                onRouteChanged: (info) {
                  setState(() {
                    _multiRouteInfo = info;
                  });
                },
                onMarkerTapped: _handleMarkerTapped,
                fetchGeocodeOnMarkerTap: true,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(_formatRouteSummary(_multiRouteInfo)),
          const SizedBox(height: 8),
          Text(_formatMarkerTap(_markerTapResult)),
          // const SizedBox(height: 16),
          // _buildCacheStats(),
        ],
      ),
    );
  }

  Widget _buildMultiPathInput(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final String stats = [
      'Chains: ${_multiPathGroups.length}',
      'Stops: ${_multiPathStops.length}',
      'Segments: ${_multiPathSegments.length}',
    ].join(' • ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _multiPathController,
          focusNode: _multiPathFocusNode,
          keyboardType: TextInputType.multiline,
          maxLines: null,
          decoration: InputDecoration(
            labelText: 'Multi-path input',
            hintText: 'lat,lng,label (blank line = new chain)',
            errorText: _multiPathParseError,
            helperText:
                'Enter one stop per line. Routes connect consecutive stops; blank lines split chains.',
          ),
        ),
        const SizedBox(height: 8),
        Text(stats, style: theme.textTheme.bodySmall),
        if (_multiPathParseError != null) ...[
          const SizedBox(height: 4),
          Text(
            _multiPathParseError!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.error,
            ),
          ),
        ],
        const SizedBox(height: 12),
      ],
    );
  }

  // Widget _buildCacheStats() {
  //   final stats = MapRoutesService.getCacheStats();
  //   return Card(
  //     child: Padding(
  //       padding: const EdgeInsets.all(12),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           const Text('Route Cache Stats', style: TextStyle(fontWeight: FontWeight.bold)),
  //           const SizedBox(height: 8),
  //           Text('Cache Size: ${stats['cacheSize']}/${stats['maxCacheSize']}'),
  //           Text('Cache Expiry: ${stats['cacheExpiry']} minutes'),
  //           Text('Has Pending Request: ${stats['hasPendingRequest']}'),
  //           Text('Debug Logging: ${stats['debugLogging']}'),
  //           const SizedBox(height: 8),
  //           Row(
  //             children: [
  //               ElevatedButton(
  //                 onPressed: () {
  //                   MapRoutesService.clearCache();
  //                   setState(() {});
  //                 },
  //                 child: const Text('Clear Cache'),
  //               ),
  //               const SizedBox(width: 8),
  //               ElevatedButton(
  //                 onPressed: () {
  //                   final currentStats = MapRoutesService.getCacheStats();
  //                   final isEnabled = currentStats['debugLogging'] as bool;
  //                   MapRoutesService.setDebugLogging(!isEnabled);
  //                   setState(() {});
  //                 },
  //                 child: Text(stats['debugLogging'] == true ? 'Disable Debug' : 'Enable Debug'),
  //               ),
  //             ],
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}

class _MultiPathParseResult {
  _MultiPathParseResult({
    required this.groups,
    required this.segments,
    this.error,
  });

  final List<List<MapDestination>> groups;
  final List<MapPathSegment> segments;
  final String? error;

  List<MapDestination> get flattenedStops => groups
      .expand((List<MapDestination> chain) => chain)
      .toList(growable: false);
}
