import 'dart:developer';

import 'package:app/config/share/app_data.dart';
import 'package:app/config/theme/app_theme.dart';
import 'package:app/layout/MainLayout.dart';
import 'package:app/pages/rider/rider_job.dart';
import 'package:app/service/delivery/rider_job.dart';
import 'package:app/service/map/map_service.dart';
import 'package:app/types/address/address.dart';
import 'package:app/types/delivery/delivery_job.dart';
import 'package:app/types/status.dart';
import 'package:app/widget/button.widget.dart';
import 'package:app/widget/card/rider_job.widget.dart';
import 'package:app/widget/map/map_route_info.dart';
import 'package:app/widget/profile_img.widget.dart';
import 'package:app/widget/sliding_up/map_viewer_single-point._path-finder.widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:provider/provider.dart';

class RiderListProd extends StatefulWidget {
  const RiderListProd({super.key});

  @override
  State<RiderListProd> createState() => _RiderListProdState();
}

class _RiderListProdState extends State<RiderListProd> {
  bool _isMapOpen = false;
  LatLng? _currentLocation;
  bool _isLoadingLocation = false;

  MapRouteInfo _routeInfo = MapRouteInfo(
    points: [],
    distanceMeters: 0,
    duration: null,
    distanceSource: MapRouteDistanceSource.api,
  );
  String _selectedDestinationLabel = "ปลายทาง";

  DeliveryJob _deliveryJob = DeliveryJob(
    deliveryId: '???',
    status: StatusType.pending,
    pickupPkgImagesUrl: [],
    pickupAddress: AddressInfo(
      addressId: '???',
      detail: '???',
      latitude: 0,
      longtitude: 0,
      createdAt: '???',
      updatedAt: '???',
    ),
    deliveryAddress: AddressInfo(
      addressId: '???',
      detail: '???',
      latitude: 0,
      longtitude: 0,
      createdAt: '???',
      updatedAt: '???',
    ),
    sender: UserInfo(userId: '???', name: '???', imagesUrl: '???'),
    reciver: UserInfo(userId: '???', name: '???', imagesUrl: '???'),
    sendedPkgDetail: '???',
  );

  double _selectedLat = 16.1872;
  double _selectedLng = 103.3045;

  AddressInfo _getTargetAddressForJob(DeliveryJob job) {
    switch (job.status.name) {
      case 'receiving':
        log(
          'Job ${job.deliveryId} is in receiving state - target: pickup address',
        );
        return job.pickupAddress;
      case 'riding':
        log(
          'Job ${job.deliveryId} is in riding state - target: delivery address',
        );
        return job.deliveryAddress;
      default:
        log(
          'Job ${job.deliveryId} has unknown status ${job.status.name} - defaulting to pickup address',
        );
        return job.pickupAddress;
    }
  }

  void _openMapForDelivery(AddressInfo address) async {
    setState(() {
      _isLoadingLocation = true;
      _selectedDestinationLabel = "ปลายทาง: ${address.detail}";
      _selectedLat = address.latitude;
      _selectedLng = address.longtitude;
    });

    if (_isLoadingLocation) {
      log("Loading current location for delivery map...");
    }

    try {
      final currentLoc = await MapService.getCurrentLocation();
      log(
        "Got current location for map: ${currentLoc.latitude}, ${currentLoc.longitude}",
      );

      if (mounted) {
        setState(() {
          _currentLocation = currentLoc;
          _isLoadingLocation = false;
          _isMapOpen = true;
        });

        if (_currentLocation != null) {
          log(
            "Current location set: ${_currentLocation!.latitude}, ${_currentLocation!.longitude}",
          );
        }

        if (_currentLocation != null) {
          await _updateRouteInfoDistance(_currentLocation!, address);
        }
      }
    } catch (e) {
      log('Error getting current location: $e');
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
          _isMapOpen = true;
        });
      }
    }
  }

  Future<void> _updateRouteInfoDistance(
    LatLng origin,
    AddressInfo address,
  ) async {
    try {
      final double distance = DeliveryRiderJob.calculateDistance(
        origin.latitude,
        origin.longitude,
        address.latitude,
        address.longtitude,
      );

      if (!mounted) return;

      setState(() {
        _routeInfo = MapRouteInfo(
          points: <LatLng>[
            origin,
            LatLng(address.latitude, address.longtitude),
          ],
          distanceMeters: distance,
          duration: _routeInfo.duration,
          distanceSource: MapRouteDistanceSource.computed,
        );
      });
    } catch (e) {
      log('Error calculating route distance: $e');
    }
  }

  void _closeMap() {
    setState(() {
      _isMapOpen = false;
    });
  }

  void _riderAcceptAnJob(DeliveryJob job) async {
    try {
      await DeliveryRiderJob.onWorkingDeliveryJob(job, _appData!.currentUser!);

      Get.off(
        () => RiderJobPage(
          deliveryJob: job,
          initialUserLocation: _currentLocation,
        ),
      );
    } catch (e) {
      log('Error accepting job: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาดในการรับงาน'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  AppData? _appData;

  @override
  void initState() {
    super.initState();
    _appData = Provider.of<AppData>(context, listen: false);
    _initializeCurrentLocation();
  }

  Future<void> _initializeCurrentLocation() async {
    try {
      final currentLoc = await MapService.getCurrentLocation();
      if (mounted) {
        setState(() {
          _currentLocation = currentLoc;
        });
      }
      log(
        "Initial current location: ${currentLoc.latitude}, ${currentLoc.longitude}",
      );
    } catch (e) {
      log('Error initializing current location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      scrollable: false,
      body: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 152,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 24,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 6,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: ShapeDecoration(
                          color: AppColors.primary5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          shadows: [
                            BoxShadow(
                              color: Color(0x3F819067),
                              blurRadius: 8,
                              offset: Offset(0, 1.50),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 4.0,
                              ),
                              child: Text(
                                _appData?.currentUser?.name ?? '???',
                                style: TextStyle(
                                  color: AppColors.black,
                                  fontSize: 14,
                                  fontFamily: 'Mali',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 2),
                      Row(
                        spacing: 8,
                        children: [
                          Text(
                            'ทะเบียนรถ:',
                            style: TextStyle(
                              color: AppColors.primary2 /* Primary-Green2 */,
                              fontSize: 12,
                              fontFamily: 'Mali',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            _appData?.currentUser?.verhicle?.licencePlate ??
                                '-',
                            style: TextStyle(
                              color: AppColors.primary2,
                              fontSize: 12,
                              fontFamily: 'Mali',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: -22,
                  top: -22,
                  // child: ProfileWidget(isEdited: false, size: ProfileSize.md),
                  child: ProfileWidgets.avatar(
                    isEdited: false,
                    size: ProfileSize.md,
                    // imageUrl: "https://storage.googleapis.com/lottocat_bucket/uploads/2a168538-24b6-4454-bc4c-906cd49dc8a1.jpg",
                    imageUrl: _appData?.currentUser?.imagesUrl,
                    onPressed: () {
                      log("On preseed work");

                      Get.offNamed('/profile');
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<DeliveryJob>>(
              stream: DeliveryRiderJob.getDeliveryJobsStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  log('StreamBuilder error: ${snapshot.error}');
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.exclamationmark_triangle,
                          size: 48,
                          color: AppColors.black,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'เกิดข้อผิดพลาดในการโหลดข้อมูล',
                          style: TextStyle(
                            fontFamily: 'Mali',
                            fontSize: 16,
                            color: AppColors.black,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CupertinoActivityIndicator());
                }

                final deliveryJobs = snapshot.data ?? [];

                if (deliveryJobs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.cube_box,
                          size: 64,
                          color: AppColors.black,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'ไม่มีงานส่งของในขณะนี้',
                          style: TextStyle(
                            fontFamily: 'Mali',
                            fontSize: 16,
                            color: AppColors.black,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 32,
                  ),

                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 16,
                    children: deliveryJobs.map((job) {
                      return DeliverJobItem(
                        deliveryJob: job,
                        isEditableField: false,
                        onCardTap: () {
                          log('Card tapped: ${job.deliveryId}');
                          _deliveryJob = job;
                          final targetAddress = _getTargetAddressForJob(job);
                          _openMapForDelivery(targetAddress);
                        },
                        onLocationTap: (address) {
                          // log('Location tapped: ${address.detail}');

                          _deliveryJob = job;
                          final targetAddress = _getTargetAddressForJob(job);
                          _openMapForDelivery(targetAddress);
                        },
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
          MapViewerSinglePointPathFinder(
            lat: _selectedLat,
            lng: _selectedLng,
            destLabel: _selectedDestinationLabel,
            label: 'เส้นทางการจัดส่ง - #${_deliveryJob.deliveryId}',

            mode: PathFinderMode.currentToDestination,
            locationUpdateInterval: Duration(seconds: 5),
            locationUpdateDistance: 3,

            isOpened: _isMapOpen,
            onModalClosed: _closeMap,
            aspectRatio: 12 / 9,
            getPathRouteInfo: (routeInfo) {
              setState(() {
                _routeInfo = routeInfo;
              });
            },
            content: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ProfileWidgets.avatar(
                        isEdited: false,
                        imageUrl: _deliveryJob.sender.imagesUrl,
                        size: ProfileSize.sm,
                      ),
                      SizedBox(height: 4),
                      Text("ผู้ส่ง #${_deliveryJob.sender.name}"),
                    ],
                  ),
                  SizedBox(height: 16),
                  DeliverJobItem(
                    deliveryJob: _deliveryJob,
                    isShowingMap: false,
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ButtonActions(
                          variant: ButtonVariant.danger,
                          text: 'ปิด',
                          icon: Icons.close,
                          iconPosition: IconPosition.left,
                          onPressed: () {
                            _closeMap();
                          },
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: ButtonActions(
                          variant: ButtonVariant.primary,
                          text: 'รับงานนนี้',
                          // text: 'รับงานนนี้ ${_routeInfo.distanceMeters}',
                          disable: _routeInfo.distanceMeters > 20,
                          iconPosition: IconPosition.right,
                          icon: Icons.check,
                          onPressed: () {
                            _closeMap();

                            _riderAcceptAnJob(_deliveryJob);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
