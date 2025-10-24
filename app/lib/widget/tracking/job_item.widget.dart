import 'package:app/config/theme/app_theme.dart';
import 'package:app/types/delivery/delivery_job.dart';
import 'package:app/types/status.dart';
import 'package:app/widget/profile_img.widget.dart';
import 'package:app/widget/status/status_tag.widget.dart';
import 'package:flutter/material.dart';

class JobItem extends StatelessWidget {
  final DeliveryJob deliveryJob;
  final Function(DeliveryJob) onLocationPress;

  const JobItem({
    super.key,
    required this.deliveryJob,
    required this.onLocationPress,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        // Rider
        Column(
          children: [
            ProfileWidgets.avatar(
              size: ProfileSize.xs,
              shape: ProfileShape.rectangle,
              config: ProfileWidgetConfig(
                placeholderIcon: Icons.inbox_outlined,
                placeholderIconColor: AppColors.primary2,
              ),
              isEdited: false,
              imageUrl: deliveryJob.pickupPkgImagesUrl.isNotEmpty
                  ? deliveryJob.pickupPkgImagesUrl[0]
                  : '',
            ),
            // Text(
            //   deliveryJob.rider.name,
            //   style: TextStyle(
            //     fontSize: 12,
            //     fontWeight: FontWeight.w500,
            //     fontFamily: 'Mali',
            //   ),
            // ),
          ],
        ),

        // Job Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status and ID
              Row(
                spacing: 4,
                children: [
                  StatusTag(statusType: deliveryJob.status),
                  Text(
                    deliveryJob.deliveryId,
                    style: TextStyle(
                      color: AppColors.primary2 /* Primary-Green2 */,
                      fontSize: 12,
                      fontFamily: 'Mali',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '- ${StatusTypes().getStatusMeaning(deliveryJob.status)}',
                    style: TextStyle(
                      color: AppColors.primary2 /* Primary-Green2 */,
                      fontSize: 12,
                      fontFamily: 'Mali',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),

              // Sender Info
              Text(
                "ผู้ส่ง: ${deliveryJob.sender.name}",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Mali',
                ),
              ),
              SizedBox(height: 4),

              // Receiver Info
              Text(
                "ผู้รับ: ${deliveryJob.reciver.name}",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Mali',
                ),
              ),
              SizedBox(height: 8),

              // Delivery Address
              GestureDetector(
                onTap: () => onLocationPress(deliveryJob),
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          deliveryJob.deliveryAddress.detail,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                            fontFamily: 'Mali',
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
