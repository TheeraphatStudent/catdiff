import 'package:app/config/theme/app_theme.dart';
import 'package:app/service/map/map_service.dart';
import 'package:app/types/delivery/delivery_job.dart';
import 'package:app/types/status.dart';
import 'package:app/widget/map/map_destination.dart';
import 'package:app/widget/map/map_placeholder.dart';
import 'package:app/widget/map/map_selection_result.dart';
import 'package:app/widget/sliding_up/sliding_template.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'dart:developer';

class MapViewerMultiplePoint extends StatefulWidget {
  final List<DeliveryJob> deliveryJobs;
  final bool isOpened;
  final String? label;
  final VoidCallback? onModalClosed;
  final double? aspectRatio;
  final Widget? content;

  const MapViewerMultiplePoint({
    super.key,
    required this.deliveryJobs,
    this.isOpened = false,
    this.label,
    this.onModalClosed,
    this.aspectRatio = 9 / 16,
    this.content,
  });

  @override
  State<MapViewerMultiplePoint> createState() => _MapViewerMultiplePointState();
}

class _MapViewerMultiplePointState extends State<MapViewerMultiplePoint> {
  List<MapDestination> _destinations = [];
  String? _selectedMarkerInfo;
  StreamSubscription<LatLng>? _locationSubscription;
  LatLng? _currentRiderLocation;

  @override
  void initState() {
    super.initState();
    _buildDestinations();
    _startLocationTracking();
  }

  @override
  void didUpdateWidget(MapViewerMultiplePoint oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.deliveryJobs != widget.deliveryJobs) {
      _buildDestinations();
      _startLocationTracking();
    }
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  void _buildDestinations() {
    List<MapDestination> destinations = [];

    for (DeliveryJob job in widget.deliveryJobs) {
      if (job.status == StatusType.prepare ||
          job.status == StatusType.pending) {
        destinations.add(
          MapDestination(
            latitude: job.pickupAddress.latitude,
            longitude: job.pickupAddress.longtitude,
            label: 'รับ: ${job.deliveryId} - ${job.pickupAddress.detail}',
          ),
        );
      }

      destinations.add(
        MapDestination(
          latitude: job.deliveryAddress.latitude,
          longitude: job.deliveryAddress.longtitude,
          label: 'ส่ง: ${job.deliveryId} - ${job.deliveryAddress.detail}',
        ),
      );
    }

    if (_currentRiderLocation != null && _hasActiveRiderJobs()) {
      destinations.add(
        MapDestination(
          latitude: _currentRiderLocation!.latitude,
          longitude: _currentRiderLocation!.longitude,
          label: 'ตำแหน่งไรเดอร์ (อัพเดทแบบเรียลไทม์)',
        ),
      );
    }

    setState(() {
      _destinations = destinations;
    });
  }

  bool _hasActiveRiderJobs() {
    return widget.deliveryJobs.any(
      (job) =>
          job.status == StatusType.receiving || job.status == StatusType.riding,
    );
  }

  void _startLocationTracking() {
    _locationSubscription?.cancel();

    if (_hasActiveRiderJobs()) {
      log('Starting real-time location tracking for rider');
      _locationSubscription =
          MapService.getPositionStream(distanceFilterMeters: 5).listen((
            location,
          ) {
            log(
              'Rider location updated: ${location.latitude}, ${location.longitude}',
            );
            setState(() {
              _currentRiderLocation = location;
            });
            _buildDestinations();
          });
    }
  }

  void _handleMarkerTapped(MapSelectionResult result) {
    String markerInfo = 'ไม่พบข้อมูล';

    if (_currentRiderLocation != null &&
        _currentRiderLocation!.latitude == result.position.latitude &&
        _currentRiderLocation!.longitude == result.position.longitude) {
      markerInfo = 'ตำแหน่งไรเดอร์ปัจจุบัน';
    } else {
      for (DeliveryJob job in widget.deliveryJobs) {
        if (job.deliveryAddress.latitude == result.position.latitude &&
            job.deliveryAddress.longtitude == result.position.longitude) {
          markerInfo = 'ส่ง: ${job.deliveryId} - ${job.deliveryAddress.detail}';
          break;
        }

        if ((job.status == StatusType.prepare ||
                job.status == StatusType.pending) &&
            job.pickupAddress.latitude == result.position.latitude &&
            job.pickupAddress.longtitude == result.position.longitude) {
          markerInfo = 'รับ: ${job.deliveryId} - ${job.pickupAddress.detail}';
          break;
        }
      }
    }

    setState(() {
      _selectedMarkerInfo = markerInfo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SlidingTemplate(
      customTopBar: Center(
        child: Text(
          widget.label ?? 'แผนที่จุดส่งหลายจุด',
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
        AspectRatio(
          aspectRatio: widget.aspectRatio ?? 9 / 16,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: MapPlaceholder(
              mode: MapPlaceholderMode.viewer,
              viewerType: MapViewerType.multiple,
              destinations: _destinations,
              onMarkerTapped: _handleMarkerTapped,
              fetchGeocodeOnMarkerTap: true,
            ),
          ),
        ),

        SizedBox(height: 16),

        if (_selectedMarkerInfo != null)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'จุดที่เลือก:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Mali',
                    color: Colors.blue[700],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  _selectedMarkerInfo!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Mali',
                  ),
                ),
              ],
            ),
          ),

        SizedBox(height: 16),

        Text(
          'รายการจัดส่ง (${widget.deliveryJobs.length} จุด)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Mali',
          ),
        ),

        SizedBox(height: 8),

        ...widget.deliveryJobs.map((job) {
          IconData statusIcon = _getStatusIcon(job.status);

          return Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(statusIcon, size: 16),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${job.deliveryId} - ${StatusTypes().getStatusMeaning(job.status)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Mali',
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),

                  if (job.status == StatusType.prepare ||
                      job.status == StatusType.pending) ...[
                    Row(
                      children: [
                        Icon(Icons.upload, size: 14, color: Colors.orange),
                        SizedBox(width: 4),
                        Text(
                          'รับ:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Mali',
                          ),
                        ),
                      ],
                    ),
                    Text(
                      job.pickupAddress.detail,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontFamily: 'Mali',
                      ),
                    ),
                    SizedBox(height: 4),
                  ],

                  Row(
                    children: [
                      Icon(Icons.download, size: 14, color: Colors.green),
                      SizedBox(width: 4),
                      Text(
                        'ส่ง:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Mali',
                        ),
                      ),
                    ],
                  ),
                  Text(
                    job.deliveryAddress.detail,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontFamily: 'Mali',
                    ),
                  ),
                  SizedBox(height: 4),

                  Text(
                    'ผู้รับ: ${job.reciver.name}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      fontFamily: 'Mali',
                    ),
                  ),

                  if (job.status == StatusType.receiving ||
                      job.status == StatusType.riding) ...[
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.motorcycle, size: 14, color: Colors.blue),
                        SizedBox(width: 4),
                        Text(
                          _currentRiderLocation != null
                              ? 'ไรเดอร์: ติดตามตำแหน่งแบบเรียลไทม์'
                              : 'ไรเดอร์: กำลังค้นหาตำแหน่ง...',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[700],
                            fontFamily: 'Mali',
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        }),

        if (widget.content != null) ...[SizedBox(height: 16), widget.content!],
      ],
    );
  }

  IconData _getStatusIcon(StatusType status) {
    switch (status) {
      case StatusType.prepare:
        return Icons.inventory_2;
      case StatusType.pending:
        return Icons.schedule;
      case StatusType.receiving:
        return Icons.motorcycle;
      case StatusType.riding:
        return Icons.local_shipping;
      case StatusType.success:
        return Icons.check_circle;
    }
  }
}
