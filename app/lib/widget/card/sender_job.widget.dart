import 'dart:developer';

import 'package:app/config/theme/app_theme.dart';
import 'package:app/types/delivery/sender_showcard.dart';
import 'package:app/widget/input.widget.dart';
import 'package:app/widget/profile_img.widget.dart';
import 'package:app/widget/tag.widget.dart';
import 'package:flutter/material.dart';

class SenderJobItem extends StatelessWidget {
  final SenderJob senderJob;

  const SenderJobItem({super.key, required this.senderJob});
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
          ProfileWidgets.avatar(
            isEdited: false,
            size: ProfileSize.md,
            imageUrl: senderJob.pickupPkgImagesUrl.first,
            shape: ProfileShape.circular,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Tag(
                    color: AppColors.primary5,
                    text: "${senderJob.sendedName}",
                  ),
                ),
                SizedBox(height: 8),
                InputField(
                  controller: TextEditingController(
                    text: senderJob.deliveryAddress.detail,
                  ),
                  hintText: "ที่อยู่ปลายทางเริ่มต้น",
                  label: "ที่อยู่ปลายทางเริ่มต้น",
                  multiline: true,
                  fontSize: FontSize.sm,
                  suffixIcon: Icon(
                    Icons.location_on,
                    color: AppColors.primary2,
                  ),
                  onSuffixIconTap: () {
                    log("On suffix icon tab work");
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
