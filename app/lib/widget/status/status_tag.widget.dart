import 'package:app/types/status.dart';
import 'package:app/utils/status_helper.dart';
import 'package:flutter/material.dart';

class StatusTag extends StatelessWidget {
  const StatusTag({super.key, required this.statusType, this.size = 12});

  final StatusType statusType;
  final double size;

  @override
  Widget build(BuildContext context) {
    final StatusColors palette = StatusHelper.colors(statusType);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: palette.light,
        border: Border.all(color: palette.dark, width: 1.2),
        borderRadius: BorderRadius.circular(size * 0.35),
      ),
    );
  }
}
