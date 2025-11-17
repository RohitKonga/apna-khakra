import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  String? _email;
  bool _isLoading = false;

  String? get token => _token;
  String? get email => _email;
  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _loadAuth();
  }

  Future<void> _loadAuth() async {
    _token = await StorageService.getAuthToken();
    _email = await StorageService.getAdminEmail();
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
      
      await StorageService.saveAuthToken(_token!, _email!);
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
    await StorageService.clearAuth();
    ApiService.setAuthToken(null);
    notifyListeners();
  }
}

