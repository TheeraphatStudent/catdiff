import 'dart:developer';

import 'package:app/config/share/app_data.dart';
import 'package:app/config/theme/app_theme.dart';
import 'package:app/layout/MainLayout.dart';
import 'package:app/types/address/address.dart';
import 'package:app/types/delivery/delivery_home.dart';
import 'package:app/types/delivery/delivery_job.dart';
import 'package:app/types/status.dart';
import 'package:app/types/user/type.dart';
import 'package:app/widget/card/rider_job.widget.dart';
import 'package:app/widget/profile_img.widget.dart';
import 'package:app/service/delivery/rider_job.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class DebugRider extends StatefulWidget {
  const DebugRider({super.key});

  @override
  State<DebugRider> createState() => _DebugRiderState();
}

class _DebugRiderState extends State<DebugRider> {
  @override
  void dispose() {
    DeliveryRiderJob.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    return MainLayout(
      scrollable: false,
      body: Column(
        children: [
          // Header Section with Profile
          Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Name and Status
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 6,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
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
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Text(
                          'ไม่มีสลิปรอชื่อรับอยู่',
                          style: TextStyle(
                            color: const Color(0xFF819067),
                            fontSize: 10,
                            fontFamily: 'Mali',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Profile Avatar
                ProfileWidgets.avatar(
                  isEdited: false,
                  size: ProfileSize.md,
                  imageUrl: appData.currentUser?.imagesUrl,
                  onPressed: () {
                    log("On pressed work");
                    Get.offNamed('/profile');
                  },
                ),
              ],
            ),
          ),
          // Jobs List
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
                    children: deliveryJobs
                        .where(
                          (job) => job.pickupPkgImagesUrl.isNotEmpty,
                        ) // filter out empty images
                        .map((job) {
                          return DeliverJobItem(
                            deliveryJob: job,
                            onLocationTap: (address) {
                              log('Location tapped: ${address.detail}');
                              // Handle location tap - navigate to map
                              // Get.toNamed('/map', arguments: address);
                            },
                          );
                        })
                        .toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
