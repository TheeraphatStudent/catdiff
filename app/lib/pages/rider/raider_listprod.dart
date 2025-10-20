import 'dart:developer';

import 'package:app/config/share/app_data.dart';
import 'package:app/config/theme/app_theme.dart';
import 'package:app/layout/MainLayout.dart';
import 'package:app/service/delivery/rider_job.dart';
import 'package:app/types/address/address.dart';
import 'package:app/types/delivery/delivery_home.dart';
import 'package:app/types/delivery/delivery_job.dart';
import 'package:app/types/status.dart';
import 'package:app/types/user/type.dart';
import 'package:app/widget/card/rider_job.widget.dart';
import 'package:app/widget/profile_img.widget.dart';
import 'package:app/widget/sliding_up/map_viewer_single-point._path-finder.widget.dart';
import 'package:app/widget/sliding_up/map_viewer_single-point.widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class RiderListProd extends StatefulWidget {
  const RiderListProd({super.key});

  @override
  State<RiderListProd> createState() => _RiderListProdState();
}

class _RiderListProdState extends State<RiderListProd> {
  // Map state management
  bool _isMapOpen = false;
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
  );

  double _selectedLat = 16.1872;
  double _selectedLng = 103.3045;

  void _openMapForDelivery(AddressInfo address) {
    setState(() {
      _isMapOpen = true;
      _selectedDestinationLabel = "ปลายทาง: ${address.detail}";
      _selectedLat = address.latitude;
      _selectedLng = address.longtitude;
    });
  }

  void _closeMap() {
    setState(() {
      _isMapOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
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
                                appData.currentUser?.name ?? '???',
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
                            appData.currentUser?.verhicle?.licencePlate ?? '-',
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
                    imageUrl: appData.currentUser?.imagesUrl,
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
                        onLocationTap: (address) {
                          log('Location tapped: ${address.detail}');

                          _deliveryJob = job;

                          _openMapForDelivery(address);
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
            isOpened: _isMapOpen,
            onModalClosed: _closeMap,
            aspectRatio: 12 / 9,
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
                  DeliverJobItem(deliveryJob: _deliveryJob),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
