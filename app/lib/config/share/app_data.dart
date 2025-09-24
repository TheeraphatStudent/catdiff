import 'package:flutter/material.dart';

class AppData with ChangeNotifier {
  ThemeToken _themeToken = ThemeToken();
}

class ThemeToken {
  late Gradient gradient;
}
