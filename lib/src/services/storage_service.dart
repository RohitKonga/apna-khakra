import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _emailKey = 'auth_email';
  static const String _roleKey = 'auth_role';
  static const String _nameKey = 'user_name';
  static const String _phoneKey = 'user_phone';
  static const String _addressKey = 'user_address';

  static Future<void> saveAuthToken(
    String token,
    String email, {
    required String role,
    String? name,
    String? phone,
    String? address,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_emailKey, email);
    await prefs.setString(_roleKey, role);
    if (name != null) await prefs.setString(_nameKey, name);
    if (phone != null) await prefs.setString(_phoneKey, phone);
    if (address != null) await prefs.setString(_addressKey, address);
  }

  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<String?> getAuthEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  static Future<String?> getAuthRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey);
  }

  static Future<String?> getUserPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_phoneKey);
  }

  static Future<String?> getUserAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_addressKey);
  }

  static Future<void> saveUserProfile({
    String? name,
    String? email,
    String? phone,
    String? address,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (name != null) await prefs.setString(_nameKey, name);
    if (email != null) await prefs.setString(_emailKey, email);
    if (phone != null) await prefs.setString(_phoneKey, phone);
    if (address != null) await prefs.setString(_addressKey, address);
  }

  static Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_roleKey);
    await prefs.remove(_nameKey);
    await prefs.remove(_phoneKey);
    await prefs.remove(_addressKey);
  }
}

