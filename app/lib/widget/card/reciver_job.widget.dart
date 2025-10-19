import 'dart:developer';

import 'package:app/config/theme/app_theme.dart';
import 'package:app/types/delivery/sender_showcard.dart';
import 'package:app/widget/input.widget.dart';
import 'package:app/widget/profile_img.widget.dart';
import 'package:app/widget/tag.widget.dart';
import 'package:flutter/material.dart';

class ReciverJobItem extends StatelessWidget {
  final SenderJob senderJob;
  final VoidCallback onTap;

  const ReciverJobItem({
    super.key,
    required this.senderJob,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: Offset(0, 1.50),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ProfileWidgets.avatar(
                isEdited: false,
                size: ProfileSize.sm,
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
                        text: senderJob.sendedName,
                      ),
                    ),
                    SizedBox(height: 8),
                    InputField(
                      enabled: false,
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
        ),
      ),
    );
  }
}
