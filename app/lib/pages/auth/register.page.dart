import 'dart:io';

import 'package:app/layout/MainLayout.dart';
import 'package:app/widget/button.widget.dart';
import 'package:app/widget/input.widget.dart';
import 'package:app/widget/stepper.widget.dart';
import 'package:flutter/material.dart' hide Actions;
import 'package:app/widget/header_card.widget.dart';
import 'dart:developer';
import 'package:app/config/theme/app_theme.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class AddressLocationsProps {
  double lat;
  double lon;

  AddressLocationsProps({required this.lat, required this.lon});
}

class _RegisterPageState extends State<RegisterPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final _formKey = GlobalKey<FormState>();

  // User
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  // Address
  final _addressLocations = AddressLocationsProps(lat: 0, lon: 0);
  final _addressDetailController = TextEditingController();

  // Image
  var uploadedImage = Rxn<File>();

  bool _isPasswordVisible = false;
  int _currentStep = 0;

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
  Widget build(BuildContext context) {
    return MainLayout(
      scrollable: false,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // User header section
            HeaderStepperCard(
              steps: [
                StepData(label: 'ข้อมูลส่วนตัว', active: _currentStep == 0),
                StepData(label: 'รูปโปรไฟล์', active: _currentStep == 1),
                StepData(label: 'ผู้ใช้ทั่วไป', active: _currentStep == 2),
              ],
            ),

            // Rider header section
            HeaderStepperCard(
              steps: [
                StepData(label: 'ข้อมูลส่วนตัว', active: _currentStep == 0),
                StepData(label: 'รูปโปรไฟล์', active: _currentStep == 1),
                StepData(label: 'ยานภาหนะ', active: _currentStep == 2),
                StepData(label: 'ไรเดอร์', active: _currentStep == 3),
              ],
            ),

            Flexible(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: _buildStepContent(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return [
          InputField(
            label: 'ชื่อ-นามสกุล',
            type: InputType.line,
            hintText: 'Input',
            validate: true,
            errorText: 'Error',
            controller: _nameController,
          ),
          InputField(
            label: 'เบอร์โทร',
            type: InputType.line,
            hintText: 'Input',
            validate: true,
            errorText: 'Error',
            controller: _phoneController,
          ),
          InputField(
            label: 'ที่อยู่เริ่มต้น(สำหรับสินค้า)',
            type: InputType.line,
            hintText: 'Input',
            validate: true,
            errorText: 'Error',
            // controller: _addressController,
          ),
          InputField(
            label: 'รายละเอียดที่อยู่',
            type: InputType.line,
            hintText: 'Input',
            validate: true,
            errorText: 'Error',
            controller: _addressDetailController,
          ),
          InputField(
            label: 'รหัสผ่าน',
            type: InputType.line,
            hintText: 'Input',
            validate: true,
            errorText: 'Error',
            controller: _passwordController,
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
                  onPressed: _currentStep > 0
                      ? () => setState(() => _currentStep--)
                      : null,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: ButtonActions(
                  text: 'ต่อไป',
                  variant: ButtonVariant.primary,
                  icon: Icons.arrow_forward,
                  iconPosition: IconPosition.right,
                  onPressed: () => setState(() => _currentStep++),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
        ];
      case 1:
        return [
          Center(child: Placeholder(child: Text("State 2"))),
          Spacer(),
          Row(
            children: [
              Expanded(
                child: ButtonActions(
                  icon: Icons.arrow_back,
                  text: 'ก่อนหน้า',
                  variant: ButtonVariant.light,
                  iconPosition: IconPosition.left,
                  onPressed: () => setState(() => _currentStep--),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: ButtonActions(
                  text: 'ต่อไป',
                  variant: ButtonVariant.primary,
                  icon: Icons.arrow_forward,
                  iconPosition: IconPosition.right,
                  onPressed: () => setState(() => _currentStep++),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
        ];
      case 2:
        return [
          Center(child: Placeholder(child: Text("State 3"))),
          Spacer(),
          Row(
            children: [
              Expanded(
                child: ButtonActions(
                  icon: Icons.arrow_back,
                  text: 'ก่อนหน้า',
                  variant: ButtonVariant.light,
                  iconPosition: IconPosition.left,
                  onPressed: () => setState(() => _currentStep--),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: ButtonActions(
                  text: 'สมัครสมาชิก',
                  variant: ButtonVariant.primary,
                  onPressed: () {
                    // Handle registration
                    log('Registering...');
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
        ];
      default:
        return [];
    }
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
    _animationController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressDetailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
