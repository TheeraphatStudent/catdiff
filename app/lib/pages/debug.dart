import 'package:app/config/theme/app_theme.dart';
import 'package:app/layout/MainLayout.dart';
import 'package:app/types/delivery/sended_state_card.dart';
import 'package:app/types/status.dart';
import 'package:app/utils/status_helper.dart';
import 'package:flutter/material.dart';

class DebugPage extends StatefulWidget {
  const DebugPage({Key? key}) : super(key: key);
  @override
  State<DebugPage> createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> {
  int _selectedTab = 0;
  final List<DeliveryGroup> deliveryGroups = [
    DeliveryGroup(
      time: '00:00 น.',
      orders: [
        Del001(
          pickupAddressUrl: "https://maps.google.com/?q=13.7563,100.5018",
          deliveryAddressUrl: "https://maps.google.com/?q=13.8563,100.6018",
          status: "riding",
          createdAt: "2025-09-16T00:00:00",
          updatedAt: "2025-09-16T08:30:00",
          deliveredAt: null,
          pickupAt: "2025-09-16 00:00",
          vehicle: Vehicle(licencePlate: "กข-1234", type: "motorcycle"),
          name: "Somchai",
        ),
        Del001(
          pickupAddressUrl: "https://maps.google.com/?q=13.7563,100.5018",
          deliveryAddressUrl: "https://maps.google.com/?q=13.8563,100.6018",
          status: "receiving",
          createdAt: "2025-09-16T00:00:00",
          updatedAt: "2025-09-16T08:30:00",
          deliveredAt: null,
          pickupAt: "2025-09-16 00:00",
          vehicle: Vehicle(licencePlate: "กง-5678", type: "car"),
          name: "Manee",
        ),
      ],
    ),
    DeliveryGroup(
      time: '00.00 น.',
      orders: [
        Del001(
          pickupAddressUrl: "https://maps.google.com/?q=13.7563,100.5018",
          deliveryAddressUrl: "https://maps.google.com/?q=13.8563,100.6018",
          status: "riding",
          createdAt: "2025-09-16T00:00:00",
          updatedAt: "2025-09-16T08:30:00",
          deliveredAt: null,
          pickupAt: "2025-09-16 00:00",
          vehicle: Vehicle(licencePlate: "กข-1234", type: "motorcycle"),
          name: "Somchai",
        ),
        Del001(
          pickupAddressUrl: "https://maps.google.com/?q=13.7563,100.5018",
          deliveryAddressUrl: "https://maps.google.com/?q=13.8563,100.6018",
          status: "receiving",
          createdAt: "2025-09-16T00:00:00",
          updatedAt: "2025-09-16T08:30:00",
          deliveredAt: null,
          pickupAt: "2025-09-16 00:00",
          vehicle: Vehicle(licencePlate: "กง-5678", type: "car"),
          name: "Manee",
        ),
      ],
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return MainLayout(
      showHeader: false,
      showFooter: false,
      scrollable: false,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary5,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Theeraphat chueanokkhum',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'CF-001 - กำลังเดินทางไปส่ง',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.grayMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.lightDanger,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: AppColors.darkDanger),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTab = 0;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _selectedTab == 0
                                ? AppColors.black
                                : Colors.transparent,
                            width: 2,
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
                              fontWeight: _selectedTab == 0
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: _selectedTab == 0
                                  ? AppColors.black
                                  : AppColors.grayMedium,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward,
                            size: 16,
                            color: _selectedTab == 0
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
                    onTap: () {
                      setState(() {
                        _selectedTab = 1;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _selectedTab == 1
                                ? AppColors.black
                                : Colors.transparent,
                            width: 2,
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
                              fontWeight: _selectedTab == 2
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: _selectedTab == 1
                                  ? AppColors.black
                                  : AppColors.grayMedium,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_back,
                            size: 16,
                            color: _selectedTab == 1
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
          const SizedBox(height: 16),
          Expanded(
            child:
                _selectedTab ==
                    0 //card แสดงผล ถ้า 0 is ส่งออก 1 รับเข้า
                ? ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: deliveryGroups.length,
                    itemBuilder: (context, index) {
                      return DeliveryGroupCard(group: deliveryGroups[index]);
                    },
                  )
                : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 80,
                          color: AppColors.grayLight,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'ยังไม่มีพัสดุที่รับเข้า',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.grayMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class DeliveryGroup {
  final String time;
  final List<Del001> orders;
  DeliveryGroup({required this.time, required this.orders});
}

class DeliveryGroupCard extends StatelessWidget {
  final DeliveryGroup group;
  const DeliveryGroupCard({Key? key, required this.group}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBE6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'เมื่อ:',
                    style: TextStyle(fontSize: 12, color: AppColors.grayMedium),
                  ),
                  Text(
                    ' ${group.time}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ถึง:',
                    style: TextStyle(fontSize: 12, color: AppColors.grayMedium),
                  ),
                  const Text(
                    'ชื่อผู้รับ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'รายการที่ส่ง:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 12),
          // Card เล็กๆ ข้างใน
          ...group.orders.map((order) => OrderItemCard(data: order)),
        ],
      ),
    );
  }
}

class OrderItemCard extends StatelessWidget {
  final Del001 data;
  const OrderItemCard({Key? key, required this.data}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final statusTypes = StatusTypes();
    final statusEnum = statusTypes.getStatusTypeEnum(data.status);
    final statusMeaning = statusTypes.getStatusMeaning(statusEnum);
    // ใช้ StatusHelper แทน _getCircleColor
    final statusColors = StatusHelper.colors(statusEnum);
    final circleColor = statusColors.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // จุดสีสถานะ
          Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: circleColor.withOpacity(0.3),
              border: Border.all(color: circleColor, width: 2),
              shape: BoxShape.rectangle,
            ),
          ),
          const SizedBox(width: 12),
          // ข้อมูล
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$statusMeaning',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ไรเดอร์: ${data.name}',
                  style: const TextStyle(fontSize: 12, color: AppColors.black),
                ),
                Text(
                  'ทะเบียน: ${data.vehicle.licencePlate}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.grayMedium,
                  ),
                ),
              ],
            ),
          ),
          // ไอคอนแผนที่
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.grayLight),
            ),
            //icon
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.location_on_outlined,
                size: 20,
                color: AppColors.black,
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}
