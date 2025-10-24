import 'package:app/types/delivery/delivery_job.dart';
import 'package:app/widget/map/map_destination.dart';
import 'package:app/widget/map/map_placeholder.dart';
import 'package:app/widget/map/map_selection_result.dart';
import 'package:app/widget/sliding_up/sliding_template.dart';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    _buildDestinations();
  }

  @override
  void didUpdateWidget(MapViewerMultiplePoint oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.deliveryJobs != widget.deliveryJobs) {
      _buildDestinations();
    }
  }

  void _buildDestinations() {
    _destinations = widget.deliveryJobs.map((job) {
      return MapDestination(
        latitude: job.deliveryAddress.latitude,
        longitude: job.deliveryAddress.longtitude,
        label: '${job.deliveryId} - ${job.deliveryAddress.detail}',
      );
    }).toList();
  }

  void _handleMarkerTapped(MapSelectionResult result) {
    final selectedJob = widget.deliveryJobs.firstWhere(
      (job) =>
          job.deliveryAddress.latitude == result.position.latitude &&
          job.deliveryAddress.longtitude == result.position.longitude,
      orElse: () => widget.deliveryJobs.first,
    );

    setState(() {
      _selectedMarkerInfo =
          '${selectedJob.deliveryId} - ${selectedJob.deliveryAddress.detail}';
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
          return Container(
            margin: EdgeInsets.only(bottom: 8),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.red),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        job.deliveryId,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Mali',
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
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
              ],
            ),
          );
        }),

        if (widget.content != null) ...[SizedBox(height: 16), widget.content!],
      ],
    );
  }
}
