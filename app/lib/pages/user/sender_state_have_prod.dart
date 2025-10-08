import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/config/theme/app_theme.dart';

// Model
class HomeGame {
  String id;
  String title;
  String location;
  String dateTime;
  String phone;

  HomeGame({
    required this.id,
    required this.title,
    required this.location,
    required this.dateTime,
    required this.phone,
  });

  factory HomeGame.fromJson(Map<String, dynamic> json) => HomeGame(
    id: json["id"],
    title: json["title"],
    location: json["location"],
    dateTime: json["dateTime"],
    phone: json["phone"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "location": location,
    "dateTime": dateTime,
    "phone": phone,
  };
}

class DeliveryItem {
  final HomeGame homeGame;
  final LinearGradient gradient;

  DeliveryItem({required this.homeGame, required this.gradient});
}

class DeliveryGroup {
  final String date;
  final List<DeliveryItem> items;

  DeliveryGroup({required this.date, required this.items});
}

// Controller
class DeliveryController extends GetxController {
  var selectedTab = 0.obs; // 0 = ส่งออก, 1 = รับเข้า
  var deliveryGroups = <DeliveryGroup>[].obs;
  var receiveGroups = <DeliveryGroup>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadDeliveries();
    loadReceives();
  }

  void switchTab(int index) {
    selectedTab.value = index;
  }

  void loadDeliveries() {
    // Simulate loading data for ส่งออก
    deliveryGroups.value = [
      DeliveryGroup(
        date: '2025/09/16 | 00:00 น.',
        items: [
          DeliveryItem(
            homeGame: HomeGame(
              id: 'CF-001',
              title: 'โรงพยาบาลส่งเสริมสุขภาพตำบล',
              location: 'จังหวัดอุบลราชธานี อำเภอเมือง ตำบลในเมือง',
              dateTime: 'วันอังคาร พฤษภาคม 16 | 08:00-11',
              phone: '0000',
            ),
            gradient: AppColors.gradientStatus4,
          ),
          DeliveryItem(
            homeGame: HomeGame(
              id: 'CF-001',
              title: 'กำลังส่ง',
              location: 'จังหวัดอุบลราชธานี อำเภอเมือง ตำบลในเมือง',
              dateTime: 'วันอังคาร พฤษภาคม 16 | 08:00-11',
              phone: '0000',
            ),
            gradient: AppColors.gradientStatus2,
          ),
          DeliveryItem(
            homeGame: HomeGame(
              id: 'CF-001',
              title: 'กำลังส่ง',
              location: 'จังหวัดอุบลราชธานี อำเภอเมือง ตำบลในเมือง',
              dateTime: 'วันอังคาร พฤษภาคม 16 | 08:00-11',
              phone: '0000',
            ),
            gradient: AppColors.gradientStatus3,
          ),
          DeliveryItem(
            homeGame: HomeGame(
              id: 'CF-002',
              title: 'ไปส่ง',
              location: 'จังหวัดอุบลราชธานี อำเภอเมือง ตำบลในเมือง',
              dateTime: 'วันอังคาร พฤษภาคม 16 | 08:00-11',
              phone: '0000',
            ),
            gradient: AppColors.gradientStatus1,
          ),
        ],
      ),
      DeliveryGroup(
        date: '2025/09/16 | 00:00 น.',
        items: [
          DeliveryItem(
            homeGame: HomeGame(
              id: 'CF-004',
              title: 'โรงพยาบาลส่งเสริมสุขภาพตำบล',
              location: 'จังหวัดอุบลราชธานี อำเภอเมือง ตำบลในเมือง',
              dateTime: 'วันอังคาร พฤษภาคม 16 | 08:00-11',
              phone: '',
            ),
            gradient: AppColors.gradientStatus4,
          ),
        ],
      ),
      DeliveryGroup(date: '2025/09/16 | 00:00 น.', items: []),
    ];
  }

  void loadReceives() {
    // Simulate loading data for รับเข้า
    receiveGroups.value = [
      DeliveryGroup(
        date: '2025/09/18 | 00:00 น.',
        items: [
          DeliveryItem(
            homeGame: HomeGame(
              id: 'CF-005',
              title: 'รับวัคซีนจากโรงพยาบาลกลาง',
              location: 'จังหวัดอุบลราชธานี อำเภอเมือง ตำบลในเมือง',
              dateTime: 'วันพฤหัสบดี พฤษภาคม 18 | 09:00-12',
              phone: '1500',
            ),
            gradient: AppColors.gradientStatus4,
          ),
          DeliveryItem(
            homeGame: HomeGame(
              id: 'CF-006',
              title: 'รับเวชภัณฑ์ฉุกเฉิน',
              location: 'จังหวัดอุบลราชธานี อำเภอเมือง ตำบลในเมือง',
              dateTime: 'วันพฤหัสบดี พฤษภาคม 18 | 13:00-15',
              phone: '2000',
            ),
            gradient: AppColors.gradientStatus2,
          ),
          DeliveryItem(
            homeGame: HomeGame(
              id: 'CF-007',
              title: 'รับอุปกรณ์การแพทย์',
              location: 'จังหวัดอุบลราชธานี อำเภอเมือง ตำบลในเมือง',
              dateTime: 'วันพฤหัสบดี พฤษภาคม 18 | 14:00-16',
              phone: '1800',
            ),
            gradient: AppColors.gradientStatus3,
          ),
        ],
      ),
      DeliveryGroup(
        date: '2025/09/17 | 00:00 น.',
        items: [
          DeliveryItem(
            homeGame: HomeGame(
              id: 'CF-008',
              title: 'รับยาจากคลังกลาง',
              location: 'จังหวัดอุบลราชธานี อำเภอเมือง ตำบลในเมือง',
              dateTime: 'วันพุธ พฤษภาคม 17 | 10:00-12',
              phone: '2500',
            ),
            gradient: AppColors.gradientStatus1,
          ),
          DeliveryItem(
            homeGame: HomeGame(
              id: 'CF-009',
              title: 'รับเครื่องมือทันตกรรม',
              location: 'จังหวัดอุบลราชธานี อำเภอเมือง ตำบลในเมือง',
              dateTime: 'วันพุธ พฤษภาคม 17 | 14:00-16',
              phone: '1200',
            ),
            gradient: AppColors.gradientStatus2,
          ),
        ],
      ),
    ];
  }
}

// Main Screen
class DeliveryTrackingScreen extends StatelessWidget {
  const DeliveryTrackingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DeliveryController controller = Get.put(DeliveryController());

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradientPrimary),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              _buildTabs(),
              Expanded(
                child: Obx(() {
                  final groups = controller.selectedTab.value == 0
                      ? controller.deliveryGroups.value
                      : controller.receiveGroups.value;

                  if (groups.isEmpty) {
                    return _buildEmptyState();
                  }
                  return _buildDeliveryList(groups);
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.lightWarning,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Theeraphat chueanokkhum',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.black,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_box_outline_blank,
                      size: 14,
                      color: AppColors.darkOcean,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'CF-001',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'กำลังส่งสินค้า',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.grayMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.lightDanger,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.close, color: AppColors.darkDanger, size: 20),
              onPressed: () => Get.back(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    final DeliveryController controller = Get.find<DeliveryController>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(
        () => Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => controller.switchTab(0),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient: controller.selectedTab.value == 0
                        ? AppColors.gradientSender
                        : null,
                    border: Border(
                      bottom: BorderSide(
                        color: controller.selectedTab.value == 0
                            ? Colors.transparent
                            : AppColors.grayMedium,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'ส่งออก',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: controller.selectedTab.value == 0
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: controller.selectedTab.value == 0
                              ? AppColors.black
                              : AppColors.grayMedium,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward,
                        size: 18,
                        color: controller.selectedTab.value == 0
                            ? AppColors.black
                            : AppColors.grayMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => controller.switchTab(1),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient: controller.selectedTab.value == 1
                        ? AppColors.gradientRecever
                        : null,
                    border: Border(
                      bottom: BorderSide(
                        color: controller.selectedTab.value == 1
                            ? Colors.transparent
                            : AppColors.grayMedium,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'รับเข้า',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: controller.selectedTab.value == 1
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: controller.selectedTab.value == 1
                              ? AppColors.black
                              : AppColors.grayMedium,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_back,
                        size: 18,
                        color: controller.selectedTab.value == 1
                            ? AppColors.black
                            : AppColors.grayMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryList(List<DeliveryGroup> groups) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return _buildDeliveryGroup(group);
      },
    );
  }

  Widget _buildDeliveryGroup(DeliveryGroup group) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'เมื่อ:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
              Text(
                'ถึง:\n${group.items.isNotEmpty ? 'นายไก่แจ้' : ''}',
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 11, color: AppColors.black),
              ),
            ],
          ),
          Text(
            group.date,
            style: TextStyle(fontSize: 11, color: AppColors.grayMedium),
          ),
          const SizedBox(height: 12),
          Text(
            'รายการที่ส่ง:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 8),
          ...group.items.map((item) => _buildDeliveryItem(item)).toList(),
        ],
      ),
    );
  }

  Widget _buildDeliveryItem(DeliveryItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: item.gradient,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.grayMedium, width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: _getColorFromGradient(item.gradient),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item.homeGame.id,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item.homeGame.title,
                        style: TextStyle(fontSize: 11, color: AppColors.black),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.homeGame.dateTime,
                  style: TextStyle(fontSize: 9, color: AppColors.grayMedium),
                ),
                Text(
                  'รับได้จนถึง: ${item.homeGame.phone}',
                  style: TextStyle(fontSize: 9, color: AppColors.grayMedium),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'เรียง',
                style: TextStyle(fontSize: 9, color: AppColors.grayMedium),
              ),
              Text(
                'ตำแหน่งตัวอย่างสาธิต',
                style: TextStyle(fontSize: 8, color: AppColors.grayMedium),
                textAlign: TextAlign.center,
              ),
              Text(
                'ตำแหน่งสาธิตครรภ์',
                style: TextStyle(fontSize: 8, color: AppColors.grayMedium),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                item.homeGame.phone,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.grayMedium, width: 1),
                ),
                child: Icon(
                  Icons.location_on,
                  size: 16,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getColorFromGradient(LinearGradient gradient) {
    // Return the first opaque color from the gradient
    return gradient.colors.firstWhere(
      (color) => color.opacity > 0.5,
      orElse: () => gradient.colors.first,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.grayLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 50,
              color: AppColors.grayMedium,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'ยังไม่มีฟิลด์ที่กำลังส่ง',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.grayMedium,
            ),
          ),
        ],
      ),
    );
  }
}
