import 'package:app/config/theme/app_theme.dart';
import 'package:app/layout/MainLayout.dart';
import 'package:app/widget/button.widget.dart';
import 'package:app/widget/stepper.widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../config/share/app_data.dart';

class SingleTracking extends StatefulWidget {
  const SingleTracking({super.key});

  @override
  State<SingleTracking> createState() => _SingleTrackingState();
}

class _SingleTrackingState extends State<SingleTracking> {
  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);

    return MainLayout(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
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
                ButtonActions(
                  variant: ButtonVariant.danger,
                  icon: Icons.close,
                  onPressed: () {
                    Get.offNamed("/");
                  },
                ),
              ],
            ),
          ),
          Row(
            children: [
              ButtonTab(text: "ส่งหัสดุ", isActive: true),
              ButtonTab(text: "รับหัสดุ", isActive: false),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(child: Column(children: [
                  
                ],
              )),
          ),
        ],
      ),
    );
  }
}
