import 'package:app/widget/map/map_destination.dart';
import 'package:app/widget/map/map_placeholder.dart';
import 'package:app/widget/sliding_up/sliding_template.dart';
import 'package:flutter/material.dart';

class MapViewerSinglePoint extends StatefulWidget {
  final double lat;
  final double lng;
  final String destLabel;
  final bool isOpened;
  final VoidCallback? onModalClosed;

  const MapViewerSinglePoint({
    super.key,
    required this.lat,
    required this.lng,
    required this.isOpened,
    required this.destLabel,
    this.onModalClosed,
  });

  @override
  State<MapViewerSinglePoint> createState() => _MapViewerSinglePointState();
}

class _MapViewerSinglePointState extends State<MapViewerSinglePoint> {
  @override
  Widget build(BuildContext context) {
    return SlidingTemplate(
      isOpened: widget.isOpened,
      onModalClosed: widget.onModalClosed,
      children: [
        AspectRatio(
          aspectRatio: 1.4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: MapPlaceholder(
              mode: MapPlaceholderMode.viewer,
              viewerType: MapViewerType.single,
              destinations: <MapDestination>[
                MapDestination(
                  latitude: widget.lat,
                  longitude: widget.lng,
                  label: widget.destLabel,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
