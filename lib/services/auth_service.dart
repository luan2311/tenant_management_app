import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _keyIsLoggedIn = 'is_logged_in';
  static const _keyUserId    = 'user_id';
  static const _keyUserRole  = 'user_role';
  static const _keyUserName  = 'user_name';

  /// Lưu phiên đăng nhập vào SharedPreferences.
  static Future<void> saveSession({
    required int    userId,
    required String role,
    String          name = '',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setInt(_keyUserId, userId);
    await prefs.setString(_keyUserRole, role);
    await prefs.setString(_keyUserName, name);
  }

  /// Kiểm tra xem người dùng đã đăng nhập chưa.
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUserId);
  }

  /// Trả về 'admin' hoặc 'tenant'.
  static Future<String> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserRole) ?? 'tenant';
  }

  static Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName) ?? '';
  }

  /// Xoá toàn bộ dữ liệu phiên (đăng xuất).
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
