import 'package:app/config/theme/app_theme.dart';
import 'package:app/types/user/raider_auth.dart' as RiderModel;
import 'package:app/types/user/role.dart';
import 'package:app/types/user/user_auth.dart' as UserModel;
import 'package:flutter/material.dart';

class AppData with ChangeNotifier {
  AppData();

  final ThemeToken _themeToken = ThemeToken();
  dynamic _currentUser;

  UserRole _preferredRole = UserRole.user;

  ThemeToken get themeToken => _themeToken;
  dynamic get currentUser => _currentUser;
  UserRole get preferredRole => _preferredRole;

  void setCurrentUserFromUserModel(UserModel.User userModel) {
    _currentUser = userModel;
    _preferredRole = userModel.role;
    notifyListeners();
  }

  void setCurrentUserFromRiderModel(RiderModel.Raider riderModel) {
    _currentUser = riderModel;
    _preferredRole = riderModel.role;
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
