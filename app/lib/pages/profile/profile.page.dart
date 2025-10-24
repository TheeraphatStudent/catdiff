import 'dart:developer';

import 'package:app/config/share/app_data.dart';
import 'package:app/layout/MainLayout.dart';
import 'package:app/service/address/address_service.dart';
import 'package:app/service/auth/user.dart';
import 'package:app/types/user/user_auth.dart';
import 'package:app/widget/button.widget.dart';
import 'package:app/widget/input.widget.dart';
import 'package:app/widget/profile_img.widget.dart' as ProfileWidget;
import 'package:app/widget/sliding_up/map.widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class ProfileController extends GetxController {
  var isEditing = false.obs;
  var isLoading = false.obs;

  late TextEditingController nameController = TextEditingController();
  late TextEditingController phoneController = TextEditingController();
  late TextEditingController addressController = TextEditingController();

  final ProfileWidget.ProfileController profileImageController =
      ProfileWidget.ProfileController();

  var isMapOpen = false.obs;
  String? selectedAddressId;
  double? selectedLatitude;
  double? selectedLongitude;

  AppData? _appData;

  void setAppData(AppData appData) {
    _appData = appData;
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.onClose();
  }

  void initializeWithUserData(User? user) {
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

  void openMapSelector() {
    isMapOpen.value = true;
  }

  void closeMapSelector() {
    isMapOpen.value = false;
  }

  void handleLocationSelected(LatLng location) {
    selectedLatitude = location.latitude;
    selectedLongitude = location.longitude;
    addressController.text =
        '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}';
    closeMapSelector();
  }

  void handleAddressSelected(LatLng location, String address) {
    selectedLatitude = location.latitude;
    selectedLongitude = location.longitude;
    addressController.text = address;
    closeMapSelector();
  }

  void cancelEdit() {
    isEditing.value = false;
    selectedLatitude = null;
    selectedLongitude = null;
    selectedAddressId = null;
    isMapOpen.value = false;

    try {
      if (_appData?.currentUser != null) {
        initializeWithUserData(_appData!.currentUser);
      }
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> saveProfile() async {
    try {
      isLoading.value = true;

      if (_appData == null) {
        Get.snackbar('ข้อผิดพลาด', 'ไม่พบข้อมูลระบบ');
        return;
      }

      final currentUser = _appData!.currentUser;

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

      String addressId = currentUser.addressId;

      if (selectedLatitude != null && selectedLongitude != null) {
        try {
          final addressInfo = await AddressService.createAddress(
            latitude: selectedLatitude!,
            longitude: selectedLongitude!,
            detail: addressController.text.trim(),
          );
          addressId = addressInfo.addressId;
        } catch (e) {
          log('Error creating address: $e');
          addressId = addressController.text.trim();
        }
      } else if (addressController.text.trim().isNotEmpty) {
        addressId = addressController.text.trim();
      }

      final result = await AuthService.updateUserProfileById(
        userId: currentUser.userId,
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        imagesUrl: imageUrl,
        addressId: addressId,
      );

      if (result['success']) {
        final updatedUser = User(
          imagesUrl: imageUrl,
          name: nameController.text.trim(),
          userId: currentUser.userId,
          password: currentUser.password,
          phone: phoneController.text.trim(),
          addressId: addressId,
          role: currentUser.role,
          verhicle: currentUser.verhicle,
        );

        _appData!.setCurrentUser(updatedUser);

        selectedLatitude = null;
        selectedLongitude = null;
        selectedAddressId = null;
        isMapOpen.value = false;

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
  final ProfileController profileController = ProfileController();
  AppData _appData = AppData();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _appData = Provider.of<AppData>(context, listen: false);
      profileController.setAppData(_appData);
      if (_appData.currentUser != null) {
        profileController.initializeWithUserData(_appData.currentUser);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppData>(
      builder: (context, appData, child) {
        profileController.setAppData(appData);
        final currentUser = appData.currentUser;

        return MainLayout(
          body: Obx(
            () => SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ButtonActions(
                          variant: ButtonVariant.danger,
                          icon: Icons.logout,
                          onPressed: () {
                            AuthService.logout();
                            Get.offNamed('/');
                          },
                        ),
                        ButtonActions(
                          variant: ButtonVariant.danger,
                          icon: Icons.close,
                          onPressed: () {
                            Get.back();
                            Get.offNamed('/');
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  ProfileWidget.ProfileWidgets.managed(
                    controller: profileController.profileImageController,
                    isEdited: profileController.isEditing.value,
                    size: ProfileWidget.ProfileSize.xl,
                    userId: currentUser?.userId,
                  ),

                  SizedBox(height: 56),

                  // Name Field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InputField(
                        label: 'ชื่อ-นามสกุล:',
                        type: InputType.line,
                        hintText: 'กรอกชื่อ-นามสกุล',
                        validate: false,
                        controller: profileController.nameController,
                        enabled: profileController.isEditing.value,
                      ),
                    ],
                  ),

                  SizedBox(height: 36),

                  // Phone Field
                  InputField(
                    label: 'เบอร์โทร:',
                    type: InputType.line,
                    hintText: 'กรอกเบอร์โทรศัพท์',
                    validate: false,
                    controller: profileController.phoneController,
                    enabled: false,
                  ),

                  SizedBox(height: 36),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InputField(
                        label: 'ที่อยู่(สำหรับรับสินค้า):',
                        type: InputType.line,
                        hintText: 'กรอกที่อยู่หรือเลือกจากแผนที่',
                        validate: false,
                        controller: profileController.addressController,
                        enabled: profileController.isEditing.value,
                      ),
                      if (profileController.isEditing.value) ...[
                        SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ButtonActions(
                            variant: ButtonVariant.secondary,
                            icon: Icons.map,
                            iconPosition: IconPosition.left,
                            text: "เลือกจากแผนที่",
                            onPressed: profileController.openMapSelector,
                          ),
                        ),
                      ],
                    ],
                  ),

                  SizedBox(height: 36),

                  if (profileController.isLoading.value)
                    CircularProgressIndicator()
                  else
                    // Buttons - เปลี่ยนตาม editing state
                    profileController.isEditing.value
                        ? Row(
                            children: [
                              Expanded(
                                child: ButtonActions(
                                  variant: ButtonVariant.danger,
                                  text: "ย้อนกลับ",
                                  onPressed: profileController.cancelEdit,
                                  icon: Icons.arrow_back,
                                  iconPosition: IconPosition.left,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: ButtonActions(
                                  variant: ButtonVariant.primary,
                                  text: "บันทึก",
                                  onPressed: profileController.saveProfile,
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
                              onPressed: profileController.toggleEdit,
                            ),
                          ),

                  MapsLocationSelector(
                    isOpened: profileController.isMapOpen.value,
                    isShowingAction: false,
                    onLocationSelected:
                        profileController.handleLocationSelected,
                    onAddressSelected: profileController.handleAddressSelected,
                    onModalClosed: profileController.closeMapSelector,
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
