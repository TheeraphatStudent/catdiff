import 'dart:convert';
// [0] ผุ้ใช้เตรียมสินค้า (prepare)
// [1] รอไรเดอร์มารับสินค้า (pending)
// [2] ไรเดอร์รับงาน (กำลังเดินทางมารับสินค้า) (receiving)
// [3] ไรเดอร์รับสินค้าแล้วและกำลังเดินทางไปส่ง (riding)
// [4] ไรเดอร์นำส่งสินค้าแล้ว (success)

enum StatusType { prepare, pending, receiving, riding, success }

class StatusTypes {
  StatusType getStatusTypeEnum(String status) {
    switch (status) {
      case 'prepare':
        return StatusType.prepare;
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

  String getStatusTypeString(StatusType status) {
    switch (status) {
      case StatusType.prepare:
        return 'prepare';
      case StatusType.pending:
        return 'pending';
      case StatusType.receiving:
        return 'receiving';
      case StatusType.riding:
        return 'riding';
      case StatusType.success:
        return 'success';
    }
  }

  // Get status meaning
  String getStatusMeaning(StatusType status) {
    Map<StatusType, String> statusMap = {
      StatusType.prepare: 'กำลังตรียมสินค้า',
      StatusType.pending: 'รอไรเดอร์มารับสินค้า',
      StatusType.receiving: 'ไรเดอร์รับงาน',
      StatusType.riding: 'ไรเดอร์รับสินค้าแล้วและกำลังเดินทางไปส่ง',
      StatusType.success: 'ไรเดอร์นำส่งสินค้าแล้ว',
    };

    return statusMap[status] ?? 'ไม่พบข้อมูล';
  }
}
