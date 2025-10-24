import 'package:app/config/theme/app_theme.dart';
import 'package:app/service/delivery/rider_job.dart';
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

import 'package:latlong2/latlong.dart' as latlng;

enum PathFinderMode { currentToDestination, originToDestination }

class MapViewerSinglePointPathFinder extends StatefulWidget {
  final double? lat;
  final double? lng;
  final String? destLabel;
  final String? label;
  final bool isOpened;
  final bool isShowingDetail;
  final String? deliveryId;
  final bool trackRiderLocation;

  final double? originLat;
  final double? originLng;
  final String? originLabel;

  final PathFinderMode mode;

  final Duration locationUpdateInterval;
  final double locationUpdateDistance;

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
    this.isShowingDetail = true,
    this.deliveryId,
    this.trackRiderLocation = false,
    this.destLabel,
    this.label,
    this.originLat,
    this.originLng,
    this.originLabel,
    this.mode = PathFinderMode.currentToDestination,
    this.locationUpdateInterval = const Duration(seconds: 10),
    this.locationUpdateDistance = 5,
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
  StreamSubscription<LatLng>? _locationSubscription;
  final latlng.Distance _distanceCalculator = const latlng.Distance();
  bool _isRiderLocationActive = false;

  bool get _isCurrentToDestination =>
      widget.mode == PathFinderMode.currentToDestination;

  bool get _shouldUseRiderTracking =>
      _isCurrentToDestination &&
      widget.trackRiderLocation &&
      (widget.deliveryId?.isNotEmpty ?? false);

  bool get _shouldUseDeviceLocationFeatures =>
      _isCurrentToDestination && !_isRiderLocationActive;

  @override
  void initState() {
    super.initState();
    _initializeLocations();
    _startLocationUpdatesIfNeeded();
  }

  @override
  void didUpdateWidget(MapViewerSinglePointPathFinder oldWidget) {
    super.didUpdateWidget(oldWidget);
    final hasDestinationChanged =
        oldWidget.lat != widget.lat ||
        oldWidget.lng != widget.lng ||
        oldWidget.originLat != widget.originLat ||
        oldWidget.originLng != widget.originLng;

    final hasModeChanged = oldWidget.mode != widget.mode;
    final hasOpenedStateChanged = oldWidget.isOpened != widget.isOpened;
    final hasIntervalChanged =
        oldWidget.locationUpdateInterval != widget.locationUpdateInterval;
    final hasDistanceChanged =
        oldWidget.locationUpdateDistance != widget.locationUpdateDistance;
    final hasTrackingFlagChanged =
        oldWidget.trackRiderLocation != widget.trackRiderLocation;
    final hasDeliveryChanged = oldWidget.deliveryId != widget.deliveryId;

    final shouldReinitializeLocations =
        hasDestinationChanged ||
        (hasOpenedStateChanged && widget.isOpened) ||
        hasModeChanged ||
        hasTrackingFlagChanged ||
        hasDeliveryChanged;

    if (shouldReinitializeLocations) {
      if (!widget.trackRiderLocation && _isRiderLocationActive) {
        _isRiderLocationActive = false;
      }
      _initializeLocations();
    }

    if (hasDestinationChanged ||
        hasModeChanged ||
        hasOpenedStateChanged ||
        hasIntervalChanged ||
        hasDistanceChanged ||
        hasTrackingFlagChanged ||
        hasDeliveryChanged) {
      _stopLocationUpdates();
    }

    _startLocationUpdatesIfNeeded();
  }

  @override
  void dispose() {
    _stopLocationUpdates();
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
      bool riderLocationActive = false;

      if (_shouldUseRiderTracking) {
        log(
          "Attempting to initialize rider location for delivery ${widget.deliveryId}",
        );
      }

      if (widget.mode == PathFinderMode.originToDestination) {
        if (widget.originLat != null && widget.originLng != null) {
          originLoc = LatLng(widget.originLat!, widget.originLng!);
          log("Origin (fixed): ${originLoc.latitude}, ${originLoc.longitude}");
        }
      } else {
        if (_shouldUseRiderTracking) {
          final riderLocation = await DeliveryRiderJob.getRiderLocationOnJob(
            widget.deliveryId!,
          );
          if (riderLocation != null) {
            currentLoc = LatLng(
              riderLocation.latitude,
              riderLocation.longitude,
            );
            riderLocationActive = true;
            log(
              "Initialized rider location: ${currentLoc.latitude}, ${currentLoc.longitude}",
            );
          } else {
            log(
              "Rider location not yet available for ${widget.deliveryId}, using device location until updates arrive",
            );
          }
        }

        currentLoc ??= await MapService.getCurrentLocation();
        if (currentLoc != null) {
          log(
            "Current origin location: ${currentLoc.latitude}, ${currentLoc.longitude}",
          );
        }
      }

      if (mounted) {
        setState(() {
          _currentLocation = currentLoc;
          _originLocation = originLoc;
          _destinationLocation = destLoc;
          _isRiderLocationActive = riderLocationActive;
          _updatePathDestinations();
          _pathRouteInfo = null;
          _isLoadingLocation = false;
        });

        _updateManualRouteInfo();
      }
    } catch (e) {
      log('Error initializing locations: $e');
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
          if (!_shouldUseRiderTracking) {
            _isRiderLocationActive = false;
          }
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
    final bool shouldStart = _isCurrentToDestination && widget.isOpened;

    if (!shouldStart || _locationSubscription != null) {
      return;
    }

    if (_shouldUseRiderTracking) {
      log("Starting rider location stream for delivery ${widget.deliveryId}");

      _locationSubscription =
          DeliveryRiderJob.watchRiderLocationOnJob(widget.deliveryId!)
              .where((location) => location != null)
              .map((location) => LatLng(location!.latitude, location.longitude))
              .listen(
                (LatLng location) => _handleLiveLocation(
                  location,
                  bypassThreshold: true,
                  isRiderLocation: true,
                ),
                onError: (error) => log('Rider location stream error: $error'),
              );

      return;
    }

    log(
      "Starting live location updates with distance filter: ${widget.locationUpdateDistance}m",
    );

    _locationSubscription =
        MapService.getPositionStream(
          distanceFilterMeters: widget.locationUpdateDistance,
        ).listen(
          (location) => _handleLiveLocation(location),
          onError: (error) => log('Live location stream error: $error'),
        );

    unawaited(_updateCurrentLocation());
  }

  void _stopLocationUpdates() {
    if (_locationSubscription == null) {
      return;
    }

    log("Stopping live location updates");
    _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  Future<void> _updateCurrentLocation() async {
    if (!mounted || widget.mode != PathFinderMode.currentToDestination) return;

    try {
      final newLocation = await MapService.getCurrentLocation();
      log(
        "Updated current location: ${newLocation.latitude}, ${newLocation.longitude}",
      );

      _handleLiveLocation(
        newLocation,
        bypassThreshold: true,
        isRiderLocation: false,
      );
    } catch (e) {
      log('Error updating current location: $e');
    }
  }

  void _handleLiveLocation(
    LatLng newLocation, {
    bool bypassThreshold = false,
    bool isRiderLocation = false,
  }) {
    if (!mounted) {
      return;
    }

    if (isRiderLocation) {
      log(
        "Received rider location update: ${newLocation.latitude}, ${newLocation.longitude}",
      );
    }

    if (_currentLocation != null && !bypassThreshold) {
      final double distanceDelta = DeliveryRiderJob.calculateDistance(
        _currentLocation!.latitude,
        _currentLocation!.longitude,
        newLocation.latitude,
        newLocation.longitude,
      );

      if (distanceDelta < widget.locationUpdateDistance / 2) {
        log(
          "Location change below threshold (${distanceDelta.toStringAsFixed(2)}m), skipping UI update",
        );
        return;
      }

      log(
        "Location changed by ${distanceDelta.toStringAsFixed(1)}m, updating route",
      );
    }

    setState(() {
      _currentLocation = newLocation;
      if (isRiderLocation) {
        _isRiderLocationActive = true;
      } else if (!_shouldUseRiderTracking) {
        _isRiderLocationActive = false;
      }
      _updatePathDestinations();
    });

    _updateManualRouteInfo();
  }

  LatLng? get _getOriginLocation {
    if (widget.mode == PathFinderMode.currentToDestination) {
      return _currentLocation;
    } else {
      return _originLocation;
    }
  }

  void _updateManualRouteInfo() {
    final LatLng? origin = _getOriginLocation;
    final LatLng? destination = _destinationLocation;

    if (origin == null || destination == null) {
      return;
    }

    if (_pathRouteInfo != null &&
        _pathRouteInfo!.distanceSource == MapRouteDistanceSource.api) {
      // Defer to API-driven updates when available.
      return;
    }

    final double distanceMeters = _distanceCalculator.as(
      latlng.LengthUnit.Meter,
      latlng.LatLng(origin.latitude, origin.longitude),
      latlng.LatLng(destination.latitude, destination.longitude),
    );

    final MapRouteInfo manualInfo = MapRouteInfo(
      points: <LatLng>[origin, destination],
      distanceMeters: distanceMeters,
      duration: null,
      distanceSource: MapRouteDistanceSource.computed,
    );

    if (!mounted) return;

    setState(() {
      _pathRouteInfo = manualInfo;
    });

    widget.getPathRouteInfo?.call(manualInfo);
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
    final bool showDeviceLocationFeatures = _shouldUseDeviceLocationFeatures;
    final bool isWaitingForRider =
        _shouldUseRiderTracking && !_isRiderLocationActive;

    return SlidingTemplate(
      customTopBar: Center(
        child: Text(
          widget.label ?? 'เส้นทางการจัดส่ง',
          style: const TextStyle(
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
                mode: MapPlaceholderMode.viewer,
                viewerType: MapViewerType.path,
                destinations: [_pathDestinations],
                initialPosition: _pathDestinations.latLng,
                initialUserLocation: _isCurrentToDestination
                    ? _currentLocation
                    : null,
                showMyLocation: showDeviceLocationFeatures,
                showMyLocationButton: showDeviceLocationFeatures,
                enableLiveLocation: showDeviceLocationFeatures,
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
        if (isWaitingForRider)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.pedal_bike_outlined,
                  size: 16,
                  color: Colors.orange,
                ),
                const SizedBox(width: 6),
                Text(
                  'กำลังค้นหาตำแหน่งไรเดอร์...',
                  style: TextStyle(fontSize: 12, fontFamily: 'Mali'),
                ),
              ],
            ),
          ),
        if (_pathRouteInfo != null && widget.isShowingDetail) ...[
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
