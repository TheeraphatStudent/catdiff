import 'dart:developer';

import 'package:app/config/theme/app_theme.dart';
import 'package:app/types/user/reciver/reciver.dart';
import 'package:app/types/user/sender/sender_showcard.dart';
import 'package:app/widget/input.widget.dart';
import 'package:app/widget/profile_img.widget.dart';
import 'package:app/widget/tag.widget.dart';
import 'package:flutter/material.dart';

class ReciverJobItem extends StatelessWidget {
  final ReciverList reciver;
  final VoidCallback onTap;
  final Function(ReciverList)? onAvatarTap;

  const ReciverJobItem({
    super.key,
    required this.reciver,
    required this.onTap,
    this.onAvatarTap,
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
                imageUrl: reciver.imageUrl,
                shape: ProfileShape.circular,
                onPressed: () {
                  onAvatarTap?.call(reciver);
                },
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 8,
                      children: [
                        Tag(color: AppColors.primary5, text: reciver.name),
                        Text(
                          reciver.phoneNumber,
                          style: TextStyle(
                            color: AppColors.primary2,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            height: 1.2,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    InputField(
                      enabled: false,
                      controller: TextEditingController(
                        text: reciver.address.detail,
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
