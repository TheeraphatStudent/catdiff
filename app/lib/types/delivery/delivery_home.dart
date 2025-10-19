class DeliveryStatDisplayItem {
  String deliveryId;
  String sendedId;
  String receiverId;
  String status;

  DeliveryStatDisplayItem({
    required this.deliveryId,
    required this.sendedId,
    required this.receiverId,
    required this.status,
  });

  factory DeliveryStatDisplayItem.fromJson(Map<String, dynamic> json) {
    return DeliveryStatDisplayItem(
      sendedId: json['sended_id'] as String,
      receiverId: json['receiver_id'] as String,
      deliveryId: json['delivery_id'] as String,
      status: json['status'] as String,
    );
  }
}
