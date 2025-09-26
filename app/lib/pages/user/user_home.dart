import 'package:flutter/material.dart';
import 'package:app/config/theme/app_theme.dart';

class UserHomepage extends StatelessWidget {
  const UserHomepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          'Cat Diff - ผู้ใช้ทั่วไป',
          style: TextStyle(
            color: AppColors.primary1,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: AppColors.primary1),
            onPressed: () {
              // TODO: Navigate to profile
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.delivery_dining,
              size: 100,
              color: AppColors.primary2,
            ),
            SizedBox(height: 24),
            Text(
              'ยินดีต้อนรับสู่ Cat Diff',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary1,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'เข้าสู่ระบบในฐานะผู้ใช้ทั่วไปเรียบร้อยแล้ว',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.grayMedium,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            Container(
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: AppColors.primary2.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary2.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.construction,
                    size: 48,
                    color: AppColors.primary2,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'หน้าหลักผู้ใช้กำลังพัฒนา',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary1,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'ฟีเจอร์การส่งของและติดตามสถานะจะเปิดให้ใช้งานเร็วๆ นี้',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.grayMedium,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}