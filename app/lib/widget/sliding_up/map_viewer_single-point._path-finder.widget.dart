import 'package:app/config/theme/app_theme.dart';
import 'package:app/service/map/map_service.dart';
import 'package:app/service/map/routes_service.dart';
import 'package:app/widget/map/map_destination.dart';
import 'package:app/widget/map/map_placeholder.dart';
import 'package:app/widget/map/map_route_info.dart';
import 'package:app/widget/sliding_up/sliding_template.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:developer';

class MapViewerSinglePointPathFinder extends StatefulWidget {
  final double? lat;
  final double? lng;
  final String? destLabel;
  final String? label;
  final bool isOpened;

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
    this.onModalClosed,
    this.getPathRouteInfo,
  });

  @override
  State<MapViewerSinglePointPathFinder> createState() =>
      _MapViewerSinglePointState();
}

class _MapViewerSinglePointState extends State<MapViewerSinglePointPathFinder> {
  LatLng? _currentLocation;
  LatLng? _destinationLocation;
  final List<MapDestination> _pathDestinations = [];
  MapRouteInfo? _pathRouteInfo;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _initializeLocations();
  }

  @override
  void didUpdateWidget(MapViewerSinglePointPathFinder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lat != widget.lat || oldWidget.lng != widget.lng) {
      _initializeLocations();
    }
  }

  Future<void> _initializeLocations() async {
    if (!mounted) return;

    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final currentLoc = await MapService.getCurrentLocation();

      LatLng? destLoc;
      if (widget.lat != null && widget.lng != null) {
        destLoc = LatLng(widget.lat!, widget.lng!);
      }

      if (mounted) {
        setState(() {
          _currentLocation = currentLoc;
          _destinationLocation = destLoc;
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
    _pathDestinations.clear();

    if (_currentLocation != null) {
      _pathDestinations.add(
        MapDestination(
          latitude: _currentLocation!.latitude,
          longitude: _currentLocation!.longitude,
          label: 'ตำแหน่งปัจจุบัน',
          markerId: 'origin',
        ),
      );
    }

    if (_destinationLocation != null) {
      _pathDestinations.add(
        MapDestination(
          latitude: _destinationLocation!.latitude,
          longitude: _destinationLocation!.longitude,
          label: widget.destLabel ?? 'ปลายทาง',
          markerId: 'destination',
        ),
      );
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
        else if (_pathDestinations.isEmpty)
          SizedBox(
            height: 200,
            child: Center(
              child: Text(
                'ไม่สามารถโหลดตำแหน่งได้',
                style: TextStyle(fontFamily: 'Mali', fontSize: 16),
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
                destinations: _pathDestinations,
                initialPosition: _pathDestinations.first.latLng,
                initialUserLocation: _currentLocation,
                showMyLocation: true,
                showMyLocationButton: true,
                enableLiveLocation: false,
                distanceStrategy:
                    MapRouteDistanceStrategy.distanceMatrixPreferred,
                onRouteChanged: (info) {
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
