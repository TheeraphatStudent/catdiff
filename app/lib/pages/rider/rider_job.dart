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
  final gmaps.LatLng? initialUserLocation;

  const RiderJobPage({super.key, this.deliveryJob, this.initialUserLocation});

  @override
  State<RiderJobPage> createState() => _RiderJobPageState();
}

enum RidingJobState { takeJob, deliveringJob, submitJob }

class _RiderJobPageState extends State<RiderJobPage> {
  RidingJobState _ridingState = RidingJobState.takeJob;
  final ProfileController _profileController = ProfileController();

  DeliveryJob? _currentJob;
  StreamSubscription<gmaps.LatLng>? _locationSubscription;
  latlng.LatLng? _currentGeoLocation;
  gmaps.LatLng? _currentMapLocation;

  double _distanceToTarget = 0.0;
  bool _isUploadingImage = false;
  String? _processingImageUrl;

  @override
  void initState() {
    super.initState();

    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null && arguments['deliveryJob'] != null) {
      _currentJob = arguments['deliveryJob'] as DeliveryJob;
      log('Loaded delivery job from arguments: ${_currentJob!.deliveryId}');
    } else {
      _currentJob = widget.deliveryJob;
    }

    if (_currentJob != null) {
      switch (_currentJob!.status.name) {
        case 'receiving':
          _ridingState = RidingJobState.takeJob;
          break;
        case 'riding':
          _ridingState = RidingJobState.deliveringJob;
          break;
        default:
          _ridingState = RidingJobState.takeJob;
      }
      log(
        'Set initial riding state: ${_ridingState.name} for status: ${_currentJob!.status.name}',
      );
    }

    if (widget.initialUserLocation != null) {
      _currentMapLocation = widget.initialUserLocation;
      _currentGeoLocation = latlng.LatLng(
        widget.initialUserLocation!.latitude,
        widget.initialUserLocation!.longitude,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _refreshDistanceToTarget();
      });
    }
    _startLocationTracking();
    _setupProfileController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateCurrentLocation();
    });
  }

  void _setupProfileController() {
    _profileController.addListener(() {
      if (!mounted) {
        log('Widget not mounted, skipping ProfileController callback');
        return;
      }

      if (_profileController.uploadedUrl != null) {
        log(
          'ProfileController detected upload completion: ${_profileController.uploadedUrl}',
        );
        _handleImageUpload(_profileController.uploadedUrl!);
      }
    });
  }

  void _startLocationTracking() {
    log('Starting location tracking with stream for rider job');

    _locationSubscription =
        MapService.getPositionStream(distanceFilterMeters: 5).listen(
          _handleLiveLocation,
          onError: (error) => log('Rider job location stream error: $error'),
        );

    _updateCurrentLocation();
  }

  void _handleLiveLocation(gmaps.LatLng newLocation) {
    if (!mounted) return;

    log(
      'Live location update: ${newLocation.latitude}, ${newLocation.longitude}',
    );

    final geoLocation = latlng.LatLng(
      newLocation.latitude,
      newLocation.longitude,
    );

    setState(() {
      _currentGeoLocation = geoLocation;
      _currentMapLocation = newLocation;
    });

    _updateRiderLocationAndDistance(geoLocation);
  }

  Future<void> _updateRiderLocationAndDistance(latlng.LatLng location) async {
    if (_currentJob == null) return;

    try {
      final appData = Provider.of<AppData>(context, listen: false);

      await DeliveryRiderJob.updateRiderLocation(
        _currentJob!.deliveryId,
        location,
        appData.currentUser!.id,
      );

      final latlng.LatLng? targetLocation = _resolveTargetGeoLocation();

      if (targetLocation != null) {
        final distance = DeliveryRiderJob.calculateDistance(
          location.latitude,
          location.longitude,
          targetLocation.latitude,
          targetLocation.longitude,
        );

        _applyDistanceUpdate(distance);
      }
    } catch (e) {
      log('Error updating rider location and distance: $e');
    }
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
        await _updateRiderLocationAndDistance(geoLocation);
      }
    } catch (e) {
      log('Error getting initial location: $e');
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

    final distance = DeliveryRiderJob.calculateDistance(
      _currentGeoLocation!.latitude,
      _currentGeoLocation!.longitude,
      targetLocation.latitude,
      targetLocation.longitude,
    );

    _applyDistanceUpdate(distance);
  }

  void _applyDistanceUpdate(double distanceMeters) {
    if (!mounted) return;

    final shouldSubmit =
        _ridingState == RidingJobState.deliveringJob && distanceMeters <= 20;

    log(
      'Distance update: ${distanceMeters.toStringAsFixed(1)}m, State: ${_ridingState.name}, Should submit: $shouldSubmit',
    );

    setState(() {
      _distanceToTarget = distanceMeters;
      if (shouldSubmit) {
        log('Rider reached destination - enabling submit state');
        _ridingState = RidingJobState.submitJob;
      }
    });
  }

  Future<void> _handleImageUpload(String imageUrl) async {
    if (_currentJob == null) return;

    if (!mounted) {
      log('Widget not mounted, skipping image upload handling');
      return;
    }

    if (_processingImageUrl == imageUrl) {
      log('Image $imageUrl already being processed, skipping duplicate call');
      return;
    }

    log('Starting image upload process for: $imageUrl');
    _processingImageUrl = imageUrl;

    try {
      final appData = Provider.of<AppData>(context, listen: false);

      if (_ridingState == RidingJobState.takeJob) {
        log('Uploading pickup image for delivery: ${_currentJob!.deliveryId}');
        await DeliveryRiderJob.uploadPickupImage(
          _currentJob!.deliveryId,
          imageUrl,
          appData.currentUser!.id,
        );
        if (mounted) {
          setState(() {
            _ridingState = RidingJobState.deliveringJob;
            _isUploadingImage = false;
          });
        }

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

        log(
          'Uploading delivery completion image for delivery: ${_currentJob!.deliveryId}',
        );
        await DeliveryRiderJob.uploadDeliveryImage(
          _currentJob!.deliveryId,
          imageUrl,
        );

        log('Delivery completed successfully - redirecting to rider list');
        if (mounted) {
          setState(() {
            _isUploadingImage = false;
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('จัดส่งสำเร็จ!'),
            backgroundColor: AppColors.primary3,
          ),
        );

        Future.delayed(Duration(seconds: 2), () {
          if (mounted) {
            Get.offAllNamed('/rider');
          }
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
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
      }
      _processingImageUrl = null;
    }
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
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
                    '${_distanceStatusLabel()}: ${DeliveryRiderJob.formatDistance(_distanceToTarget)}',
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
              onRouteChanged: (_) {
                _refreshDistanceToTarget();
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
                    size: ProfileSize.xl,
                    userId: Provider.of<AppData>(
                      context,
                      listen: false,
                    ).currentUser?.id,
                    config: ProfileWidgetConfig(editIcon: Icons.upload),
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
