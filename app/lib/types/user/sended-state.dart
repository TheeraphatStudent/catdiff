// To parse this JSON data, do
//
//     final sendedCard = sendedCardFromJson(jsonString);

import 'dart:convert';

SendedCard sendedCardFromJson(String str) =>
    SendedCard.fromJson(json.decode(str));

String sendedCardToJson(SendedCard data) => json.encode(data.toJson());

class SendedCard {
  Del001 del001;

  SendedCard({required this.del001});

  factory SendedCard.fromJson(Map<String, dynamic> json) =>
      SendedCard(del001: Del001.fromJson(json["del001"]));

  Map<String, dynamic> toJson() => {"del001": del001.toJson()};
}

class Del001 {
  String? orderNumber;
  String pickupAddressUrl;
  String deliveryAddressUrl;
  String status;
  String createdAt;
  String updatedAt;
  dynamic deliveredAt;
  String pickupAt;
  Vehicle vehicle;
  String name;

  Del001({
    this.orderNumber,
    required this.pickupAddressUrl,
    required this.deliveryAddressUrl,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.deliveredAt,
    required this.pickupAt,
    required this.vehicle,
    required this.name,
  });

  factory Del001.fromJson(Map<String, dynamic> json) => Del001(
    orderNumber: json["order_number"],
    pickupAddressUrl: json["pickup_address_url"],
    deliveryAddressUrl: json["delivery_address_url"],
    status: json["status"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
    deliveredAt: json["delivered_at"],
    pickupAt: json["pickup_at"],
    vehicle: Vehicle.fromJson(json["vehicle"]),
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "order_number": orderNumber,
    "pickup_address_url": pickupAddressUrl,
    "delivery_address_url": deliveryAddressUrl,
    "status": status,
    "created_at": createdAt,
    "updated_at": updatedAt,
    "delivered_at": deliveredAt,
    "pickup_at": pickupAt,
    "vehicle": vehicle.toJson(),
    "name": name,
  };
}

class Vehicle {
  String licencePlate;
  String type;

  Vehicle({required this.licencePlate, required this.type});

  factory Vehicle.fromJson(Map<String, dynamic> json) =>
      Vehicle(licencePlate: json["licence_plate"], type: json["type"]);

  Map<String, dynamic> toJson() => {
    "licence_plate": licencePlate,
    "type": type,
  };
}
