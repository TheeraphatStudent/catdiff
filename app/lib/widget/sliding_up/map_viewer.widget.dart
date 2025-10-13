import 'package:app/widget/map/map_destination.dart';
import 'package:app/widget/map/map_placeholder.dart';
import 'package:app/widget/map/map_selection_result.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Lightweight wrapper around [MapPlaceholder] for read-only map previews.
///
/// Mirrors the behaviour demonstrated in `map_debug.dart` where a single point
/// or multiple points are rendered inside a clipped Google map.
class MapsViewer extends StatelessWidget {
  const MapsViewer({
    super.key,
    required this.destinations,
    this.viewerType,
    this.aspectRatio = 1.4,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.padding,
    this.initialPosition,
    this.mapPadding = EdgeInsets.zero,
    this.zoomGesturesEnabled = true,
    this.scrollGesturesEnabled = true,
    this.showMyLocation = false,
    this.showMyLocationButton = false,
    this.enableLiveLocation = false,
    this.fetchGeocodeOnMarkerTap = false,
    this.onMarkerTapped,
  }) : assert(
          viewerType == null ||
              viewerType == MapViewerType.single ||
              viewerType == MapViewerType.multiple,
          'MapsViewer only supports single or multiple viewer types.',
        );

  /// Destinations to display on the map.
  final List<MapDestination> destinations;

  /// Optional override for the viewer type. When omitted, the widget infers it
  /// from [destinations].
  final MapViewerType? viewerType;

  final double aspectRatio;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? padding;
  final LatLng? initialPosition;
  final EdgeInsets mapPadding;
  final bool zoomGesturesEnabled;
  final bool scrollGesturesEnabled;
  final bool showMyLocation;
  final bool showMyLocationButton;
  final bool enableLiveLocation;
  final bool fetchGeocodeOnMarkerTap;
  final ValueChanged<MapSelectionResult>? onMarkerTapped;

  MapViewerType get _resolvedViewerType {
    if (viewerType != null) {
      return viewerType!;
    }
    return destinations.length <= 1
        ? MapViewerType.single
        : MapViewerType.multiple;
  }

  @override
  Widget build(BuildContext context) {
    final Widget map = ClipRRect(
      borderRadius: borderRadius,
      child: MapPlaceholder(
        mode: MapPlaceholderMode.viewer,
        viewerType: _resolvedViewerType,
        destinations: destinations,
        initialPosition: initialPosition,
        mapPadding: mapPadding,
        zoomGesturesEnabled: zoomGesturesEnabled,
        scrollGesturesEnabled: scrollGesturesEnabled,
        showMyLocation: showMyLocation,
        showMyLocationButton: showMyLocationButton,
        enableLiveLocation: enableLiveLocation,
        fetchGeocodeOnMarkerTap: fetchGeocodeOnMarkerTap,
        onMarkerTapped: onMarkerTapped,
      ),
    );

    final Widget aspectRatioWrapper = AspectRatio(
      aspectRatio: aspectRatio,
      child: map,
    );

    Widget child = aspectRatioWrapper;
    if (padding != null) {
      child = Padding(
        padding: padding!,
        child: aspectRatioWrapper,
      );
    }

    return SliverToBoxAdapter(child: child);
  }
}
