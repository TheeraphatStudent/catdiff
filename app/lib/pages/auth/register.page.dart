import 'package:app/widget/button.widget.dart';
import 'package:app/widget/input.widget.dart';
import 'package:flutter/material.dart';
import 'package:app/widget/header_card.widget.dart';
import 'dart:developer';
import 'package:app/config/theme/app_theme.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.gradientStatus4),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Header section
                // const HeaderCard(),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InputField(
                          label: 'ชื่อ-นามสกุล',
                          type: InputType.line,
                          hintText: 'Input',
                          validate: true,
                          errorText: 'Error',
                        ),
                        // Phone field
                        InputField(
                          label: 'เบอร์โทร',
                          type: InputType.line,
                          hintText: 'Input',
                          validate: true,
                          errorText: 'Error',
                        ),
                        InputField(
                          label: 'ที่อยู่เริ่มต้น(สำหรับสินค้า)',
                          type: InputType.line,
                          hintText: 'Input',
                          validate: true,
                          errorText: 'Error',
                        ),
                        InputField(
                          label: 'รหัสผ่าน',
                          type: InputType.line,
                          hintText: 'Input',
                          validate: true,
                          errorText: 'Error',
                        ),
                        Spacer(),

                        Row(
                          children: [
                            Expanded(
                              child: ButtonActions(
                                icon: Icons.arrow_back,
                                text: 'ก่อนหน้า',
                                variant: ButtonVariant.light,
                                iconPosition: IconPosition.left,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: ButtonActions(
                                text: 'ต่อไป',
                                variant: ButtonVariant.primary,
                                icon: Icons.arrow_forward,
                                iconPosition: IconPosition.right,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int step, String title, bool isActive) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary2 : AppColors.grayLight,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? AppColors.primary1 : AppColors.grayMedium,
              width: 2,
            ),
          ),
          child: Center(
            child: isActive
                ? Icon(Icons.person, color: AppColors.white, size: 20)
                : step == 1
                ? Icon(Icons.camera_alt, color: AppColors.grayMedium, size: 20)
                : Icon(Icons.more_horiz, color: AppColors.grayMedium, size: 20),
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isActive ? AppColors.primary1 : AppColors.grayMedium,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStepLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        margin: EdgeInsets.only(bottom: 30),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary2 : AppColors.grayMedium,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
