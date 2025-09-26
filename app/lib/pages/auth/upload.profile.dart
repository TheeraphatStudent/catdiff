import 'package:app/pages/auth/trust.page.dart';
import 'package:app/widget/button.widget.dart';
import 'package:app/widget/header_card.widget.dart';
import 'package:app/widget/input.widget.dart';
import 'package:app/widget/profile_img.widget.dart';
import 'package:app/widget/stepper.widget.dart';
import 'package:app/config/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UploadProfileController extends GetxController {
  var isEditing = false.obs;
  var uploadedImage = Rxn<File>();
  var isPreviewMode = false.obs;

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    addressController.text =
        "41, Kham Riang, Kantharawichai District, Maha Sarakham 44150, Thailand";
  }

  void toggleEdit() {
    isEditing.value = !isEditing.value;
  }

  void cancelEdit() {
    isEditing.value = false;
  }

  void saveProfile() {
    isEditing.value = false;
    Get.snackbar('สำเร็จ', 'บันทึกข้อมูลเรียบร้อยแล้ว');
  }

  Future<void> uploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      uploadedImage.value = File(pickedFile.path);
      isPreviewMode.value = true;
      Get.snackbar('สำเร็จ', 'อัพโหลดรูปเรียบร้อยแล้ว');
    }
  }

  void goToEditMode() {
    isEditing.value = true;
  }

  void submitRegistration() {
    Get.snackbar('สำเร็จ', 'สมัครสมาชิกเรียบร้อยแล้ว');
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.onClose();
  }
}

class UploadProfilePage extends StatelessWidget {
  final UploadProfileController controller = Get.put(UploadProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5DC),
      body: Obx(
        () => Column(
          children: [
            HeaderStepperCard(
              steps: controller.isPreviewMode.value
                  ? [
                      StepData(label: 'ข้อมูลผู้ใช้', active: true),
                      StepData(label: 'รูปโปรไฟล์', active: true),
                      StepData(label: 'ผู้ใช้ทั่วไป', active: true),
                    ]
                  : [
                      StepData(label: 'ข้อมูลผู้ใช้', active: true),
                      StepData(label: 'รูปโปรไฟล์', active: true),
                      StepData(label: 'ผู้ใช้ทั่วไป', active: false),
                    ],
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 40),
                child: controller.isPreviewMode.value
                    ? _buildPreviewContent()
                    : _buildUploadContent(),
              ),
            ),

            _buildBottomButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 40),

        // ✅ ใช้ ProfileWidgets.avatar แสดงรูปที่เลือกแล้ว
        Obx(() {
          return ProfileWidgets.avatar(
            isEdited: true,
            initialImage: controller.uploadedImage.value,
            onImageSelected: (file) => controller.uploadedImage.value = file,
            size: ProfileSize.xl,
          );
        }),

        SizedBox(height: 40),

        Container(
          width: 200,
          child: ElevatedButton.icon(
            onPressed: controller.uploadImage,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF8FBC8F),
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 2,
            ),
            icon: Icon(
              Icons.file_upload_outlined,
              color: Colors.white,
              size: 20,
            ),
            label: Text(
              'อัพโหลดรูป',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ),

        SizedBox(height: 100),
      ],
    );
  }

  Widget _buildPreviewContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 40),

        Obx(() {
          return ProfileWidgets.avatar(
            isEdited: false,
            initialImage: controller.uploadedImage.value,
            size: ProfileSize.xl,
          );
        }),

        SizedBox(height: 40),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ชื่อ-นามสกุล:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey[400]!, width: 1),
                ),
              ),
              child: TextField(
                controller: controller.nameController,
                decoration: InputDecoration(
                  hintText: 'Hint text',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),

            SizedBox(height: 24),
            Text(
              'เบอร์โทร:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey[400]!, width: 1),
                ),
              ),
              child: TextField(
                controller: controller.phoneController,
                decoration: InputDecoration(
                  hintText: 'Hint text',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
                keyboardType: TextInputType.phone,
              ),
            ),

            SizedBox(height: 24),
            Text(
              'ที่อยู่ (สำหรับรับสินค้า):',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey[400]!, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ButtonActions(
                      text: 'ต่อไป',
                      variant: ButtonVariant.primary,
                      icon: Icons.arrow_forward,
                      iconPosition: IconPosition.right,
                      onPressed: () => Get.to(() => ProfilePreviewPage()),
                    ),
                  ),
                  Icon(Icons.location_on, color: Color(0xFF8FBC8F), size: 20),
                ],
              ),
            ),
          ],
        ),

        SizedBox(height: 60),
      ],
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Obx(
        () => Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: controller.isPreviewMode.value
                    ? controller.goToEditMode
                    : () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      controller.isPreviewMode.value &&
                          controller.isEditing.value
                      ? Colors.red[400]
                      : Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                    side: BorderSide(
                      color:
                          controller.isPreviewMode.value &&
                              controller.isEditing.value
                          ? Colors.red[400]!
                          : Colors.grey[300]!,
                    ),
                  ),
                  elevation: 2,
                ),
                icon: Icon(
                  controller.isPreviewMode.value && controller.isEditing.value
                      ? Icons.edit
                      : Icons.arrow_back,
                  color:
                      controller.isPreviewMode.value &&
                          controller.isEditing.value
                      ? Colors.white
                      : Colors.grey[700],
                  size: 20,
                ),
                label: Text(
                  controller.isPreviewMode.value && controller.isEditing.value
                      ? 'แก้ไข'
                      : 'ก่อนหน้า',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color:
                        controller.isPreviewMode.value &&
                            controller.isEditing.value
                        ? Colors.white
                        : Colors.grey[700],
                  ),
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  if (controller.isPreviewMode.value) {
                    controller.submitRegistration();
                  } else {
                    Get.to(() => ProfilePreviewPage());
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF8FBC8F),
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 2,
                ),
                label: Text(
                  controller.isPreviewMode.value ? 'สมัครเลย' : 'ต่อไป',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                icon: Icon(
                  controller.isPreviewMode.value
                      ? Icons.check
                      : Icons.arrow_forward,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
