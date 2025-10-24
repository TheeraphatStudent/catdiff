import '../status.dart';

class DeliveryStatDisplayItem {
  String deliveryId;
  String sendedId;
  String receiverId;
  StatusType status;

  DeliveryStatDisplayItem({
    required this.deliveryId,
    required this.sendedId,
    required this.receiverId,
    required this.status,
  });

  factory DeliveryStatDisplayItem.fromJson(Map<String, dynamic> json) {
    final statusTypes = StatusTypes();

    return DeliveryStatDisplayItem(
      sendedId: json['sended_id'] as String? ?? '',
      receiverId: json['received_id'] as String? ?? '',
      deliveryId: json['delivery_id'] as String? ?? '',
      status: statusTypes.getStatusTypeEnum(
        json['status'] as String? ?? 'pending',
      ),
    );
  }
}
