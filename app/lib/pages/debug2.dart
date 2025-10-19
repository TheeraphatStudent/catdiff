import 'package:app/config/theme/app_theme.dart';
import 'package:app/types/delivery/sended_state_card.dart';
import 'package:app/types/status.dart';
import 'package:flutter/material.dart';

class DebugPage extends StatelessWidget {
  const DebugPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sendedCard = SendedCard(
      del001: Del001(
        pickupAddressUrl: "https://maps.google.com/?q=13.7563,100.5018",
        deliveryAddressUrl: "https://maps.google.com/?q=13.8563,100.6018",
        status: "receiving", // เปลี่ยนได้: pending, receiving, riding, success
        createdAt: "2025-09-16T00:00:00",
        updatedAt: "2025-09-16T08:30:00",
        deliveredAt: null,
        pickupAt: "2025-09-16T00:00:00Z",
        vehicle: Vehicle(licencePlate: "กข-1234", type: "motorcycle"),
        name: "Theeraphat",
      ),
    );

    return Scaffold(
      body: ListView(children: [ParcelCard(data: sendedCard.del001)]),
    );
  }
}

class ParcelCard extends StatelessWidget {
  final Del001 data;

  const ParcelCard({Key? key, required this.data}) : super(key: key);

  Color _getStatusColor(String status) {
    final statusTypes = StatusTypes();
    final statusEnum = statusTypes.getStatusTypeEnum(status);

    switch (statusEnum) {
      case StatusType.pending:
        return const Color.fromARGB(255, 255, 232, 118);
      case StatusType.receiving:
        return const Color.fromARGB(255, 245, 121, 193);
      case StatusType.riding:
        return const Color.fromARGB(255, 28, 208, 231);
      case StatusType.success:
        return const Color.fromARGB(255, 1, 236, 21);
      default:
        return const Color(0xFFFFFBE6);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusTypes = StatusTypes();
    final statusEnum = statusTypes.getStatusTypeEnum(data.status);
    final statusMeaning = statusTypes.getStatusMeaning(statusEnum);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 230, 233, 224),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // แสดงสถานะ
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'เมื่อ:',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color.fromARGB(255, 32, 37, 23),
                    ),
                  ),
                  Text(
                    '${data.pickupAt} น.',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'ถึง:',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  Text(
                    data.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black,
                      decoration: TextDecoration.underline,
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
          CardDriver(
            name: data.name,
            vehicle: data.vehicle,
            status: data.status,
          ),
        ],
      ),
    );
  }
}

class CardDriver extends StatelessWidget {
  final String name;
  final Vehicle vehicle;
  final String status;

  const CardDriver({
    Key? key,
    required this.name,
    required this.vehicle,
    required this.status,
  }) : super(key: key);

  Color _getCircleColor(String status) {
    final statusTypes = StatusTypes();
    final statusEnum = statusTypes.getStatusTypeEnum(status);
    switch (statusEnum) {
      case StatusType.pending:
        return const Color.fromARGB(255, 245, 255, 103);
      case StatusType.receiving:
        return const Color.fromARGB(255, 241, 84, 255);
      case StatusType.riding:
        return Colors.blue;
      case StatusType.success:
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final circleColor = _getCircleColor(status);

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
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: circleColor.withOpacity(0.3),
              border: Border.all(color: circleColor, width: 2),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'del001-$status\nRaider: $name\nทะเบียน: ${vehicle.licencePlate}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ประเภท: ${vehicle.type}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.grayMedium,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.grayLight),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  size: 20,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
