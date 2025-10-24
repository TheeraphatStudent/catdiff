import 'package:app/config/theme/app_theme.dart';
import 'package:app/types/delivery/delivery_job.dart';
import 'package:app/widget/tracking/job_item.widget.dart';
import 'package:flutter/material.dart';

class JobContainerView extends StatelessWidget {
  final List<DeliveryJob> deliveryJobs;
  final String title;
  final Function(DeliveryJob)? onLocationPress;
  final Function(List<DeliveryJob>)? onContainerPress;

  final DateTime? date;

  const JobContainerView({
    super.key,
    required this.deliveryJobs,
    required this.title,
    this.onLocationPress,
    this.onContainerPress,
    this.date,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onContainerPress?.call(deliveryJobs);
      },
      child: Container(
        margin: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.grayMedium.withValues(alpha: 0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
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

              SizedBox(height: 6),

              // Job Count
              Text(
                "รายการสินค้า (${deliveryJobs.length} รายการ)",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontFamily: 'Mali',
                ),
              ),

              Divider(),

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
            ],
          ),
        ),
      ),
    );
  }
}
