import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoginTab = true;
  String _selectedRole = "ผู้ใช้ทั่วไป"; // เพิ่มตัวแปรเก็บบทบาทที่เลือก
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

  void _handleLogin() {
    if (_phoneController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('กรุณากรอกข้อมูลให้ครบถ้วน'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    print(
      'Login attempt: ${_phoneController.text}, ${_passwordController.text}',
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('กำลังเข้าสู่ระบบ...'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _handleRegister() {
    print("สมัครเป็น$_selectedRole");
    // เพิ่มโค้ดการสมัครสมาชิกตามบทบาทที่เลือก
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8F9FA), Color(0xFFE8F5E8), Color(0xFFD4E8D4)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Header
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(30, 40, 30, 20),
                    child: Column(
                      children: [
                        // Image.asset("assets/cat_bike.png", height: 80),
                        SizedBox(height: 20),

                        // Tabs
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _isLoginTab = true),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: _isLoginTab
                                            ? Colors.green
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    'เข้าสู่ระบบ',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: _isLoginTab
                                          ? Colors.green
                                          : Colors.grey,
                                      fontWeight: _isLoginTab
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _isLoginTab = false),
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: !_isLoginTab
                                            ? Colors.green
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    'สมัครสมาชิก',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: !_isLoginTab
                                          ? Colors.green
                                          : Colors.grey,
                                      fontWeight: !_isLoginTab
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(20),
                    child: _isLoginTab ? _buildLoginForm() : _buildRegisterUI(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🔹 ฟอร์มเข้าสู่ระบบ
  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'เบอร์โทร:',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d\-]')),
            LengthLimitingTextInputFormatter(12),
            TextInputFormatter.withFunction((oldValue, newValue) {
              String newText = newValue.text.replaceAll('-', '');
              if (newText.length <= 10) {
                String formatted = _formatPhoneNumber(newText);
                return TextEditingValue(
                  text: formatted,
                  selection: TextSelection.collapsed(offset: formatted.length),
                );
              }
              return oldValue;
            }),
          ],
          decoration: InputDecoration(
            hintText: '000-000-0000',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),

        SizedBox(height: 25),

        Text(
          'รหัสผ่าน:',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: '••••••••',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),

        SizedBox(height: 30),

        ElevatedButton(
          onPressed: _handleLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            minimumSize: Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text("เข้าสู่ระบบ"),
        ),
      ],
    );
  }

  // 🔹 สมัครสมาชิก UI
  Widget _buildRegisterUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: _handleRegister,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFDFFFD6),
            foregroundColor: Colors.black,
            minimumSize: Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text("สมัครเป็น$_selectedRole"), // ใช้ตัวแปร _selectedRole
        ),
        SizedBox(height: 20),

        Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            _selectedRole == "ผู้ใช้ทั่วไป"
                ? "การใช้งาน Cat Diff ในฐานะผู้ใช้ทั่วไป\n\n"
                      "คุณจะได้รับความสะดวกสบายในการสั่งของได้ทุกเวลา\n"
                      "เลือกสินค้าง่าย ส่งสินค้าปลอดภัยตรงเวลา\n"
                      "พร้อมมั่นใจว่ามีทีมจัดการขนส่งที่รวดเร็วและปลอดภัย"
                : "การใช้งาน Cat Diff ในฐานะคนส่งของ\n\n"
                      "คุณจะได้รับรายได้เสริมจากการส่งของ\n"
                      "เลือกงานได้ตามเวลาที่สะดวก\n"
                      "ระบบจัดการเส้นทางอัตโนมัติ เพิ่มประสิทธิภาพในการขนส่ง",
            style: TextStyle(fontSize: 14, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
        ),

        SizedBox(height: 30),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _roleCard("ผู้ใช้ทั่วไป", "assets/cat_user.png"),
            _roleCard("คนส่งของ", "assets/cat_rider.png"),
          ],
        ),
      ],
    );
  }

  Widget _roleCard(String title, String asset) {
    bool isSelected = _selectedRole == title; // ตรวจสอบว่าเลือกหรือไม่

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = title; // เปลี่ยนบทบาทที่เลือก
        });
      },
      child: Container(
        width: 140,
        height: 160,
        decoration: BoxDecoration(
          color: isSelected
              ? Colors
                    .green
                    .shade200 // สีเข้มขึ้นเมื่อถูกเลือก
              : Colors.green.shade50,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(
                  color: Colors.green,
                  width: 2,
                ) // เพิ่มขอบเมื่อถูกเลือก
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image.asset(asset, height: 80),
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                title == "ผู้ใช้ทั่วไป" ? Icons.person : Icons.delivery_dining,
                size: 40,
                color: isSelected
                    ? Colors.green.shade700
                    : Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? Colors.green.shade700 : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
