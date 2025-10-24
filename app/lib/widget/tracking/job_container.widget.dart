import 'package:app/types/delivery/delivery_job.dart';
import 'package:app/widget/tracking/job_item.widget.dart';
import 'package:flutter/material.dart';

class JobContainerView extends StatelessWidget {
  final List<DeliveryJob> deliveryJobs;
  final String title;
  final Function(DeliveryJob)? onLocationPress;
  final DateTime? date;

  const JobContainerView({
    super.key,
    required this.deliveryJobs,
    required this.title,
    this.onLocationPress,
    this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Mali',
                  ),
                ),
                if (date != null)
                  Text(
                    "${date!.day}/${date!.month}/${date!.year}",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontFamily: 'Mali',
                    ),
                  ),
              ],
            ),
          ),
          
          // Job Count
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              "รายการสินค้า (${deliveryJobs.length} รายการ)",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontFamily: 'Mali',
              ),
            ),
          ),
          
          // Job Items List
          if (deliveryJobs.isEmpty)
            Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 8),
                    Text(
                      "ไม่มีรายการจัดส่ง",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                        fontFamily: 'Mali',
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: deliveryJobs.map((job) {
                return JobItem(
                  deliveryJob: job,
                  onLocationPress: onLocationPress ?? (job) {},
                );
              }).toList(),
            ),
          
          SizedBox(height: 8),
        ],
      ),
    );
  }
}
