import 'dart:async';
import 'dart:developer';

import 'package:app/config/share/app_data.dart';
import 'package:app/config/theme/app_theme.dart';
import 'package:app/layout/MainLayout.dart';
import 'package:app/service/delivery/rider_job.dart';
import 'package:app/service/map/map_service.dart';
import 'package:app/service/map/routes_service.dart';
import 'package:app/types/delivery/delivery_job.dart';
import 'package:app/widget/button.widget.dart';
import 'package:app/widget/card/rider_job.widget.dart';
import 'package:app/widget/map/map_destination.dart';
import 'package:app/widget/map/map_placeholder.dart';
import 'package:app/widget/profile_img.widget.dart';
import 'package:app/widget/sliding_up/sliding_template.dart';
import 'package:app/widget/stepper.widget.dart';
import 'package:app/widget/tag.widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:latlong2/latlong.dart' as latlng;
import 'package:provider/provider.dart';

class RiderJobPage extends StatefulWidget {
  final DeliveryJob? deliveryJob;

  const RiderJobPage({super.key, this.deliveryJob});

  @override
  State<RiderJobPage> createState() => _RiderJobPageState();
}

enum RidingJobState { takeJob, deliveringJob, submitJob }

class _RiderJobPageState extends State<RiderJobPage> {
  RidingJobState _ridingState = RidingJobState.takeJob;
  final ProfileController _profileController = ProfileController();

  DeliveryJob? _currentJob;
  Timer? _locationTimer;
  latlng.LatLng? _currentGeoLocation;
  gmaps.LatLng? _currentMapLocation;

  double _distanceToTarget = 0.0;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _currentJob = widget.deliveryJob;
    _startLocationTracking();
    _setupProfileController();
  }

  void _setupProfileController() {
    _profileController.addListener(() {
      if (_profileController.uploadedUrl != null && !_isUploadingImage) {
        _handleImageUpload(_profileController.uploadedUrl!);
      }
    });
  }

  void _startLocationTracking() {
    _locationTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      _updateCurrentLocation();
    });
  }

  Future<void> _updateCurrentLocation() async {
    try {
      final location = await MapService.getCurrentLocation();
      final geoLocation = latlng.LatLng(location.latitude, location.longitude);

      setState(() {
        _currentMapLocation = location;
        _currentGeoLocation = geoLocation;
      });

      if (_currentJob != null && _currentGeoLocation != null) {
        final appData = Provider.of<AppData>(context, listen: false);
        await DeliveryRiderJob.updateRiderLocation(
          _currentJob!.deliveryId,
          _currentGeoLocation!,
          appData.currentUser!.id,
        );

        final latlng.LatLng? targetLocation = _resolveTargetGeoLocation();
        if (targetLocation != null) {
          final distance =
              await DeliveryRiderJob.calculateDistanceFromDestination(
                _currentGeoLocation!,
                targetLocation,
              );

          _applyDistanceUpdate(distance);
        }
      }
    } catch (e) {
      log('Error updating location: $e');
    }
  }

  latlng.LatLng? _resolveTargetGeoLocation() {
    if (_currentJob == null) return null;
    final targetAddress = _ridingState == RidingJobState.takeJob
        ? _currentJob!.pickupAddress
        : _currentJob!.deliveryAddress;

    return latlng.LatLng(targetAddress.latitude, targetAddress.longtitude);
  }

  MapDestination _buildTargetDestination() {
    final targetAddress = _ridingState == RidingJobState.takeJob
        ? _currentJob!.pickupAddress
        : _currentJob!.deliveryAddress;

    return MapDestination(
      latitude: targetAddress.latitude,
      longitude: targetAddress.longtitude,
      label: targetAddress.detail,
      markerId: _ridingState == RidingJobState.takeJob
          ? 'pickup_destination'
          : 'delivery_destination',
    );
  }

  String _distanceStatusLabel() {
    switch (_ridingState) {
      case RidingJobState.takeJob:
        return 'ระยะห่างจากจุดรับสินค้า';
      case RidingJobState.deliveringJob:
      case RidingJobState.submitJob:
        return 'ระยะห่างจากปลายทาง';
    }
  }

  bool get _isWithinCompletionRange => _distanceToTarget <= 20;

  Future<void> _refreshDistanceToTarget() async {
    if (_currentGeoLocation == null) return;
    final targetLocation = _resolveTargetGeoLocation();
    if (targetLocation == null) return;

    final distance = await DeliveryRiderJob.calculateDistanceFromDestination(
      _currentGeoLocation!,
      targetLocation,
    );

    _applyDistanceUpdate(distance);
  }

  void _applyDistanceUpdate(double distanceMeters) {
    if (!mounted) return;

    final shouldSubmit =
        _ridingState == RidingJobState.deliveringJob && distanceMeters <= 20;

    setState(() {
      _distanceToTarget = distanceMeters;
      if (shouldSubmit) {
        _ridingState = RidingJobState.submitJob;
      }
    });
  }

  Future<void> _handleImageUpload(String imageUrl) async {
    if (_currentJob == null) return;

    setState(() {
      _isUploadingImage = true;
    });

    try {
      final appData = Provider.of<AppData>(context, listen: false);

      if (_ridingState == RidingJobState.takeJob) {
        await DeliveryRiderJob.uploadPickupImage(
          _currentJob!.deliveryId,
          imageUrl,
          appData.currentUser!.id,
        );

        setState(() {
          _ridingState = RidingJobState.deliveringJob;
        });

        await _refreshDistanceToTarget();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('อัพโหลดรูปรับสินค้าสำเร็จ กำลังดำเนินการส่ง'),
            backgroundColor: AppColors.primary3,
          ),
        );
      } else if (_ridingState == RidingJobState.submitJob) {
        if (_distanceToTarget > 20) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'คุณต้องอยู่ในระยะ 20 เมตรจากจุดหมายปลายทางเพื่ออัพโหลดรูป',
              ),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        await DeliveryRiderJob.uploadDeliveryImage(
          _currentJob!.deliveryId,
          imageUrl,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('จัดส่งสำเร็จ!'),
            backgroundColor: AppColors.primary3,
          ),
        );

        Future.delayed(Duration(seconds: 2), () {
          Get.back();
        });
      }
    } catch (e) {
      log('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาดในการอัพโหลดรูป'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploadingImage = false;
      });
    }
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    _profileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentJob == null) {
      return MainLayout(body: Center(child: Text('ไม่พบข้อมูลงานจัดส่ง')));
    }

    final mapDestination = _buildTargetDestination();

    return MainLayout(
      scrollable: false,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              spacing: 8,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Tag(
                      color: AppColors.primary5,
                      text: "#${_currentJob!.deliveryId}",
                    ),
                    ButtonActions(
                      variant: ButtonVariant.danger,
                      icon: Icons.close,
                      disable: _ridingState != RidingJobState.takeJob,
                      onPressed: () {},
                    ),
                  ],
                ),
                StepperWidget(
                  steps: [
                    StepData(
                      label: "เข้ารับสินค้า",
                      active: _ridingState == RidingJobState.takeJob,
                    ),
                    StepData(
                      label: "ดำเนินการส่ง",
                      active: _ridingState == RidingJobState.deliveringJob,
                    ),
                    StepData(
                      label: "ถึงปลายทาง",
                      active: _ridingState == RidingJobState.submitJob,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_currentGeoLocation != null)
            Container(
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: _isWithinCompletionRange
                    ? AppColors.primary3
                    : AppColors.primary2,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    '${_distanceStatusLabel()}: ${_distanceToTarget.toStringAsFixed(1)} เมตร',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

          // State 1 -> Rider to pickup
          // State 2 -> Pickup to delivery
          Expanded(
            child: MapPlaceholder(
              key: ValueKey('rider_map_${_ridingState.name}'),
              mode: MapPlaceholderMode.viewer,
              viewerType: MapViewerType.path,
              destinations: [mapDestination],
              initialPosition: mapDestination.latLng,
              initialUserLocation: _currentMapLocation,
              showMyLocation: true,
              showMyLocationButton: true,
              enableLiveLocation: true,
              distanceStrategy:
                  MapRouteDistanceStrategy.distanceMatrixPreferred,
              onRouteChanged: (info) {
                _applyDistanceUpdate(info.distanceMeters);
              },
            ),
          ),

          Padding(
            padding: EdgeInsetsGeometry.all(16),
            child: Column(
              spacing: 12,
              children: [
                DeliverJobItem(deliveryJob: _currentJob!),

                _buildActions(_ridingState),
              ],
            ),
          ),

          SizedBox(height: 12),

          SlidingTemplate(
            isOpened: _isUploadingImage,
            onModalClosed: () {
              setState(() {
                _isUploadingImage = false;
              });
            },
            children: [
              Column(
                children: [
                  Text(
                    _ridingState == RidingJobState.takeJob
                        ? "อัพโหลดรูปการรับสินค้า"
                        : "อัพโหลดรูปการจัดส่ง",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  ProfileWidgets.managed(
                    controller: _profileController,
                    isEdited: true,
                    autoUpload: true,
                    userId: Provider.of<AppData>(
                      context,
                      listen: false,
                    ).currentUser?.id,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActions(RidingJobState state) {
    String text = "";
    ButtonVariant variant = ButtonVariant.primary;
    bool disable = false;
    VoidCallback? onPressed;

    switch (state) {
      case RidingJobState.takeJob:
        text = "อัพโหลดรูปการรับสินค้า";
        onPressed = () {
          setState(() {
            _isUploadingImage = true;
          });
        };
        break;
      case RidingJobState.deliveringJob:
        text = "กำลังดำเนินการส่ง...";
        disable = true;
        break;
      case RidingJobState.submitJob:
        text = "อัพโหลดรูปการจัดส่ง";
        disable = !_isWithinCompletionRange;
        onPressed = disable
            ? null
            : () {
                setState(() {
                  _isUploadingImage = true;
                });
              };
        break;
    }

    return ButtonActions(
      variant: variant,
      icon: Icons.upload,
      text: text,
      iconPosition: IconPosition.right,
      disable: disable,
      onPressed: onPressed,
    );
  }
}
