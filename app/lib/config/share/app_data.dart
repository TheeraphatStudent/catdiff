import 'package:app/config/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AppData with ChangeNotifier {
  ThemeToken _themeToken = ThemeToken();

  ThemeToken get themeToken => _themeToken;
}

class ThemeToken {
  Color color = AppColors.grayInsight;

  LinearGradient gradient = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x00D3ECA5), Color(0x90D3ECA5), Color(0xFFD3ECA5)],
  );
}
