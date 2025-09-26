import 'package:app/pages/auth/upload.profile.dart';
import 'package:app/widget/button.widget.dart';
import 'package:app/widget/header_card.widget.dart';
import 'package:app/widget/input.widget.dart';
import 'package:app/widget/profile_img.widget.dart';
import 'package:app/widget/stepper.widget.dart';
import 'package:app/config/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfilePreviewController extends GetxController {
  var isPreviewMode = true.obs;

  void goToEditMode() {
    Get.snackbar('แก้ไข', 'เข้าสู่โหมดแก้ไข');
  }

  void submitRegistration() {
    final uploadController = Get.find<UploadProfileController>();
    uploadController.submitRegistration();
  }
}

class ProfilePreviewPage extends StatelessWidget {
  final ProfilePreviewController controller = Get.put(
    ProfilePreviewController(),
  );

  @override
  Widget build(BuildContext context) {
    final uploadController = Get.find<UploadProfileController>();

    return Scaffold(
      backgroundColor: Color(0xFFF5F5DC),
      body: Column(
        children: [
          HeaderStepperCard(
            steps: [
              StepData(label: 'ข้อมูลผู้ใช้', active: true),
              StepData(label: 'รูปโปรไฟล์', active: true),
              StepData(label: 'ผู้ใช้ทั่วไป', active: true),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20),

                  Obx(() {
                    return ProfileWidgets.avatar(
                      isEdited: false,
                      initialImage: uploadController.uploadedImage.value,
                      size: ProfileSize.xl,
                    );
                  }),

                  SizedBox(height: 32),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InputField(
                        label: 'ชื่อ-นามสกุล:',
                        type: InputType.line,
                        hintText: uploadController.nameController.text,
                        validate: true,
                        errorText: 'Error',
                      ),
                      SizedBox(height: 24),
                      InputField(
                        label: 'เบอร์โทร:',
                        type: InputType.line,
                        hintText: uploadController.phoneController.text,
                        validate: true,
                        errorText: 'Error',
                      ),
                      SizedBox(height: 24),
                      InputField(
                        label: 'ที่อยู่ (สำหรับรับสินค้า):',
                        type: InputType.line,
                        hintText: uploadController.addressController.text,
                        validate: true,
                        errorText: 'Error',
                      ),
                    ],
                  ),
                  SizedBox(height: 60),
                ],
              ),
            ),
          ),
          _buildBottomButtons(context),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    final uploadController = Get.find<UploadProfileController>();

    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: ButtonActions(
              text: 'แก้ไข',
              variant: ButtonVariant.danger,
              icon: Icons.edit,
              iconPosition: IconPosition.left,
              onPressed: () => Get.back(),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: ButtonActions(
              text: 'สมัครเลย',
              variant: ButtonVariant.primary,
              icon: Icons.check,
              iconPosition: IconPosition.right,
              onPressed: () => uploadController.submitRegistration(),
            ),
          ),
        ],
      ),
    );
  }
}
