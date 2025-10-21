import 'dart:developer';
import 'package:app/config/share/app_data.dart';
import 'package:app/config/theme/app_theme.dart';
import 'package:app/layout/MainLayout.dart';
import 'package:app/pages/map_debug.dart';
import 'package:app/service/delivery/rider_job.dart';
import 'package:app/types/address/address.dart';
import 'package:app/types/delivery/delivery_home.dart';
import 'package:app/types/delivery/delivery_job.dart';
import 'package:app/types/status.dart';
import 'package:app/types/user/type.dart';
import 'package:app/widget/button.widget.dart';
import 'package:app/widget/card/rider_job.widget.dart';
import 'package:app/widget/profile_img.widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class DebugMulti extends StatefulWidget {
  const DebugMulti({super.key});

  @override
  State<DebugMulti> createState() => _DebugMultiState();
}

class _DebugMultiState extends State<DebugMulti> {
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
      body: Stack(
        children: [
          // 🔹 ส่วนแสดงรายการงานจัดส่ง
          Column(
            children: [
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
                      return const Center(child: CupertinoActivityIndicator());
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
                        children: deliveryJobs.map((job) {
                          return DeliverJobItem(
                            deliveryJob: job,
                            isEditableField: false,
                            isShowingMap: true,
                            onCardTap: () {
                              log('Card tapped: ${job.deliveryId}');
                              _deliveryJob = job;
                              _openMapForDelivery(job.deliveryAddress);
                            },
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
            ],
          ),

          // 🔹 เมื่อกดเปิดแผนที่ จะแสดง MapDebugPage แทน
          if (_isMapOpen)
            Positioned.fill(
              child: Scaffold(
                body: SafeArea(
                  child: Stack(
                    children: [
                      const MapDebugPage(),
                      Positioned(
                        top: 16,
                        left: 16,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black87,
                            elevation: 3,
                          ),
                          onPressed: _closeMap,
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('กลับ'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
