import 'dart:developer';
import 'package:app/config/theme/app_theme.dart';
import 'package:app/types/delivery/sender_showcard.dart';
import 'package:app/widget/input.widget.dart';
import 'package:app/widget/profile_img.widget.dart';
import 'package:app/widget/tag.widget.dart';
import 'package:flutter/material.dart';

class DeliverJobItem extends StatelessWidget {
  final SenderJob senderJob;

  const DeliverJobItem({super.key, required this.senderJob});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 1.50),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          // แสดงรูปภาพพัสดุจาก pickup_pkg_images_url
          ProfileWidgets.avatar(
            isEdited: false,
            size: ProfileSize.md,
            imageUrl: senderJob.pickupPkgImagesUrl.isNotEmpty
                ? senderJob.pickupPkgImagesUrl.first
                : "",
            shape: ProfileShape.rectangle,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // แสดง Tag delivery_id และชื่อผู้ส่ง
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ชื่อผู้ส่ง (ตามภาพคือ "นายแมวเป๋า หลอนจัด")
                    Expanded(
                      child: Text(
                        "นายแมวเป๋า หลอนจัด",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    Tag(
                      color: AppColors.primary5,
                      text: "#${senderJob.deliveryId}",
                    ),
                  ],
                ),
                SizedBox(height: 8),
                // แสดงที่อยู่ปลายทาง
                InputField(
                  controller: TextEditingController(
                    text: senderJob.deliveryAddress.detail,
                  ),
                  hintText: "ที่อยู่ปลายทางเริ่มต้น:",
                  label: "ที่อยู่ปลายทางเริ่มต้น:",
                  multiline: true,
                  fontSize: FontSize.sm,
                  readOnly: true,
                  suffixIcon: Icon(
                    Icons.location_on,
                    color: AppColors.primary2,
                  ),
                  onSuffixIconTap: () {
                    log(
                      "On suffix icon tap - Open map for: ${senderJob.deliveryAddress.detail}",
                    );
                  },
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
        ],
      ),
    );
  }
}
