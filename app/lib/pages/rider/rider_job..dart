import 'package:app/config/theme/app_theme.dart';
import 'package:app/layout/MainLayout.dart';
import 'package:app/types/address/address.dart';
import 'package:app/types/delivery/delivery_job.dart';
import 'package:app/types/status.dart';
import 'package:app/widget/button.widget.dart';
import 'package:app/widget/card/rider_job.widget.dart';
import 'package:app/widget/map/map_placeholder.dart';
import 'package:app/widget/profile_img.widget.dart';
import 'package:app/widget/sliding_up/sliding_template.dart';
import 'package:app/widget/stepper.widget.dart';
import 'package:app/widget/tag.widget.dart';
import 'package:flutter/material.dart';

class RiderJobPage extends StatefulWidget {
  const RiderJobPage({super.key});

  @override
  State<RiderJobPage> createState() => _RiderJobPageState();
}

enum RidingJobState { takeJob, deliveringJob, submitJob }

class _RiderJobPageState extends State<RiderJobPage> {
  /*
  State
  1. Tack a photo
  2. Riding to sended job
  3. Tack a photo 
  */

  final RidingJobState _ridingState = RidingJobState.takeJob;

  final ProfileController _profileController = ProfileController();

  // Update realtime rider location

  // Updatte job

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Tag(color: AppColors.primary5, text: "#TEST"),
              ButtonActions(
                variant: ButtonVariant.danger,
                icon: Icons.close,
                onPressed: () {},
              ),
            ],
          ),
          StepperWidget(
            steps: [
              StepData(label: "เข้ารับสินค้า", active: true),
              StepData(label: "ดำเนินการส่ง", active: true),
              StepData(label: "ถึงปลายทาง", active: true),
            ],
          ),

          // Map view
          MapPlaceholder(),

          // Job detail
          DeliverJobItem(
            deliveryJob: DeliveryJob(
              deliveryId: "",
              status: StatusType.pending,
              pickupPkgImagesUrl: [],
              pickupAddress: AddressInfo(
                addressId: '',
                latitude: 0,
                longtitude: 0,
                detail: '',
                createdAt: '',
                updatedAt: '',
              ),
              deliveryAddress: AddressInfo(
                addressId: '',
                latitude: 0,
                longtitude: 0,
                detail: '',
                createdAt: '',
                updatedAt: '',
              ),
              sender: UserInfo(userId: '', name: '', imagesUrl: ''),
              reciver: UserInfo(userId: '', name: '', imagesUrl: ''),
              sendedPkgDetail: '',
            ),
          ),

          // Action
          _buildActions(_ridingState),

          // Upload image
          SlidingTemplate(
            children: [
              Column(
                children: [
                  Text("อัพโหลดรูปภาพ"),
                  ProfileWidgets.managed(
                    controller: _profileController,
                    isEdited: true,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActions(RidingJobState state) {
    String text = "";
    ButtonVariant variant = ButtonVariant.primary;

    switch (state) {
      case RidingJobState.takeJob:
        text = "รูปการเข้ารับสินค้า";
        break;
      case RidingJobState.deliveringJob:
        text = "กำลังจัดส่ง...";
        break;
      case RidingJobState.submitJob:
        text = "รูปการจัดส่งสินค้า";
        break;
    }

    return ButtonActions(
      variant: variant,
      icon: Icons.upload,
      text: text,
      iconPosition: IconPosition.right,
      disable: state == RidingJobState.deliveringJob,
      onPressed: () {},
    );
  }
}
