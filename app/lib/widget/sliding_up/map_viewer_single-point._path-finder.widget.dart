import 'package:app/config/theme/app_theme.dart';
import 'package:app/service/map/map_service.dart';
import 'package:app/service/map/routes_service.dart';
import 'package:app/widget/map/map_destination.dart';
import 'package:app/widget/map/map_placeholder.dart';
import 'package:app/widget/map/map_route_info.dart';
import 'package:app/widget/sliding_up/sliding_template.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;

enum PathFinderMode { currentToDestination, originToDestination }

class MapViewerSinglePointPathFinder extends StatefulWidget {
  final double? lat;
  final double? lng;
  final String? destLabel;
  final String? label;
  final bool isOpened;

  final double? originLat;
  final double? originLng;
  final String? originLabel;

  final PathFinderMode mode;

  final Duration locationUpdateInterval;

  final VoidCallback? onModalClosed;
  final Function(MapRouteInfo)? getPathRouteInfo;

  final double? aspectRatio;
  final Widget? content;

  const MapViewerSinglePointPathFinder({
    super.key,
    this.aspectRatio = 9 / 16,
    this.content,
    this.lat,
    this.lng,
    this.isOpened = false,
    this.destLabel,
    this.label,
    this.originLat,
    this.originLng,
    this.originLabel,
    this.mode = PathFinderMode.currentToDestination,
    this.locationUpdateInterval = const Duration(seconds: 10),
    this.onModalClosed,
    this.getPathRouteInfo,
  });

  @override
  State<MapViewerSinglePointPathFinder> createState() =>
      _MapViewerSinglePointState();
}

class _MapViewerSinglePointState extends State<MapViewerSinglePointPathFinder> {
  LatLng? _currentLocation;
  LatLng? _originLocation;
  LatLng? _destinationLocation;
  MapDestination _pathDestinations = MapDestination(
    latitude: 0,
    longitude: 0,
    label: 'ปลายทาง',
    markerId: 'destination',
  );
  MapRouteInfo? _pathRouteInfo;
  bool _isLoadingLocation = false;
  Timer? _locationUpdateTimer;
  int _mapRebuildCounter = 0;

  @override
  void initState() {
    super.initState();
    _initializeLocations();
    _startLocationUpdatesIfNeeded();
  }

  @override
  void didUpdateWidget(MapViewerSinglePointPathFinder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lat != widget.lat ||
        oldWidget.lng != widget.lng ||
        oldWidget.originLat != widget.originLat ||
        oldWidget.originLng != widget.originLng ||
        oldWidget.mode != widget.mode) {
      _initializeLocations();
      _restartLocationUpdatesIfNeeded(oldWidget.mode);
    }
  }

  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeLocations() async {
    if (!mounted) return;

    setState(() {
      _isLoadingLocation = true;
    });

    try {
      log("Initializing locations for mode: ${widget.mode}");

      LatLng? destLoc;
      if (widget.lat != null && widget.lng != null) {
        destLoc = LatLng(widget.lat!, widget.lng!);
        log("Destination: ${destLoc.latitude}, ${destLoc.longitude}");
      }

      LatLng? originLoc;
      LatLng? currentLoc;

      if (widget.mode == PathFinderMode.originToDestination) {
        if (widget.originLat != null && widget.originLng != null) {
          originLoc = LatLng(widget.originLat!, widget.originLng!);
          log("Origin (fixed): ${originLoc.latitude}, ${originLoc.longitude}");
        }
      } else {
        currentLoc = await MapService.getCurrentLocation();
        log(
          "Current location: ${currentLoc.latitude}, ${currentLoc.longitude}",
        );
      }

      if (mounted) {
        setState(() {
          _currentLocation = currentLoc;
          _originLocation = originLoc;
          _destinationLocation = destLoc;
          _mapRebuildCounter++;
          _updatePathDestinations();
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      log('Error initializing locations: $e');
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  void _updatePathDestinations() {
    if (widget.mode == PathFinderMode.currentToDestination &&
        _currentLocation != null) {
      _pathDestinations = MapDestination(
        latitude: _currentLocation!.latitude,
        longitude: _currentLocation!.longitude,
        label: 'ตำแหน่งปัจจุบัน',
        markerId: 'current_origin',
      );
    } else if (widget.mode == PathFinderMode.originToDestination &&
        _originLocation != null) {
      _pathDestinations = MapDestination(
        latitude: _originLocation!.latitude,
        longitude: _originLocation!.longitude,
        label: widget.originLabel ?? 'จุดเริ่มต้น',
        markerId: 'origin',
      );
    }

    if (_destinationLocation != null) {
      _pathDestinations = MapDestination(
        latitude: _destinationLocation!.latitude,
        longitude: _destinationLocation!.longitude,
        label: widget.destLabel ?? 'ปลายทาง',
        markerId: 'destination',
      );
    }
  }

  void _startLocationUpdatesIfNeeded() {
    if (widget.mode == PathFinderMode.currentToDestination && widget.isOpened) {
      log(
        "Starting real-time location updates every ${widget.locationUpdateInterval.inSeconds} seconds",
      );
      _locationUpdateTimer = Timer.periodic(widget.locationUpdateInterval, (
        timer,
      ) {
        _updateCurrentLocation();
      });
    }
  }

  void _restartLocationUpdatesIfNeeded(PathFinderMode oldMode) {
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = null;

    if (widget.mode != oldMode) {
      _startLocationUpdatesIfNeeded();
    }
  }

  Future<void> _updateCurrentLocation() async {
    if (!mounted || widget.mode != PathFinderMode.currentToDestination) return;

    try {
      final newLocation = await MapService.getCurrentLocation();
      log(
        "Updated current location: ${newLocation.latitude}, ${newLocation.longitude}",
      );

      if (_currentLocation != null) {
        final distance = _calculateDistance(
          _currentLocation!.latitude,
          _currentLocation!.longitude,
          newLocation.latitude,
          newLocation.longitude,
        );

        if (distance < 10) {
          log(
            "Location change too small (${distance.toStringAsFixed(1)}m), skipping update",
          );
          return;
        }

        log(
          "Location changed by ${distance.toStringAsFixed(1)}m, updating route",
        );
      }

      if (mounted) {
        setState(() {
          _currentLocation = newLocation;
          _mapRebuildCounter++;
          _updatePathDestinations();
        });
      }
    } catch (e) {
      log('Error updating current location: $e');
    }
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371000;
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);
    final double a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  LatLng? get _getOriginLocation {
    if (widget.mode == PathFinderMode.currentToDestination) {
      return _currentLocation;
    } else {
      return _originLocation;
    }
  }

  String _formatDistance(double distanceMeters) {
    if (distanceMeters < 1000) {
      return '${distanceMeters.toInt()} ม.';
    } else {
      return '${(distanceMeters / 1000).toStringAsFixed(1)} กม.';
    }
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return 'ไม่ทราบ';

    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '${hours} ชม. ${minutes} นาที';
    } else {
      return '${minutes} นาที';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlidingTemplate(
      customTopBar: Center(
        child: Text(
          widget.label ?? 'เส้นทางการจัดส่ง',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Mali',
          ),
        ),
      ),
      isOpened: widget.isOpened,
      onModalClosed: widget.onModalClosed,
      children: [
        if (_isLoadingLocation)
          SizedBox(
            height: 200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'กำลังโหลดตำแหน่ง...',
                    style: TextStyle(fontFamily: 'Mali', fontSize: 16),
                  ),
                ],
              ),
            ),
          )
        else
          AspectRatio(
            aspectRatio: widget.aspectRatio ?? 9 / 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: MapPlaceholder(
                key: ValueKey('map_rebuild_$_mapRebuildCounter'),
                mode: MapPlaceholderMode.viewer,
                viewerType: MapViewerType.path,
                destinations: [_pathDestinations],
                initialPosition: _pathDestinations.latLng,
                initialUserLocation:
                    widget.mode == PathFinderMode.currentToDestination
                    ? _currentLocation
                    : null,
                showMyLocation:
                    widget.mode == PathFinderMode.currentToDestination,
                showMyLocationButton:
                    widget.mode == PathFinderMode.currentToDestination,
                enableLiveLocation:
                    widget.mode == PathFinderMode.currentToDestination,
                distanceStrategy:
                    MapRouteDistanceStrategy.distanceMatrixPreferred,
                onRouteChanged: (info) {
                  log(
                    "Route changed - Distance: ${info.distanceMeters}m, Duration: ${info.duration}",
                  );
                  setState(() {
                    _pathRouteInfo = info;

                    widget.getPathRouteInfo?.call(info);
                  });
                },
              ),
            ),
          ),
        if (_pathRouteInfo != null) ...[
          SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary2.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ข้อมูลเส้นทาง',
                    style: TextStyle(
                      fontFamily: 'Mali',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ระยะทาง:',
                        style: TextStyle(fontSize: 12, fontFamily: 'Mali'),
                      ),
                      Text(
                        _formatDistance(_pathRouteInfo!.distanceMeters),
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'Mali',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'เวลาโดยประมาณ:',
                        style: TextStyle(fontSize: 12, fontFamily: 'Mali'),
                      ),
                      Text(
                        _formatDuration(_pathRouteInfo!.duration),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
        widget.content != null ? widget.content! : SizedBox.shrink(),
      ],
    );
  }
}
