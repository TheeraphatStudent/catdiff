import 'package:app/config/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:app/widget/status.dart';

class TestHomeScreen extends StatefulWidget {
  TestHomeScreen({Key? key}) : super(key: key);

  @override
  State<TestHomeScreen> createState() => _TestHomeScreenState();
}

class _TestHomeScreenState extends State<TestHomeScreen> {
  final TextEditingController _sendController = TextEditingController();
  final TextEditingController _receiveController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Theeraphat chueanokkhum',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'ไรเดอร์ส่งของรวดเร็ว',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.grayMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.grayLight,
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: AppColors.grayMedium,
                    ),
                  ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // ส่งของ Card
                    _buildDeliveryCard(
                      title: 'ส่งของ',
                      placeholder: 'ใส่ที่อยู่ของคุณ',
                      controller: _sendController,
                      gradient: AppColors.gradientSender,
                      onVoicePressed: () {
                        print('Voice input for send location');
                      },
                    ),

                    const SizedBox(height: 20),

                    // รับของ Card
                    _buildDeliveryCard(
                      title: 'รับของ',
                      placeholder: 'ใส่ปลายทางของคุณ',
                      controller: _receiveController,
                      gradient: AppColors.gradientRecever,
                      onVoicePressed: () {
                        print('Voice input for receive location');
                      },
                    ),

                    const SizedBox(height: 30),

                    // Confirm Button
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryCard({
    required String title,
    required String placeholder,
    required TextEditingController controller,
    required Gradient gradient,
    required VoidCallback onVoicePressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grayMedium, width: 2),
        borderRadius: BorderRadius.circular(20),
        color: AppColors.white,
      ),
      child: Column(
        children: [
          // Title with gradient
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
          ),

          // Input Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.grayLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.grayMedium),
                    ),
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: placeholder,
                        hintStyle: const TextStyle(
                          color: AppColors.grayMedium,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Voice Button
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary5,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.grayMedium, width: 2),
                  ),
                  child: IconButton(
                    onPressed: onVoicePressed,
                    icon: const Icon(
                      Icons.play_arrow,
                      color: AppColors.primary1,
                      size: 28,
                    ),
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _sendController.dispose();
    _receiveController.dispose();
    super.dispose();
  }
}
