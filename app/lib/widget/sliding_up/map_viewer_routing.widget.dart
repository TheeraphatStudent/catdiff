import 'package:app/config/secret/api_data.dart';
import 'package:app/service/map/routes_service.dart';
import 'package:app/widget/map/map_destination.dart';
import 'package:app/widget/map/map_placeholder.dart';
import 'package:app/widget/map/map_route_info.dart';
import 'package:app/widget/map/map_selection_result.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Convenience widget for visualising a route between multiple destinations
/// inside a sliding sheet context.
class MapsViewerRouting extends StatefulWidget {
  const MapsViewerRouting({
    super.key,
    required this.destinations,
    this.initialUserLocation,
    this.initialPosition,
    this.aspectRatio = 9 / 16,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.padding,
    this.mapPadding = const EdgeInsets.only(bottom: 164),
    this.showMyLocation = false,
    this.showMyLocationButton = false,
    this.enableLiveLocation = false,
    this.fetchGeocodeOnMarkerTap = false,
    this.onMarkerTapped,
    this.onRouteChanged,
    this.travelMode = MapRouteTravelMode.driving,
    this.distanceStrategy = MapRouteDistanceStrategy.distanceMatrixPreferred,
    this.routesClientConfig,
    this.routesApiKey,
    this.showRouteSummary = true,
  }) : assert(
         destinations.length >= 2,
         'MapsViewerRouting expects at least two destinations to form a path.',
       );

  final List<MapDestination> destinations;
  final LatLng? initialUserLocation;
  final LatLng? initialPosition;
  final double aspectRatio;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsets mapPadding;
  final bool showMyLocation;
  final bool showMyLocationButton;
  final bool enableLiveLocation;
  final bool fetchGeocodeOnMarkerTap;
  final ValueChanged<MapSelectionResult>? onMarkerTapped;
  final ValueChanged<MapRouteInfo>? onRouteChanged;
  final MapRouteTravelMode travelMode;
  final MapRouteDistanceStrategy distanceStrategy;
  final MapRoutesClientConfig? routesClientConfig;
  final String? routesApiKey;
  final bool showRouteSummary;

  @override
  State<MapsViewerRouting> createState() => _MapsViewerRoutingState();
}

class _MapsViewerRoutingState extends State<MapsViewerRouting> {
  MapRouteInfo? _routeInfo;

  late final String _resolvedApiKey;

  @override
  void initState() {
    super.initState();
    _resolvedApiKey = widget.routesApiKey ?? ApiData().apiKey;
  }

  void _handleRouteChanged(MapRouteInfo info) {
    widget.onRouteChanged?.call(info);
    if (!mounted) {
      return;
    }
    setState(() {
      _routeInfo = info;
    });
  }

  Widget _buildRouteSummary(BuildContext context) {
    if (!widget.showRouteSummary || _routeInfo == null) {
      return const SizedBox.shrink();
    }

    final MapRouteInfo info = _routeInfo!;
    final ThemeData theme = Theme.of(context);
    final List<Widget> rows = <Widget>[
      Text(
        'Distance: ${_formatDistance(info.distanceMeters)}',
        style: theme.textTheme.bodyMedium,
      ),
    ];

    if (info.duration != null) {
      rows.add(
        Text(
          'ETA: ${_formatDuration(info.duration!)}',
          style: theme.textTheme.bodySmall,
        ),
      );
    }

    rows.add(
      Text(
        'Source: ${_distanceSourceLabel(info.distanceSource)}',
        style: theme.textTheme.bodySmall,
      ),
    );

    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: rows,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget map = ClipRRect(
      borderRadius: widget.borderRadius,
      child: MapPlaceholder(
        mode: MapPlaceholderMode.viewer,
        viewerType: MapViewerType.path,
        destinations: widget.destinations,
        initialPosition:
            widget.initialPosition ?? widget.destinations.first.latLng,
        initialUserLocation: widget.initialUserLocation,
        mapPadding: widget.mapPadding,
        showMyLocation: widget.showMyLocation,
        showMyLocationButton: widget.showMyLocationButton,
        enableLiveLocation: widget.enableLiveLocation,
        fetchGeocodeOnMarkerTap: widget.fetchGeocodeOnMarkerTap,
        onMarkerTapped: widget.onMarkerTapped,
        routesApiKey: _resolvedApiKey,
        routesClientConfig: widget.routesClientConfig,
        routeTravelMode: widget.travelMode,
        distanceStrategy: widget.distanceStrategy,
        onRouteChanged: _handleRouteChanged,
      ),
    );

    final Widget mapWrapper = AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: map,
    );

    final List<Widget> children = <Widget>[
      mapWrapper,
      _buildRouteSummary(context),
    ];

    final Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );

    Widget child = content;
    if (widget.padding != null) {
      child = Padding(padding: widget.padding!, child: content);
    }

    return SliverToBoxAdapter(child: child);
  }

  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    }
    final double km = meters / 1000;
    return km >= 10
        ? '${km.toStringAsFixed(1)} km'
        : '${km.toStringAsFixed(2)} km';
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
      case MapRouteDistanceSource.api:
        return 'Routes API response';
      case MapRouteDistanceSource.distanceMatrix:
        return 'Distance Matrix API';
      case MapRouteDistanceSource.computed:
        return 'Geodesic estimate';
    }
  }
}
