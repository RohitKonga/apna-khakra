import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  String? _email;
  String? _role; // 'admin' or 'user'
  bool _isLoading = false;

  String? get token => _token;
  String? get email => _email;
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
    if (_token != null) {
      ApiService.setAuthToken(_token);
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.login(email, password);
      _token = response['token'];
      _email = response['email'];
      _role = response['role'] ?? 'user';
      
      await StorageService.saveAuthToken(
        _token!,
        _email!,
        role: _role!,
      );
      ApiService.setAuthToken(_token);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    _email = null;
    _role = null;
    await StorageService.clearAuth();
    ApiService.setAuthToken(null);
    notifyListeners();
  }
}

