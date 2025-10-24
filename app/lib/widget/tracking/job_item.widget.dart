import 'package:app/types/delivery/delivery_job.dart';
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
    return Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sender/Receiver Avatar
          ProfileWidgets.avatar(
            size: ProfileSize.xs,
            isEdited: false,
            imageUrl: deliveryJob.sender.imagesUrl,
          ),
          SizedBox(width: 12),
          
          // Job Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status and ID
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StatusTag(statusType: deliveryJob.status),
                    Text(
                      "ID: ${deliveryJob.deliveryId}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontFamily: 'Mali',
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
                        Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
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
      ),
    );
  }
}
