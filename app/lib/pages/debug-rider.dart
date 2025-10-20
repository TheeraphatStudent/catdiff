import 'dart:developer';
import 'package:app/config/share/app_data.dart';
import 'package:app/config/theme/app_theme.dart';
import 'package:app/layout/MainLayout.dart';
// import 'package:app/types/address/address.dart';
// import 'package:app/types/delivery/delivery_home.dart';
import 'package:app/types/delivery/delivery_job.dart';
// import 'package:app/types/status.dart';
// import 'package:app/types/user/type.dart';
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
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 128,
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
                      Text(
                        'ไม่มีพัสดุจัดส่งหรือรอรับ',
                        style: TextStyle(
                          color: const Color(0xFF819067) /* Primary-Green2 */,
                          fontSize: 10,
                          fontFamily: 'Mali',
                          fontWeight: FontWeight.w400,
                        ),
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
                      // log("On preseed work");

                      Get.offNamed('/profile');
                    },
                  ),
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
                    children: deliveryJobs.map((job) {
                      return DeliverJobItem(
                        deliveryJob: job,
                        onLocationTap: (address) {
                          log('Location tapped: ${address.detail}');
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
    );
  }
}
