import 'package:app/config/theme/app_theme.dart';
import 'package:app/types/user/role.dart';
import 'package:app/types/user/user_auth.dart';
import 'package:flutter/material.dart';

class AppData with ChangeNotifier {
  AppData();

  final ThemeToken _themeToken = ThemeToken();
  User? _currentUser;

  UserRole _preferredRole = UserRole.user;

  ThemeToken get themeToken => _themeToken;
  User? get currentUser => _currentUser;
  UserRole get preferredRole => _preferredRole;

  void setCurrentUser(User user) {
    _currentUser = user;
    _preferredRole = user.role;
    notifyListeners();
  }

  void clearCurrentUser() {
    _currentUser = null;
    notifyListeners();
  }

  void setPreferredRole(UserRole role) {
    if (_preferredRole == role) {
      return;
    }
    _preferredRole = role;
    notifyListeners();
  }
}

class ThemeToken {
  Color color = AppColors.grayInsight;
  LinearGradient gradient = AppColors.gradientPrimary;
}
