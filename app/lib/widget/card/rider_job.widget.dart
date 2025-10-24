import 'dart:developer';

import 'package:app/config/theme/app_theme.dart';
import 'package:app/types/address/address.dart';
import 'package:app/types/delivery/delivery_job.dart';
import 'package:app/widget/input.widget.dart';
import 'package:app/widget/profile_img.widget.dart';
import 'package:app/widget/tag.widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DeliverJobItem extends StatelessWidget {
  final DeliveryJob deliveryJob;
  final bool? isShowingMap;
  final bool? isEditableField;

  final Function(AddressInfo)? onLocationTap;
  final VoidCallback? onCardTap;

  final ProfileController? profileController;
  final Function(String)? onImageUploaded;
  final String? userId;

  const DeliverJobItem({
    super.key,
    required this.deliveryJob,
    this.isShowingMap = true,
    this.isEditableField = true,
    this.onLocationTap,
    this.onCardTap,
    this.profileController,
    this.onImageUploaded,
    this.userId,
  });

  Widget _buildManagedProfile() {
    return StatefulBuilder(
      builder: (context, setState) {
        return ProfileWidgets.managed(
          controller: profileController!,
          isEdited: true,
          shape: ProfileShape.rectangle,
          autoUpload: true,
          userId: userId,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onCardTap,
      child: Container(
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
          spacing: 10,
          children: [
            profileController != null
                ? _buildManagedProfile()
                : ProfileWidgets.avatar(
                    isEdited: false,
                    size: ProfileSize.md,
                    imageUrl: deliveryJob.pickupPkgImagesUrl.isNotEmpty
                        ? deliveryJob.pickupPkgImagesUrl
                        : null,
                    shape: ProfileShape.rectangle,
                    config: ProfileWidgetConfig(
                      // editIcon: CupertinoIcons.cube_box,
                      placeholderIcon: CupertinoIcons.cube_box,
                    ),
                  ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Tag(
                      color: AppColors.primary5,
                      text: "#${deliveryJob.deliveryId}",
                    ),
                  ),
                  SizedBox(height: 8),
                  InputField(
                    controller: TextEditingController(
                      text: deliveryJob.deliveryAddress.detail,
                    ),
                    hintText: "รายละเอียดที่อยู่ปลายทาง",
                    label: "รายละเอียดที่อยู่ปลายทาง",
                    multiline: true,
                    fontSize: FontSize.xs,
                    enabled: isEditableField == true,
                    suffixIcon: isShowingMap == true
                        ? Icon(Icons.location_on, color: AppColors.primary2)
                        : null,
                    onSuffixIconTap: () {
                      // log("On suffix icon tab work");
                      // log(deliveryJob.deliveryAddress.toString());
                      // log(deliveryJob.deliveryAddress.latitude.toString());
                      // log(deliveryJob.deliveryAddress.longtitude.toString());

                      if (isShowingMap == true) {
                        onLocationTap?.call(deliveryJob.deliveryAddress);
                      }
                    },
                  ),
                ],
              ),
            ),
            SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}
