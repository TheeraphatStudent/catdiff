// To parse this JSON data, do
//
//     final userHome = userHomeFromJson(jsonString);

import 'dart:convert';

UserHome userHomeFromJson(String str) => UserHome.fromJson(json.decode(str));

String userHomeToJson(UserHome data) => json.encode(data.toJson());

class UserHome {
  String profileImageUrl;
  String name;
  String status;
  SenderObj senderObj;
  ReciverObj reciverObj;

  UserHome({
    required this.profileImageUrl,
    required this.name,
    required this.status,
    required this.senderObj,
    required this.reciverObj,
  });

  factory UserHome.fromJson(Map<String, dynamic> json) => UserHome(
    profileImageUrl: json["profile_image_url"],
    name: json["name"],
    status: json["status"],
    senderObj: SenderObj.fromJson(json["senderObj"]),
    reciverObj: ReciverObj.fromJson(json["reciverObj"]),
  );

  Map<String, dynamic> toJson() => {
    "profile_image_url": profileImageUrl,
    "name": name,
    "status": status,
    "senderObj": senderObj.toJson(),
    "reciverObj": reciverObj.toJson(),
  };
}

class ReciverObj {
  List<ReciverObjItem> items;

  ReciverObj({required this.items});

  factory ReciverObj.fromJson(Map<String, dynamic> json) => ReciverObj(
    items: List<ReciverObjItem>.from(
      json["items"].map((x) => ReciverObjItem.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "items": List<dynamic>.from(items.map((x) => x.toJson())),
  };
}

class ReciverObjItem {
  String deliveryId;
  String pickupAddressId;
  String deliveryAddressId;
  String status;
  dynamic pickupPkgImagesUrl;
  dynamic sendedPkgImgUrl;
  String sendedPkgDetail;
  dynamic pickupAt;
  dynamic deliveredAt;
  String createdAt;
  String updatedAt;

  ReciverObjItem({
    required this.deliveryId,
    required this.pickupAddressId,
    required this.deliveryAddressId,
    required this.status,
    required this.pickupPkgImagesUrl,
    required this.sendedPkgImgUrl,
    required this.sendedPkgDetail,
    required this.pickupAt,
    required this.deliveredAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReciverObjItem.fromJson(Map<String, dynamic> json) => ReciverObjItem(
    deliveryId: json["delivery_id"],
    pickupAddressId: json["pickup_address_id"],
    deliveryAddressId: json["delivery_address_id"],
    status: json["status"],
    pickupPkgImagesUrl: json["pickup_pkg_images_url"],
    sendedPkgImgUrl: json["sended_pkg_img_url"],
    sendedPkgDetail: json["sended_pkg_detail"],
    pickupAt: json["pickup_at"],
    deliveredAt: json["delivered_at"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "delivery_id": deliveryId,
    "pickup_address_id": pickupAddressId,
    "delivery_address_id": deliveryAddressId,
    "status": status,
    "pickup_pkg_images_url": pickupPkgImagesUrl,
    "sended_pkg_img_url": sendedPkgImgUrl,
    "sended_pkg_detail": sendedPkgDetail,
    "pickup_at": pickupAt,
    "delivered_at": deliveredAt,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}

class SenderObj {
  List<SenderObjItem> items;

  SenderObj({required this.items});

  factory SenderObj.fromJson(Map<String, dynamic> json) => SenderObj(
    items: List<SenderObjItem>.from(
      json["items"].map((x) => SenderObjItem.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "items": List<dynamic>.from(items.map((x) => x.toJson())),
  };
}

class SenderObjItem {
  String deliveryId;
  String pickupAddressId;
  String deliveryAddressId;
  String status;
  String pickupPkgImagesUrl;
  String sendedPkgImgUrl;
  String sendedPkgDetail;
  String pickupAt;
  dynamic deliveredAt;
  String createdAt;
  String updatedAt;

  SenderObjItem({
    required this.deliveryId,
    required this.pickupAddressId,
    required this.deliveryAddressId,
    required this.status,
    required this.pickupPkgImagesUrl,
    required this.sendedPkgImgUrl,
    required this.sendedPkgDetail,
    required this.pickupAt,
    required this.deliveredAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SenderObjItem.fromJson(Map<String, dynamic> json) => SenderObjItem(
    deliveryId: json["delivery_id"],
    pickupAddressId: json["pickup_address_id"],
    deliveryAddressId: json["delivery_address_id"],
    status: json["status"],
    pickupPkgImagesUrl: json["pickup_pkg_images_url"],
    sendedPkgImgUrl: json["sended_pkg_img_url"],
    sendedPkgDetail: json["sended_pkg_detail"],
    pickupAt: json["pickup_at"],
    deliveredAt: json["delivered_at"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "delivery_id": deliveryId,
    "pickup_address_id": pickupAddressId,
    "delivery_address_id": deliveryAddressId,
    "status": status,
    "pickup_pkg_images_url": pickupPkgImagesUrl,
    "sended_pkg_img_url": sendedPkgImgUrl,
    "sended_pkg_detail": sendedPkgDetail,
    "pickup_at": pickupAt,
    "delivered_at": deliveredAt,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}
