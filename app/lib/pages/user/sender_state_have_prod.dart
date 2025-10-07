import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
  final Color color;

  DeliveryItem({required this.homeGame, required this.color});
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
              dateTime:
                  'วันอังคาร พฤษภาคม 16 | 08:00-11\nรับได้จนถึง: 07-5-066566',
              phone: '0000',
            ),
            color: const Color(0xFFD4E7C5),
          ),
          DeliveryItem(
            homeGame: HomeGame(
              id: 'CF-001',
              title: 'กำลังส่งประชาไปไม่ใส่',
              location: 'จังหวัดอุบลราชธานี อำเภอเมือง ตำบลในเมือง',
              dateTime:
                  'วันอังคาร พฤษภาคม 16 | 08:00-11\nรับได้จนถึง: 07-5-066566',
              phone: '0000',
            ),
            color: const Color(0xFFB8D4E8),
          ),
          DeliveryItem(
            homeGame: HomeGame(
              id: 'CF-001',
              title: 'กำลังส่งประชาสำรำไปไม่ใส่',
              location: 'จังหวัดอุบลราชธานี อำเภอเมือง ตำบลในเมือง',
              dateTime:
                  'วันอังคาร พฤษภาคม 16 | 08:00-11\nรับได้จนถึง: 07-5-066566',
              phone: '0000',
            ),
            color: const Color(0xFFE8C5E5),
          ),
          DeliveryItem(
            homeGame: HomeGame(
              id: 'CF-002',
              title: 'สะโพกยอดวรราเวศีไม่ใส่',
              location: 'จังหวัดอุบลราชธานี อำเภอเมือง ตำบลในเมือง',
              dateTime:
                  'วันอังคาร พฤษภาคม 16 | 08:00-11\nรับได้จนถึง: 07-5-066566',
              phone: '0000',
            ),
            color: const Color(0xFFFFE4B5),
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
              dateTime:
                  'วันอังคาร พฤษภาคม 16 | 08:00-11\nรับได้จนถึง: 07-5-066566',
              phone: '',
            ),
            color: const Color(0xFFD4E7C5),
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
              dateTime:
                  'วันพฤหัสบดี พฤษภาคม 18 | 09:00-12\nรับได้จนถึง: 07-5-066566',
              phone: '1500',
            ),
            color: const Color(0xFFD4E7C5),
          ),
          DeliveryItem(
            homeGame: HomeGame(
              id: 'CF-006',
              title: 'รับเวชภัณฑ์ฉุกเฉิน',
              location: 'จังหวัดอุบลราชธานี อำเภอเมือง ตำบลในเมือง',
              dateTime:
                  'วันพฤหัสบดี พฤษภาคม 18 | 13:00-15\nรับได้จนถึง: 07-5-066566',
              phone: '2000',
            ),
            color: const Color(0xFFB8D4E8),
          ),
          DeliveryItem(
            homeGame: HomeGame(
              id: 'CF-007',
              title: 'รับอุปกรณ์การแพทย์',
              location: 'จังหวัดอุบลราชธานี อำเภอเมือง ตำบลในเมือง',
              dateTime:
                  'วันพฤหัสบดี พฤษภาคม 18 | 14:00-16\nรับได้จนถึง: 07-5-066566',
              phone: '1800',
            ),
            color: const Color(0xFFE8C5E5),
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
              dateTime:
                  'วันพุธ พฤษภาคม 17 | 10:00-12\nรับได้จนถึง: 07-5-066566',
              phone: '2500',
            ),
            color: const Color(0xFFFFE4B5),
          ),
          DeliveryItem(
            homeGame: HomeGame(
              id: 'CF-009',
              title: 'รับเครื่องมือทันตกรรม',
              location: 'จังหวัดอุบลราชธานี อำเภอเมือง ตำบลในเมือง',
              dateTime:
                  'วันพุธ พฤษภาคม 17 | 14:00-16\nรับได้จนถึง: 07-5-066566',
              phone: '1200',
            ),
            color: const Color(0xFFFFD4D4),
          ),
        ],
      ),
      DeliveryGroup(
        date: '2025/09/16 | 00:00 น.',
        items: [
          DeliveryItem(
            homeGame: HomeGame(
              id: 'CF-010',
              title: 'รับชุด PPE จากกรมควบคุมโรค',
              location: 'จังหวัดอุบลราชธานี อำเภอเมือง ตำบลในเมือง',
              dateTime:
                  'วันอังคาร พฤษภาคม 16 | 08:00-10\nรับได้จนถึง: 07-5-066566',
              phone: '3000',
            ),
            color: const Color(0xFFD4E7C5),
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
      backgroundColor: const Color(0xFFE8F3F5),
      body: SafeArea(
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
                  color: const Color(0xFFE8F4D9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Theeraphat chueanokkhum',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Row(
                  children: const [
                    Icon(
                      Icons.check_box_outline_blank,
                      size: 16,
                      color: Color(0xFF5CB3CC),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'CF-001',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'กำลังส่งสินค้าทางเรือไปไม่ใส่',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
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
              color: const Color(0xFFE8B4B4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.close, color: Color(0xFF8B3A3A)),
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
                    border: Border(
                      bottom: BorderSide(
                        color: controller.selectedTab.value == 0
                            ? Colors.black87
                            : Colors.black26,
                        width: controller.selectedTab.value == 0 ? 2 : 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'ส่งออก',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: controller.selectedTab.value == 0
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: controller.selectedTab.value == 0
                              ? Colors.black87
                              : Colors.black38,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward,
                        size: 20,
                        color: controller.selectedTab.value == 0
                            ? Colors.black87
                            : Colors.black38,
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
                    border: Border(
                      bottom: BorderSide(
                        color: controller.selectedTab.value == 1
                            ? Colors.black87
                            : Colors.black26,
                        width: controller.selectedTab.value == 1 ? 2 : 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'รับเข้า',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: controller.selectedTab.value == 1
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: controller.selectedTab.value == 1
                              ? Colors.black87
                              : Colors.black38,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_back,
                        size: 20,
                        color: controller.selectedTab.value == 1
                            ? Colors.black87
                            : Colors.black38,
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
        color: const Color(0xFFFFFBEE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'เมื่อ:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              Text(
                'ถึง:\n${group.items.length > 0 ? 'นายไก่แจ้' : ''}',
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ],
          ),
          Text(
            group.date,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 16),
          const Text(
            'รายการที่ส่ง:',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ...group.items.map((item) => _buildDeliveryItem(item)).toList(),
        ],
      ),
    );
  }

  Widget _buildDeliveryItem(DeliveryItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: item.color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: item.color, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: item.color,
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
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.homeGame.title,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.homeGame.dateTime,
                  style: const TextStyle(fontSize: 10, color: Colors.black54),
                ),
                Text(
                  'รับได้จนถึง: ${item.homeGame.phone}',
                  style: const TextStyle(fontSize: 10, color: Colors.black54),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                'เรียง',
                style: TextStyle(fontSize: 10, color: Colors.black54),
              ),
              Text(
                'ตำแหน่งตัวอย่างสาธิต',
                style: TextStyle(fontSize: 9, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              Text(
                'ตำแหน่งสาธิตครรภ์',
                style: TextStyle(fontSize: 9, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                item.homeGame.phone,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black26),
                ),
                child: const Icon(Icons.location_on, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              color: Color(0xFFE8DCC4),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 60,
              color: Color(0xFFB8A888),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'ยังไม่มีฟิลด์ที่กำลังส่ง',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Color(0xFFB8A888),
            ),
          ),
        ],
      ),
    );
  }
}

// Example usage
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Delivery Tracking',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Prompt'),
      home: const DeliveryTrackingScreen(),
    );
  }
}
