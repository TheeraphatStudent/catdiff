import 'package:app/widget/input.widget.dart';
import 'package:app/widget/profile_img.widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';

class ProfileController extends GetxController {
  var isEditing = false.obs;

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
}

class ProfilePage extends StatelessWidget {
  final ProfileController controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5DC), // สีครีม
      appBar: AppBar(
        backgroundColor: Color(0xFFF5F5DC),
        elevation: 0,
        leading: Container(), // ซ่อน back button
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16, top: 8),
            child: CircleAvatar(
              backgroundColor: Color(0xFFE8B4B4),
              radius: 20,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.red, size: 20),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
      body: Obx(
        () => SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 40),

              // Profile Avatar with edit icon when editing
              Stack(
                children: [
                  ProfileWidgets.avatar(
                    isEdited: controller.isEditing.value,
                    size: ProfileSize.xl,
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
                    hintText: 'Hint text',
                    validate: false,
                  ),
                ],
              ),

              SizedBox(height: 40),

              // Phone Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InputField(
                    label: 'เบอร์โทร:',
                    type: InputType.line,
                    hintText: 'Hint text',
                    validate: false,
                  ),
                ],
              ),

              SizedBox(height: 40),

              // Key Field with eye icon
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: InputField(
                          label: 'ทือยู่(สำหรับรับสินค้า):',
                          type: InputType.line,
                          hintText: 'Hint text',
                          validate: false,
                        ),
                      ),
                      SizedBox(width: 10),
                      Container(
                        padding: EdgeInsets.only(top: 25),
                        child: CircleAvatar(
                          backgroundColor: Colors.grey[300],
                          radius: 20,
                          child: Icon(
                            Icons.remove_red_eye_outlined,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 80),

              // Buttons - เปลี่ยนตาม editing state
              controller.isEditing.value
                  ? // Edit mode - 2 buttons
                    Row(
                      children: [
                        // Back Button (สีชมพู)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: controller.cancelEdit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFE8B4B4),
                              padding: EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              elevation: 2,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.arrow_back,
                                  color: Colors.red[400],
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'ย้อนกลับ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.red[400],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        // Save Button (สีเขียว)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: controller.saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF8FBC8F),
                              padding: EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              elevation: 2,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'ยืนยัน',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : // Normal mode - single edit button
                    Container(
                      width: 120,
                      child: ElevatedButton(
                        onPressed: controller.toggleEdit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFE8B4B4),
                          padding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 2,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.edit, color: Colors.red[400], size: 16),
                            SizedBox(width: 8),
                            Text(
                              'แก้ไข',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.red[400],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
