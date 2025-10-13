import 'package:get_storage/get_storage.dart';
import 'package:app/types/role.dart';

class StorageHelper {
  static final _box = GetStorage();
  static const String _tokenKey = 'auth_token';
  static const String _roleKey = 'user_role';

  // Token
  static void saveToken(String token) {
    _box.write(_tokenKey, token);
  }

  static String? getToken() {
    return _box.read(_tokenKey);
  }

  static void deleteToken() {
    _box.remove(_tokenKey);
  }

  // Role
  static void saveRole(UserRole role) {
    _box.write(_roleKey, role.name);
  }

  static UserRole? getRole() {
    String? roleName = _box.read(_roleKey);
    if (roleName == null) return null;
    return UserRole.values.firstWhere((e) => e.name == roleName);
  }

  static void deleteRole() {
    _box.remove(_roleKey);
  }
}
