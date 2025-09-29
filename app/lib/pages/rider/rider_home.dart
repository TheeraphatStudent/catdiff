import 'package:flutter/material.dart';
import 'package:app/config/theme/app_theme.dart';

class RiderHome extends StatelessWidget {
  const RiderHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          'Cat Diff - ไรเดอร์',
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
              Icons.motorcycle,
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
              'เข้าสู่ระบบในฐานะไรเดอร์เรียบร้อยแล้ว',
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
                    'หน้าหลักไรเดอร์กำลังพัฒนา',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary1,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'ฟีเจอร์การรับงานและจัดการการส่งของจะเปิดให้ใช้งานเร็วๆ นี้',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.grayMedium,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatusCard('งานรอรับ', '0', Icons.pending_actions, Colors.orange),
                _buildStatusCard('กำลังส่ง', '0', Icons.local_shipping, Colors.blue),
                _buildStatusCard('เสร็จสิ้น', '0', Icons.check_circle, Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(String title, String count, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.grayMedium,
            ),
          ),
        ],
      ),
    );
  }
}