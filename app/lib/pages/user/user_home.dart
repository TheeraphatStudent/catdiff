import 'package:app/config/theme/app_theme.dart';
import 'package:app/types/status.dart';
import 'package:flutter/material.dart';
import 'package:app/widget/status.dart';

class DeliveryHome {
  List<Map> getDeliveryMockDataFormFirebase() {
    return [
      {
        "profileImageUrl": "https://cataas.com/cat",
        "name": "Alice Johnson",
        "status": "pending",
        "delivery_id": "DEL12345",
        "pickup_address_id": "ADDR1001",
        "delivery_address_id": "ADDR2001",
        "pickup_pkg_images_url": [
          "https://example.com/packages/pkg1_img1.png",
          "https://example.com/packages/pkg1_img2.png",
        ],
        "created_at": "2025-09-29T10:15:00Z",
        "updated_at": "2025-09-29T11:00:00Z",
        "delivered_at": null,
        "pickup_at": null,
        "sended_pkg_detail": "Small box, fragile",
        "sended_pkg_img_url": "https://example.com/packages/pkg1_main.png",
      },
      {
        "profileImageUrl": "https://example.com/images/user2.png",
        "name": "Michael Smith",
        "status": "riding",
        "delivery_id": "DEL67890",
        "pickup_address_id": "ADDR1002",
        "delivery_address_id": "ADDR2002",
        "pickup_pkg_images_url": ["https://example.com/packages/pkg2_img1.png"],
        "created_at": "2025-09-28T08:00:00Z",
        "updated_at": "2025-09-28T12:30:00Z",
        "delivered_at": "2025-09-28T12:00:00Z",
        "pickup_at": "2025-09-28T09:00:00Z",
        "sended_pkg_detail": "Medium parcel, electronics",
        "sended_pkg_img_url": "https://example.com/packages/pkg2_main.png",
      },
    ];
  }
}

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _sendController = TextEditingController();
  final TextEditingController _receiveController = TextEditingController();
  final DeliveryHome _deliveryHome = DeliveryHome();

  int _selectedDeliveryIndex = 0;
  List<Map> _deliveryData = [];

  @override
  void initState() {
    super.initState();
    _loadDeliveryData();
  }

  void _loadDeliveryData() {
    _deliveryData = _deliveryHome.getDeliveryMockDataFormFirebase();
    if (_deliveryData.isNotEmpty && _deliveryData.length >= 2) {
      // Card บน (ส่งของ) - ใช้ข้อมูลจาก index 0 กับ StatusSender
      StatusType sendStatus = _getStatusTypeFromString(
        _deliveryData[0]['status'],
      );
      String senderStatus = StatusSender.typeStatusTag[sendStatus]?.label ?? '';
      _sendController.text = senderStatus;

      // Card ล่าง (รับของ) - ใช้ข้อมูลจาก index 1 กับ StatusGetProduct
      StatusType receiveStatus = _getStatusTypeFromString(
        _deliveryData[1]['status'],
      );
      String receiverStatus =
          StatusGetProduct.typeStatusTag[receiveStatus]?.label ?? '';
      _receiveController.text = receiverStatus;
    }
    setState(() {});
  }

  StatusType _getStatusTypeFromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return StatusType.pending;
      case 'receiving':
        return StatusType.receiving;
      case 'riding':
        return StatusType.riding;
      case 'success':
        return StatusType.success;
      default:
        return StatusType.pending;
    }
  }

  void _changeDelivery(int index) {
    setState(() {
      _selectedDeliveryIndex = index;

      if (_deliveryData.length >= 2) {
        // Card บน (ส่งของ) - ใช้ข้อมูลจาก index 0 กับ StatusSender
        StatusType sendStatus = _getStatusTypeFromString(
          _deliveryData[0]['status'],
        );
        String senderStatus =
            StatusSender.typeStatusTag[sendStatus]?.label ?? '';
        _sendController.text = senderStatus;

        // Card ล่าง (รับของ) - ใช้ข้อมูลจาก index 1 กับ StatusGetProduct
        StatusType receiveStatus = _getStatusTypeFromString(
          _deliveryData[1]['status'],
        );
        String receiverStatus =
            StatusGetProduct.typeStatusTag[receiveStatus]?.label ?? '';
        _receiveController.text = receiverStatus;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // ดึงข้อมูลผู้ใช้งานปัจจุบัน
    String userName = _deliveryData.isNotEmpty
        ? _deliveryData[_selectedDeliveryIndex]['name'] ??
              'Theeraphat chueanokkhum'
        : 'Theeraphat chueanokkhum';

    String userRole = _deliveryData.isNotEmpty
        ? 'ID: ${_deliveryData[_selectedDeliveryIndex]['delivery_id']}'
        : 'ไรเดอร์ส่งของรวดเร็ว';

    String? profileImageUrl = _deliveryData.isNotEmpty
        ? _deliveryData[_selectedDeliveryIndex]['profileImageUrl']
        : null;

    // ดึงข้อมูลสถานะ
    StatusType currentStatus = _deliveryData.isNotEmpty
        ? _getStatusTypeFromString(
            _deliveryData[_selectedDeliveryIndex]['status'],
          )
        : StatusType.pending;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section - แสดงข้อมูลผู้ใช้งาน
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userRole,
                          style: const TextStyle(
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
                    backgroundImage: profileImageUrl != null
                        ? NetworkImage(profileImageUrl)
                        : null,
                    child: profileImageUrl == null
                        ? const Icon(
                            Icons.person,
                            size: 40,
                            color: AppColors.grayMedium,
                          )
                        : null,
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

                    // ส่งของ Card (บน) - ใช้ข้อมูลจาก index 0 กับ StatusSender
                    _buildDeliveryCard(
                      title: 'ส่งของ',
                      placeholder: 'ใส่ที่อยู่ของคุณ',
                      controller: _sendController,
                      gradient: AppColors.gradientSender,
                      onVoicePressed: () {
                        // ใช้โมเดล StatusSender จาก index 0
                        if (_deliveryData.isNotEmpty) {
                          StatusType sendStatus = _getStatusTypeFromString(
                            _deliveryData[0]['status'],
                          );
                          String statusLabel =
                              StatusSender.typeStatusTag[sendStatus]?.label ??
                              '';
                          print('Voice input for send location');
                          print(
                            'StatusSender (${_deliveryData[0]['status']}): $statusLabel',
                          );
                          print('Sender: ${_deliveryData[0]['name']}');
                          print(
                            'Pickup Address: ${_deliveryData[0]['pickup_address_id']}',
                          );
                          print(
                            'Package Detail: ${_deliveryData[0]['sended_pkg_detail']}',
                          );
                        }
                      },
                    ),

                    const SizedBox(height: 20),

                    // รับของ Card (ล่าง) - ใช้ข้อมูลจาก index 1 กับ StatusGetProduct
                    _buildDeliveryCard(
                      title: 'รับของ',
                      placeholder: 'ใส่ปลายทางของคุณ',
                      controller: _receiveController,
                      gradient: AppColors.gradientRecever,
                      onVoicePressed: () {
                        // ใช้โมเดล StatusGetProduct จาก index 1
                        if (_deliveryData.length >= 2) {
                          StatusType receiveStatus = _getStatusTypeFromString(
                            _deliveryData[1]['status'],
                          );
                          String statusLabel =
                              StatusGetProduct
                                  .typeStatusTag[receiveStatus]
                                  ?.label ??
                              '';
                          print('Voice input for receive location');
                          print(
                            'StatusGetProduct (${_deliveryData[1]['status']}): $statusLabel',
                          );
                          print('Receiver: ${_deliveryData[1]['name']}');
                          print(
                            'Delivery Address: ${_deliveryData[1]['delivery_address_id']}',
                          );
                          print(
                            'Delivered At: ${_deliveryData[1]['delivered_at']}',
                          );
                        }
                      },
                    ),

                    const SizedBox(height: 30),

                    // ปุ่มสลับ Delivery (สำหรับทดสอบ)
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
