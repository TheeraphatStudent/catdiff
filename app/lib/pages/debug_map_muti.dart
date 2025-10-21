import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:app/widget/map/map_destination.dart';
import 'package:app/widget/map/map_placeholder.dart';
import 'package:app/widget/map/map_selection_result.dart';

class MapMulti extends StatefulWidget {
  const MapMulti({super.key});

  @override
  State<MapMulti> createState() => _MapMultiState();
}

class _MapMultiState extends State<MapMulti> {
  MapSelectionResult? _markerTapResult;

  static const List<MapDestination> _multipleDestinations = <MapDestination>[
    MapDestination(latitude: 13.7563, longitude: 100.5018, label: 'Bangkok'),
    MapDestination(latitude: 13.789, longitude: 100.57, label: 'Ladprao'),
    MapDestination(latitude: 13.74, longitude: 100.6, label: 'Rama 9'),
    MapDestination(latitude: 13.81, longitude: 100.55, label: 'Chatuchak'),
  ];

  void _handleMarkerTapped(MapSelectionResult result) {
    log('Marker tapped: ${result.address}');
    log('Lat: ${result.position.latitude}, Lng: ${result.position.longitude}');
    setState(() {
      _markerTapResult = result;
    });
  }

  String _formatMarkerTap(MapSelectionResult? result) {
    if (result == null) return 'Tap any marker to see details.';
    final lat = result.position.latitude.toStringAsFixed(6);
    final lng = result.position.longitude.toStringAsFixed(6);
    return 'Marker tapped:\n($lat, $lng)\n${result.address ?? ''}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
          Text(
            _formatMarkerTap(_markerTapResult),
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
