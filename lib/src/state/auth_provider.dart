import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  String? _email;
  String? _name;
  String? _phone;
  String? _address;
  String? _role; // 'admin' or 'user'
  bool _isLoading = false;

  String? get token => _token;
  String? get email => _email;
  String? get name => _name;
  String? get phone => _phone;
  String? get address => _address;
  String? get role => _role;
  bool get isAdmin => _role == 'admin';
  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _loadAuth();
  }

  Future<void> _loadAuth() async {
    _token = await StorageService.getAuthToken();
    _email = await StorageService.getAuthEmail();
    _role = await StorageService.getAuthRole();
    _name = await StorageService.getUserName();
    _phone = await StorageService.getUserPhone();
    _address = await StorageService.getUserAddress();
    if (_token != null) {
      ApiService.setAuthToken(_token);
      // If user is logged in, fetch latest profile
      if (_role == 'user') {
        _fetchProfile();
      }
    }
    notifyListeners();
  }

  Future<void> _fetchProfile() async {
    try {
      final profile = await ApiService.getUserProfile();
      _name = profile['name'];
      _email = profile['email'];
      _phone = profile['phone'] ?? '';
      _address = profile['address'] ?? '';
      await StorageService.saveUserProfile(
        name: _name,
        email: _email,
        phone: _phone,
        address: _address,
      );
      notifyListeners();
    } catch (e) {
      // Silently fail - use cached data
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.login(email, password);
      _token = response['token'];
      _email = response['email'];
      _role = response['role'] ?? 'user';
      _name = response['name'];
      _phone = response['phone'] ?? '';
      _address = response['address'] ?? '';
      
      await StorageService.saveAuthToken(
        _token!,
        _email!,
        role: _role!,
        name: _name,
        phone: _phone,
        address: _address,
      );
      ApiService.setAuthToken(_token);
      
      // Fetch full profile if user
      if (_role == 'user') {
        _fetchProfile();
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? address,
  }) async {
    try {
      final profile = await ApiService.updateUserProfile(
        name: name,
        email: email,
        phone: phone,
        address: address,
      );
      
      if (name != null) _name = profile['name'];
      if (email != null) _email = profile['email'];
      if (phone != null) _phone = profile['phone'] ?? '';
      if (address != null) _address = profile['address'] ?? '';
      
      await StorageService.saveUserProfile(
        name: _name,
        email: _email,
        phone: _phone,
        address: _address,
      );
      
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    _email = null;
    _name = null;
    _phone = null;
    _address = null;
    _role = null;
    await StorageService.clearAuth();
    ApiService.setAuthToken(null);
    notifyListeners();
  }
}

