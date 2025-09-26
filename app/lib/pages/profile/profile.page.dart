import 'package:app/widget/input.widget.dart';
import 'package:app/widget/profile_img.widget.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false;

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

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
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 40),

            // Profile Avatar
            ProfileWidgets.avatar(
              isEdited: true,
              size: ProfileSize.xl, // ใหญ่ขึ้น
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

            // Email Field
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

            // Bio Field with eye icon
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: InputField(
                        label: 'ที่อยู่(สำหรับรับสินค้า):',
                        type: InputType.line,
                        hintText: 'Hint text',
                        validate: false,
                      ),
                    ),
                    SizedBox(width: 10),
                    Container(
                      padding: EdgeInsets.only(top: 25),
                      child: Icon(
                        Icons.location_on,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 80),

            // Edit Button
            Container(
              width: 120,
              child: ElevatedButton(
                onPressed: _toggleEditMode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFE8B4B4), // สีชมพูอ่อน
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
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
    );
  }
}
