import 'package:app/config/theme/app_theme.dart';
import 'package:app/types/role.dart';
import 'package:flutter/material.dart';

class AppData with ChangeNotifier {
  ThemeToken _themeToken = ThemeToken();
  User _user = User(uid: '');

  ThemeToken get themeToken => _themeToken;
  User get user => _user;
}

class User {
  String uid;
  UserRole _role = UserRole.user;

  User({required this.uid});

  UserRole get role => _role;

  void setRole(UserRole role) {
    _role = role;
  }
}

class ThemeToken {
  Color color = AppColors.grayInsight;

  LinearGradient gradient = AppColors.gradientPrimary;
}
