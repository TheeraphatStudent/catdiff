import 'package:app/config/theme/app_theme.dart';
import 'package:app/types/raider_auth.dart' as RiderModel;
import 'package:app/types/role.dart';
import 'package:app/types/user/user_auth.dart' as UserModel;
import 'package:flutter/material.dart';

class AppData with ChangeNotifier {
  AppData();

  final ThemeToken _themeToken = ThemeToken();
  AppUser? _currentUser;
  UserRole _preferredRole = UserRole.user;

  ThemeToken get themeToken => _themeToken;
  AppUser? get currentUser => _currentUser;
  UserRole get preferredRole => _preferredRole;

  void setCurrentUser(AppUser user) {
    _currentUser = user;
    _preferredRole = user.role;
    notifyListeners();
  }

  void setCurrentUserFromUserModel(UserModel.User userModel) {
    setCurrentUser(AppUser.fromUserModel(userModel));
  }

  void setCurrentUserFromRiderModel(RiderModel.Raider riderModel) {
    setCurrentUser(AppUser.fromRiderModel(riderModel));
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

class AppUser {
  const AppUser({
    required this.userId,
    required this.name,
    required this.phone,
    required this.addressId,
    required this.imagesUrl,
    required this.role,
    required this.vehicle,
  });

  final String userId;
  final String name;
  final String phone;
  final String addressId;
  final String imagesUrl;
  final UserRole role;
  final AppVehicle vehicle;

  factory AppUser.fromUserModel(UserModel.User user) {
    return AppUser(
      userId: user.userId,
      name: user.name,
      phone: user.phone,
      addressId: user.addressId,
      imagesUrl: user.imagesUrl,
      role: _roleFromString(user.role),
      vehicle: AppVehicle.fromUserVehicle(user.verhicle),
    );
  }

  factory AppUser.fromRiderModel(RiderModel.Raider rider) {
    return AppUser(
      userId: rider.userId,
      name: rider.name,
      phone: rider.phone,
      addressId: rider.addressId,
      imagesUrl: rider.imagesUrl,
      role: _roleFromString(rider.role),
      vehicle: AppVehicle.fromRiderVehicle(rider.verhicle),
    );
  }

  static UserRole _roleFromString(String value) {
    return UserRole.values.firstWhere(
      (element) => element.name == value,
      orElse: () => UserRole.user,
    );
  }
}

class AppVehicle {
  const AppVehicle({
    required this.driveImageUrl,
    required this.licencePlate,
    required this.type,
  });

  final String driveImageUrl;
  final String licencePlate;
  final String type;

  factory AppVehicle.fromUserVehicle(UserModel.Verhicle vehicle) {
    return AppVehicle(
      driveImageUrl: vehicle.driveImageUrl,
      licencePlate: vehicle.licencePlate,
      type: vehicle.type,
    );
  }

  factory AppVehicle.fromRiderVehicle(RiderModel.Verhicle vehicle) {
    return AppVehicle(
      driveImageUrl: vehicle.driveImageUrl,
      licencePlate: vehicle.licencePlate,
      type: vehicle.type,
    );
  }
}

class ThemeToken {
  Color color = AppColors.grayInsight;
  LinearGradient gradient = AppColors.gradientPrimary;
}
