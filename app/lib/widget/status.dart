import 'package:app/config/theme/app_theme.dart';
import 'package:app/types/status.dart';
import 'package:flutter/material.dart';

class ColorSchema {
  final Color border;
  final Color background;

  const ColorSchema(this.border, this.background);
}

class StatusTag extends StatelessWidget {
  final StatusType type;
  final String label;

  const StatusTag({super.key, required this.type, required this.label});

  // map <Inout, Output>
  static const Map<StatusType, ColorSchema> colorVariants = {
    StatusType.pending: ColorSchema(AppColors.primary1, AppColors.primary3),
    StatusType.receiving: ColorSchema(
      AppColors.darkWarning,
      AppColors.lightWarning,
    ),
    StatusType.riding: ColorSchema(AppColors.darkDanger, AppColors.lightDanger),
    StatusType.success: ColorSchema(AppColors.darkOcean, AppColors.lightOcean),
  };

  @override
  Widget build(BuildContext context) {
    final colors = colorVariants[type]!;

    return Container(
      width: 12,
      height: 12,
      decoration: ShapeDecoration(
        color: colors.background,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: colors.border),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}

class StatusName {
  final String id;
  final String status;
  const StatusName({required this.id, required this.status});

  // ใช้ static const map → ใช้โดยไม่ต้องสร้าง instance
  static const Map<StatusType, StatusTag> typeStatusTag = {
    StatusType.pending: StatusTag(
      type: StatusType.pending,
      label: "รอไรเดอร์มารับสินค้า",
    ),
    StatusType.receiving: StatusTag(
      type: StatusType.receiving,
      label: "ไรเดอร์กำลังเดินทางมารับสินค้า",
    ),
    StatusType.riding: StatusTag(
      type: StatusType.riding,
      label: "ไรเดอร์รับสินค้าแล้ว กำลังไปส่ง",
    ),
    StatusType.success: StatusTag(
      type: StatusType.success,
      label: "ไรเดอร์ส่งสำเร็จแล้ว",
    ),
  };
}

class StatusSender {
  final String id;
  final String status;
  const StatusSender({required this.id, required this.status});

  // ใช้ static const map → ใช้โดยไม่ต้องสร้าง instance
  static const Map<StatusType, StatusTag> typeStatusTag = {
    StatusType.pending: StatusTag(
      type: StatusType.pending,
      label: "กำลังเดินทางไปส่ง",
    ),
    StatusType.receiving: StatusTag(
      type: StatusType.receiving,
      label: "กำลังเดินทางมารับสินค้า",
    ),
    StatusType.riding: StatusTag(
      type: StatusType.riding,
      label: "กำลังเดินทางมารับสินค้า",
    ),
    StatusType.success: StatusTag(
      type: StatusType.success,
      label: "รอไรเดอร์มารับสินค้า",
    ),
  };
}

class StatusGetProduct {
  final String id;
  final String status;
  const StatusGetProduct({required this.id, required this.status});

  // ใช้ static const map → ใช้โดยไม่ต้องสร้าง instance
  static const Map<StatusType, StatusTag> typeStatusTag = {
    StatusType.pending: StatusTag(
      type: StatusType.pending,
      label: "กำลังเดินมาส่ง",
    ),
    StatusType.receiving: StatusTag(
      type: StatusType.receiving,
      label: "กำลังเดินเข้ารับสินค้า",
    ),
    StatusType.riding: StatusTag(
      type: StatusType.riding,
      label: "รอไรเดอร์เข้ารับสินค้า",
    ),
  };
}

// --------------------- 1. Get Data ---------------------

// Overview: User -> Feature: Sender, Reciver
// ดึง Content จาก Delivery -> เอา Contnet มา Map แค่ที่ใช้ตาม app/lib/types/status.dart -> Status_fill
// จากนั้น Group ข้อมูลที่ดึงมาให้เป็น  StautsConttainer

/*
[
  { id, status },
  { id, status }
]
*/

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

// --------------------- 2. Render UI ---------------------

/*
[
  { id, status },
  { id, status }
]
*/

// { id, status }
// Tag [ StatusTag(status: status) ] -> widget status tag
// StatusLabel [ StatusLabel(status: status ) ] -> widget status label

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

// เอา StatusTag มาบวกับ ชื่อสถานะ

// มุมมองคนส่ง - Sender
/*
รอไรเดอร์มารับสินค้า
กำลังเดินทางมารับสินค้า
กำลังเดินทางไปส่ง
ไรเดอร์นำส่งสินค้าแล้ว
*/

// มุมมองคนรับ - Reciver

/*
รอไรเดอร์เข้ารับสินค้า
กำลังเดินเข้ารับสินค้า
กำลังเดินมาส่ง
ไรเดอร์นำส่งสินค้าแล้ว
*/

class StatusLabel {}
