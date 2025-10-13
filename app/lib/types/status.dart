import 'dart:convert';
// [1] รอไรเดอร์มารับสินค้า (pending)
// [2] ไรเดอร์รับงาน (กำลังเดินทางมารับสินค้า) (receiving)
// [3] ไรเดอร์รับสินค้าแล้วและกำลังเดินทางไปส่ง (riding)
// [4] ไรเดอร์นำส่งสินค้าแล้ว (success)

enum StatusType { pending, receiving, riding, success }

// { <Status_fill> }
Statustype StatustypeFromJson(String str) =>
    Statustype.fromJson(json.decode(str));
String StatustypeToJson(Statustype data) => json.encode(data.toJson());

class Statustype {
  String id;
  String status;
  Statustype({required this.id, required this.status});
  factory Statustype.fromJson(Map<String, dynamic> json) =>
      Statustype(id: json["id"], status: json["status"]);

  Map<String, dynamic> toJson() => {"id": id, "status": status};
}
//
// [{ <Status_fill> }, { <Status_fill> }, { <Status_fill> }, ...]

class StautsConttainer {}

// =================================
