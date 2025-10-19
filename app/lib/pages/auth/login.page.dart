import 'dart:developer';

import 'package:app/config/theme/app_theme.dart';
import 'package:app/layout/MainLayout.dart';
import 'package:app/types/user/role.dart';
import 'package:app/widget/button.widget.dart';
import 'package:app/widget/input.widget.dart';
import 'package:flutter/material.dart' hide Actions;
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:app/service/auth/user.dart' as UserService;

import 'package:app/config/share/app_data.dart';
import 'package:provider/provider.dart';
import 'package:app/widget/header_card.widget.dart';
import 'package:app/types/user/user_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoginTab = true;
  UserRole _selectedRole = UserRole.user; // เพิ่มตัวแปรเก็บบทบาทที่เลือก
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _formatPhoneNumber(String value) {
    String digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length > 10) {
      digitsOnly = digitsOnly.substring(0, 10);
    }
    if (digitsOnly.length >= 7) {
      return '${digitsOnly.substring(0, 3)}-${digitsOnly.substring(3, 6)}-${digitsOnly.substring(6)}';
    } else if (digitsOnly.length >= 4) {
      return '${digitsOnly.substring(0, 3)}-${digitsOnly.substring(3)}';
    }
    return digitsOnly;
  }

  void _handleLogin() async {
    if (_phoneController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('กรุณากรอกข้อมูลให้ครบถ้วน'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('กำลังเข้าสู่ระบบ...'),
          ],
        ),
      ),
    );

    try {
      log('Login attempt: ${_phoneController.text}');

      String cleanPhone = _phoneController.text.replaceAll(
        RegExp(r'[^\d]'),
        '',
      );

      final appData = Provider.of<AppData>(context, listen: false);

      // Try user login
      final userResult = await UserService.AuthService.loginUser(
        user_id: cleanPhone,
        password: _passwordController.text,
        role: UserRole.user,
      );

      if (userResult['success']) {
        Get.back();
        final User user = userResult['user'] as User;
        appData.setCurrentUser(user);
        appData.setPreferredRole(UserRole.user);

        Get.offAllNamed('/');
        return;
      }

      // Try rider login if user login failed
      final riderResult = await UserService.AuthService.loginUser(
        user_id: cleanPhone,
        password: _passwordController.text,
        role: UserRole.rider,
      );

      if (riderResult['success']) {
        log('Rider login successful');
        Get.back();
        final User user = riderResult['user'] as User;
        appData.setCurrentUser(user);
        appData.setPreferredRole(UserRole.rider);

        Get.offAllNamed('/');
      } else {
        Get.back();
        appData.clearCurrentUser();
        // Both login attempts failed
        _showErrorDialog(
          'เข้าสู่ระบบไม่สำเร็จ',
          riderResult['message'] ?? 'เบอร์โทรหรือรหัสผ่านไม่ถูกต้อง',
        );
      }
    } catch (e) {
      Get.back();

      log('Login error: $e');
      Provider.of<AppData>(context, listen: false).clearCurrentUser();
      _showErrorDialog(
        'เกิดข้อผิดพลาด',
        'เกิดข้อผิดพลาดในการเชื่อมต่อ กรุณาลองใหม่อีกครั้ง',
      );
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [TextButton(onPressed: () => Get.back(), child: Text('ตกลง'))],
      ),
    );
  }

  void _handleRegister() {
    String roleText = _selectedRole == UserRole.user
        ? "ผู้ใช้ทั่วไป"
        : "ไรเดอร์";
    log("สมัครเป็น$roleText");

    final appData = Provider.of<AppData>(context, listen: false);
    appData.setPreferredRole(_selectedRole);

    Get.toNamed('/register');
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      scrollable: true,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Header
            HeaderCard(
              onPressed: (context) {
                switch (context) {
                  case Actions.login:
                    setState(() => _isLoginTab = true);
                    break;
                  case Actions.register:
                    setState(() => _isLoginTab = false);
                    break;
                }
              },
              activeState: () => _isLoginTab ? Actions.login : Actions.register,
            ),

            SizedBox(height: 32),

            _isLoginTab
                ? Padding(
                    padding: EdgeInsets.symmetric(horizontal: 36),
                    child: _buildLoginForm(),
                  )
                : Padding(
                    padding: EdgeInsets.symmetric(horizontal: 36),
                    child: _buildRegisterUI(),
                  ),
          ],
        ),
      ),
    );
  }

  // 🔹 ฟอร์มเข้าสู่ระบบ
  Widget _buildLoginForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 48,
      children: [
        InputField(
          hintText: '000-000-0000',
          label: 'เบอร์โทรศัพท์',
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          onChanged: (value) {
            _phoneController.text = value;
          },
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 32,
          children: [
            InputField(
              hintText: '**********',
              label: 'รหัสผ่าน',
              controller: _passwordController,
              keyboardType: TextInputType.visiblePassword,
              obscureText: true,
              onChanged: (value) {
                _passwordController.text = value;
              },
            ),
            GestureDetector(
              onTap: () => {log("On reset password work")},
              child: Text(
                'จำรหัสผ่านไม่ได้?',
                style: TextStyle(
                  color: AppColors.darkWarning,
                  fontSize: 16,
                  fontFamily: 'Mali',
                  fontWeight: FontWeight.w400,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            SizedBox(height: 32),

            ButtonActions(
              text: "เข้าสู่ระบบ",
              variant: ButtonVariant.primary,
              onPressed: _handleLogin,
            ),
          ],
        ),
      ],
    );
  }

  // 🔹 สมัครสมาชิก UI
  Widget _buildRegisterUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ButtonActions(
          text:
              "สมัครเป็น\"${_selectedRole == UserRole.user ? "ผู้ใช้ทั่วไป" : "ไรเดอร์"}\"",
          variant: ButtonVariant.secondary,
          onPressed: () => {_handleRegister()},
        ),

        SizedBox(height: 24),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: ShapeDecoration(
            color: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 10,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    _selectedRole == "ผู้ใช้ทั่วไป"
                        ? 'การใช้งาน Cat Diff ในฐานะผู้ใช้ทั่วไป'
                        : 'เมื่อเข้าร่วมเป็น Rider กับ Cat Diff ',
                    style: TextStyle(
                      color: AppColors.black,
                      fontSize: 14,
                      fontFamily: 'Mali',
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    _selectedRole == "ผู้ใช้ทั่วไป"
                        ? 'คุณจะได้รับความสะดวกสบายในการส่งของได้ทุกเวลา\nเลือกตำแหน่งรับ–ส่งผ่านแผนที่ได้อย่างแม่นยำ พร้อมมั่นใจว่าสินค้าของคุณจะถูกจัดการอย่างรวดเร็ว และปลอดภัย '
                        : 'มีระบบที่ใช้งานง่าย ช่วยให้การรับ–ส่งสินค้าเป็นเรื่องสะดวก ปลอดภัย และมั่นใจได้ว่าทุกการส่งมีการติดตามแบบเรียลไทม์ ',
                    style: TextStyle(
                      color: AppColors.primary1,
                      fontSize: 12,
                      fontFamily: 'Mali',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 96),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _roleCard(
              UserRole.user,
              "ผู้ใช้ทั่วไป",
              "lib/assets/images/user.png",
            ),
            _roleCard(
              UserRole.rider,
              "คนส่งของ",
              "lib/assets/images/rider.png",
            ),
          ],
        ),
      ],
    );
  }

  Widget _roleCard(UserRole role, String title, String assetPath) {
    bool isSelected = _selectedRole == role;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedRole = role;
          });
          // Optional: Add haptic feedback
          // HapticFeedback.lightImpact();
        },
        child: Container(
          width: 140,
          height: 160,
          decoration: BoxDecoration(
            gradient: isSelected
                ? AppColors.gradientPrimary
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.grayInsight, AppColors.grayLight],
                  ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.primary3 : AppColors.grayMedium,
              width: isSelected ? 2.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? AppColors.primary3.withOpacity(0.3)
                    : AppColors.grayMedium.withOpacity(0.2),
                spreadRadius: isSelected ? 2 : 1,
                blurRadius: isSelected ? 8 : 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 84,
                width: 84,
                // decoration: BoxDecoration(
                //   color: isSelected
                //       ? AppColors.white.withValues(alpha: 0.9)
                //       : AppColors.white,
                //   borderRadius: BorderRadius.circular(16),
                //   boxShadow: [
                //     BoxShadow(
                //       color: Colors.black.withOpacity(0.1),
                //       spreadRadius: 0,
                //       blurRadius: 4,
                //       offset: const Offset(0, 2),
                //     ),
                //   ],
                // ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    assetPath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        role == UserRole.user
                            ? Icons.person_rounded
                            : Icons.delivery_dining_rounded,
                        size: 64,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: isSelected ? 17 : 16,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? AppColors.primary1 : AppColors.grayMedium,
                  letterSpacing: 0.2,
                ),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              if (isSelected) ...[
                const SizedBox(height: 4),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.primary3,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
