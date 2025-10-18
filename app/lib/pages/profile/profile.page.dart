import 'dart:developer';

import 'package:app/config/share/app_data.dart';
import 'package:app/layout/MainLayout.dart';
import 'package:app/service/auth/user.dart';
import 'package:app/types/user/user_auth.dart' as UserModel;
import 'package:app/widget/button.widget.dart';
import 'package:app/widget/input.widget.dart';
import 'package:app/widget/profile_img.widget.dart' as ProfileWidget;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class ProfileController extends GetxController {
  var isEditing = false.obs;
  var isLoading = false.obs;

  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController addressController;

  final ProfileWidget.ProfileController profileImageController =
      ProfileWidget.ProfileController();

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController();
    phoneController = TextEditingController();
    addressController = TextEditingController();
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.onClose();
  }

  void initializeWithUserData(UserModel.User? user) {
    if (user != null) {
      nameController.text = user.name;
      phoneController.text = user.phone;
      addressController.text = user.addressId;
      profileImageController.setImageUrl(user.imagesUrl);
    }
  }

  void toggleEdit() {
    isEditing.value = !isEditing.value;
  }

  void cancelEdit() {
    isEditing.value = false;
    try {
      final appData = Get.find<AppData>();
      if (appData.currentUser != null) {
        initializeWithUserData(appData.currentUser as UserModel.User);
      }
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> saveProfile() async {
    try {
      isLoading.value = true;

      final appData = Get.find<AppData>();
      final currentUser = appData.currentUser as UserModel.User?;

      if (currentUser == null) {
        Get.snackbar('ข้อผิดพลาด', 'ไม่พบข้อมูลผู้ใช้');
        return;
      }

      String? imageUrl = currentUser.imagesUrl;
      if (profileImageController.selectedFile != null) {
        final uploadResult = await profileImageController.uploadProfile(
          currentUser.userId,
        );
        if (uploadResult != null) {
          imageUrl = uploadResult;
        }
      }

      final result = await AuthService.updateUserProfileById(
        userId: currentUser.userId,
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        imagesUrl: imageUrl,
        addressId: addressController.text.trim(),
      );

      if (result['success']) {
        final updatedUser = UserModel.User(
          imagesUrl: imageUrl,
          name: nameController.text.trim(),
          userId: currentUser.userId,
          password: currentUser.password,
          phone: phoneController.text.trim(),
          addressId: addressController.text.trim(),
          role: currentUser.role,
          verhicle: currentUser.verhicle,
        );

        appData.setCurrentUserFromUserModel(updatedUser);

        isEditing.value = false;
        Get.snackbar(
          'สำเร็จ',
          result['message'] ?? 'บันทึกข้อมูลเรียบร้อยแล้ว',
        );
      } else {
        Get.snackbar(
          'ข้อผิดพลาด',
          result['message'] ?? 'เกิดข้อผิดพลาดในการบันทึกข้อมูล',
        );
      }
    } catch (e) {
      Get.snackbar(
        'ข้อผิดพลาด',
        'เกิดข้อผิดพลาดในการบันทึกข้อมูล: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late ProfileController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ProfileController());

    // Initialize with current user data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appData = Provider.of<AppData>(context, listen: false);
      if (appData.currentUser != null) {
        controller.initializeWithUserData(
          appData.currentUser as UserModel.User,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppData>(
      builder: (context, appData, child) {
        final currentUser = appData.currentUser as UserModel.User?;

        return MainLayout(
          body: Obx(
            () => SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Close button
                  Align(
                    alignment: Alignment.topRight,
                    child: SizedBox(
                      width: 52,
                      child: ButtonActions(
                        variant: ButtonVariant.danger,
                        icon: Icons.close,
                        onPressed: () {
                          Get.back();
                          Get.offNamed('/');
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  Stack(
                    children: [
                      ProfileWidget.ProfileWidgets.managed(
                        controller: controller.profileImageController,
                        isEdited: controller.isEditing.value,
                        size: ProfileWidget.ProfileSize.xl,
                        userId: currentUser?.userId,
                      ),
                      if (controller.isEditing.value)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(width: 40, height: 40),
                        ),
                    ],
                  ),

                  SizedBox(height: 60),

                  // Name Field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InputField(
                        label: 'ชื่อ-นามสกุล:',
                        type: InputType.line,
                        hintText: 'กรอกชื่อ-นามสกุล',
                        validate: false,
                        controller: controller.nameController,
                        enabled: controller.isEditing.value,
                      ),
                    ],
                  ),

                  SizedBox(height: 40),

                  // Phone Field
                  InputField(
                    label: 'เบอร์โทร:',
                    type: InputType.line,
                    hintText: 'กรอกเบอร์โทรศัพท์',
                    validate: false,
                    controller: controller.phoneController,
                    enabled: controller.isEditing.value,
                  ),

                  SizedBox(height: 40),

                  InputField(
                    label: 'ที่อยู่(สำหรับรับสินค้า):',
                    type: InputType.line,
                    hintText: 'กรอกที่อยู่',
                    validate: false,
                    controller: controller.addressController,
                    enabled: controller.isEditing.value,
                  ),

                  SizedBox(height: 40),

                  if (controller.isLoading.value)
                    CircularProgressIndicator()
                  else
                    // Buttons - เปลี่ยนตาม editing state
                    controller.isEditing.value
                        ? Row(
                            children: [
                              Expanded(
                                child: ButtonActions(
                                  variant: ButtonVariant.danger,
                                  text: "ย้อนกลับ",
                                  onPressed: controller.cancelEdit,
                                  icon: Icons.arrow_back,
                                  iconPosition: IconPosition.left,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: ButtonActions(
                                  variant: ButtonVariant.primary,
                                  text: "บันทึก",
                                  onPressed: controller.saveProfile,
                                  icon: Icons.save,
                                  iconPosition: IconPosition.right,
                                ),
                              ),
                            ],
                          )
                        : SizedBox(
                            width: 120,
                            child: ButtonActions(
                              variant: ButtonVariant.danger,
                              icon: Icons.edit,
                              iconPosition: IconPosition.left,
                              text: "แก้ไข",
                              onPressed: controller.toggleEdit,
                            ),
                          ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
