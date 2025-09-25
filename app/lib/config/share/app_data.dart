import 'package:app/config/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AppData with ChangeNotifier {
  ThemeToken _themeToken = ThemeToken();

  ThemeToken get themeToken => _themeToken;
}

class ThemeToken {
  Color color = AppColors.grayInsight;

  LinearGradient gradient = AppColors.gradientPrimary;
}
