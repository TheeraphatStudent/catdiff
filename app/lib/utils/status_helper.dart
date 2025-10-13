import 'package:app/config/theme/app_theme.dart';
import 'package:app/types/status.dart';
import 'package:flutter/material.dart';

class StatusColors {
  const StatusColors({required this.dark, required this.light});

  final Color dark;
  final Color light;
}

class StatusHelper {
  StatusHelper._();

  static const Map<StatusType, StatusColors> _colorMap = {
    StatusType.pending: StatusColors(
      dark: AppColors.darkWarning,
      light: AppColors.lightWarning,
    ),
    StatusType.receiving: StatusColors(
      dark: AppColors.darkTilip,
      light: AppColors.lightTilip,
    ),
    StatusType.riding: StatusColors(
      dark: AppColors.darkOcean,
      light: AppColors.lightOcean,
    ),
    StatusType.success: StatusColors(
      dark: AppColors.primary1,
      light: AppColors.primary4,
    ),
  };

  static StatusColors colors(StatusType type) {
    return _colorMap[type] ??
        const StatusColors(dark: AppColors.primary1, light: AppColors.primary3);
  }
}
