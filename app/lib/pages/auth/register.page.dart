import 'dart:io';

import 'package:app/layout/MainLayout.dart';
import 'package:app/widget/button.widget.dart';
import 'package:app/widget/input.widget.dart';
import 'package:app/widget/profile_img.widget.dart';
import 'package:app/widget/stepper.widget.dart';
import 'package:flutter/material.dart' hide Actions;
import 'package:app/widget/header_card.widget.dart';
import 'dart:developer';
import 'package:app/config/theme/app_theme.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get.dart';
import 'package:app/service/auth/user.dart' as UserService;
import 'package:app/types/role.dart';
import 'package:app/config/share/app_data.dart';
import 'package:provider/provider.dart';


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

  // Role selection
  late UserRole _selectedRole;

  // User
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  // Address
  final _addressLocations = AddressLocationsProps(lat: 0, lon: 0);
  final _addressDetailController = TextEditingController();

  // Image
  var uploadedImage = Rxn<File>();
  final ProfileController _profileController = ProfileController();

  // Vehicle (for riders)
  final _vehicleTypeController = TextEditingController();
  final _licensePlateController = TextEditingController();
  var vehicleImage = Rxn<File>();

  int _currentStep = 0;

  // Get max steps based on role
  int get _maxSteps => _selectedRole == UserRole.user ? 3 : 4;

  // Get step labels based on role
  List<StepData> get _stepLabels {
    if (_selectedRole == UserRole.user) {
      return [
        StepData(label: 'ข้อมูลส่วนตัว', active: _currentStep == 0),
        StepData(label: 'รูปโปรไฟล์', active: _currentStep == 1),
        StepData(label: 'ผู้ใช้ทั่วไป', active: _currentStep == 2),
      ];
    } else {
      return [
        StepData(label: 'ข้อมูลส่วนตัว', active: _currentStep == 0),
        StepData(label: 'รูปโปรไฟล์', active: _currentStep == 1),
        StepData(label: 'ยานพาหนะ', active: _currentStep == 2),
        StepData(label: 'ไรเดอร์', active: _currentStep == 3),
      ];
    }
  }

  @override
  void initState() {
    super.initState();
    
    final appData = Provider.of<AppData>(context, listen: false);
    _selectedRole = appData.user.role;
    
    _animationController = AnimationController( 
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    _profileController.addListener(() {
      if (mounted) {
        setState(() {
          uploadedImage.value = _profileController.selectedFile;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      scrollable: false,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            HeaderStepperCard(steps: _stepLabels),

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
      case 0: // Personal Information
        return [
          SizedBox(height: 24),
          InputField(
            label: 'ชื่อ-นามสกุล',
            type: InputType.line,
            hintText: 'กรอกชื่อ-นามสกุล',
            validate: true,
            errorText: 'กรุณากรอกชื่อ-นามสกุล',
            controller: _nameController,
          ),
          SizedBox(height: 8),
          InputField(
            label: 'เบอร์โทร',
            type: InputType.line,
            hintText: 'กรอกเบอร์โทรศัพท์',
            validate: true,
            errorText: 'กรุณากรอกเบอร์โทรศัพท์',
            controller: _phoneController,
          ),
          SizedBox(height: 8),
          InputField(
            label: 'ที่อยู่เริ่มต้น(สำหรับสินค้า)',
            type: InputType.line,
            hintText: 'กรอกที่อยู่',
            validate: true,
            errorText: 'กรุณากรอกที่อยู่',
          ),
          SizedBox(height: 8),
          InputField(
            label: 'รายละเอียดที่อยู่',
            type: InputType.line,
            hintText: 'กรอกรายละเอียดที่อยู่',
            validate: true,
            errorText: 'กรุณากรอกรายละเอียดที่อยู่',
            controller: _addressDetailController,
          ),
          SizedBox(height: 8),
          InputField(
            label: 'รหัสผ่าน',
            type: InputType.line,
            hintText: 'กรอกรหัสผ่าน',
            validate: true,
            errorText: 'กรุณากรอกรหัสผ่าน',
            controller: _passwordController,
            obscureText: true,
          ),
          Spacer(),
          _buildNavigationButtons(),
        ];
      case 1: // Profile Image
        return [
          SizedBox(height: 24),
          Text(
            'อัปโหลดรูปโปรไฟล์',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary1,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          Center(
            child: ProfileWidgets.managed(
              controller: _profileController,
              isEdited: true,
              size: ProfileSize.xl,
              shape: ProfileShape.circular,
              config: ProfileWidgetConfig.light,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'แตะเพื่อเลือกรูปภาพจากแกลเลอรี่หรือกล้อง',
            style: TextStyle(
              color: AppColors.grayMedium,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          if (_profileController.error != null) ...[
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _profileController.error!,
                      style: TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
          Spacer(),
          _buildNavigationButtons(),
        ];
      case 2: // Vehicle (for riders) or Final step (for users)
        if (_selectedRole == UserRole.rider) {
          return [
            Text(
              'ข้อมูลยานพาหนะ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary1,
              ),
            ),
            SizedBox(height: 20),
            InputField(
              label: 'ประเภทยานพาหนะ',
              type: InputType.line,
              hintText: 'เช่น มอเตอร์ไซค์, รถยนต์',
              validate: true,
              errorText: 'กรุณากรอกประเภทยานพาหนะ',
              controller: _vehicleTypeController,
            ),
            InputField(
              label: 'ทะเบียนรถ',
              type: InputType.line,
              hintText: 'กรอกทะเบียนรถ',
              validate: true,
              errorText: 'กรุณากรอกทะเบียนรถ',
              controller: _licensePlateController,
            ),
            SizedBox(height: 20),
            Text(
              'รูปภาพยานพาหนะ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary1,
              ),
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                // TODO: Implement vehicle image picker
                log('Pick vehicle image');
              },
              child: Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.grayLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.grayMedium, width: 2),
                ),
                child: vehicleImage.value != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          vehicleImage.value!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo,
                            size: 40,
                            color: AppColors.grayMedium,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'แตะเพื่อเลือกรูปภาพยานพาหนะ',
                            style: TextStyle(color: AppColors.grayMedium),
                          ),
                        ],
                      ),
              ),
            ),
            Spacer(),
            _buildNavigationButtons(),
          ];
        } else {
          // Final step for users
          return [
            Text(
              'ยืนยันข้อมูลการสมัครสมาชิก',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary1,
              ),
            ),
            SizedBox(height: 20),
            _buildSummaryCard(),
            Spacer(),
            _buildNavigationButtons(isLastStep: true),
          ];
        }
      case 3: // Final step for riders
        return [
          Text(
            'ยืนยันข้อมูลการสมัครสมาชิก',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary1,
            ),
          ),
          SizedBox(height: 20),
          _buildSummaryCard(),
          Spacer(),
          _buildNavigationButtons(isLastStep: true),
        ];
      default:
        return [];
    }
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grayLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grayMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ProfileWidgets.managed(
                controller: _profileController,
                isEdited: false,
                size: ProfileSize.sm,
                shape: ProfileShape.circular,
                config: ProfileWidgetConfig.light,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ชื่อ-นามสกุล: ${_nameController.text}',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 4),
                    Text('เบอร์โทร: ${_phoneController.text}'),
                    SizedBox(height: 4),
                    Text(
                      'ประเภท: ${_selectedRole == UserRole.user ? "ผู้ใช้ทั่วไป" : "ไรเดอร์"}',
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(
                _profileController.hasImage ? Icons.check_circle : Icons.error_outline,
                color: _profileController.hasImage ? Colors.green : Colors.orange,
                size: 16,
              ),
              SizedBox(width: 8),
              Text(
                _profileController.hasImage ? 'รูปโปรไฟล์: เลือกแล้ว' : 'รูปโปรไฟล์: ยังไม่ได้เลือก',
                style: TextStyle(
                  color: _profileController.hasImage ? Colors.green : Colors.orange,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          if (_selectedRole == UserRole.rider) ...[
            SizedBox(height: 8),
            Text('ประเภทยานพาหนะ: ${_vehicleTypeController.text}'),
            Text('ทะเบียนรถ: ${_licensePlateController.text}'),
            Row(
              children: [
                Icon(
                  vehicleImage.value != null ? Icons.check_circle : Icons.error_outline,
                  color: vehicleImage.value != null ? Colors.green : Colors.orange,
                  size: 16,
                ),
                SizedBox(width: 8),
                Text(
                  vehicleImage.value != null ? 'รูปยานพาหนะ: เลือกแล้ว' : 'รูปยานพาหนะ: ยังไม่ได้เลือก',
                  style: TextStyle(
                    color: vehicleImage.value != null ? Colors.green : Colors.orange,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavigationButtons({bool isLastStep = false}) {
    return Column(
      children: [
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
                    : () => Get.back(),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: ButtonActions(
                text: isLastStep ? 'สมัครสมาชิก' : 'ต่อไป',
                variant: ButtonVariant.primary,
                icon: isLastStep ? Icons.check : Icons.arrow_forward,
                iconPosition: IconPosition.right,
                onPressed: isLastStep ? _handleRegistration : _handleNextStep,
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
      ],
    );
  }

  void _handleNextStep() {
    if (_currentStep < _maxSteps - 1) {
      setState(() => _currentStep++);
    }
  }

  void _handleRegistration() async {
    try {
      log('Starting registration for ${_selectedRole.name}...');

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('กำลังสมัครสมาชิก...'),
            ],
          ),
        ),
      );

      // Create user account first
      final result = await UserService.AuthService.createUser(
        user_id: _nameController.text,
        phone: _phoneController.text,
        address: _addressDetailController.text,
        password: _passwordController.text,
        role: _selectedRole,
      );

      if (result['success']) {
        final userId = result['userId'] as String;
        log('User created successfully with ID: $userId');

        // Upload profile image if selected
        String? profileImageUrl;
        if (_profileController.hasImage) {
          log('Uploading profile image...');
          profileImageUrl = await _profileController.uploadProfile(userId);
          if (profileImageUrl != null) {
            log('Profile image uploaded successfully: $profileImageUrl');
          } else {
            log('Failed to upload profile image');
          }
        }

        // Close loading dialog
        Navigator.of(context).pop();

        // Show success dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('สำเร็จ!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('สมัครสมาชิกเรียบร้อยแล้ว'),
                if (profileImageUrl != null)
                  Text('✓ อัปโหลดรูปโปรไฟล์สำเร็จ')
                else if (_profileController.hasImage)
                  Text('⚠ อัปโหลดรูปโปรไฟล์ไม่สำเร็จ'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  if (_selectedRole == UserRole.user) {
                    Get.offAllNamed('/user');
                  } else {
                    Get.offAllNamed('/rider');
                  }
                },
                child: Text('เข้าสู่แอป'),
              ),
            ],
          ),
        );
      } else {
        // Close loading dialog
        Navigator.of(context).pop();
        
        // Show error dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.error, color: Colors.red),
                SizedBox(width: 8),
                Text('เกิดข้อผิดพลาด'),
              ],
            ),
            content: Text(result['message'] ?? 'ไม่สามารถสมัครสมาชิกได้'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('ตกลง'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if open
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
      
      log('Registration error: $e');
      
      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 8),
              Text('เกิดข้อผิดพลาด'),
            ],
          ),
          content: Text('เกิดข้อผิดพลาดในการเชื่อมต่อ กรุณาลองใหม่อีกครั้ง'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('ตกลง'),
            ),
          ],
        ),
      );
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
    _vehicleTypeController.dispose();
    _licensePlateController.dispose();
    _profileController.dispose();
    super.dispose();
  }
}
