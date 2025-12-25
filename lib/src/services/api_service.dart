import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/config.dart';
import '../models/product.dart';
import '../models/order.dart';

class ApiService {
  static String? _authToken;

  static void setAuthToken(String? token) {
    _authToken = token;
  }

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  // Products
  static Future<List<Product>> getProducts() async {
    try {
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/api/products'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }

  static Future<Product> getProductById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/api/products/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return Product.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load product');
      }
    } catch (e) {
      throw Exception('Error fetching product: $e');
    }
  }

  // Orders
  static Future<Order> createOrder(Order order) async {
    try {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/api/orders'),
        headers: _headers,
        body: json.encode(order.toJson()),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Order.fromJson(data['order'] ?? data);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Failed to create order');
      }
    } catch (e) {
      throw Exception('Error creating order: $e');
    }
  }

  static Future<List<Order>> getOrders() async {
    try {
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/api/orders'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Order.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      throw Exception('Error fetching orders: $e');
    }
  }

  // Get user's own orders
  static Future<List<Order>> getUserOrders() async {
    try {
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/api/orders/my-orders'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Order.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      throw Exception('Error fetching user orders: $e');
    }
  }

  static Future<Order> getOrderById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/api/orders/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return Order.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load order');
      }
    } catch (e) {
      throw Exception('Error fetching order: $e');
    }
  }

  static Future<Order> updateOrderStatus(String id, String status) async {
    try {
      final response = await http.patch(
        Uri.parse('${Config.baseUrl}/api/orders/$id'),
        headers: _headers,
        body: json.encode({'status': status}),
      );

      if (response.statusCode == 200) {
        return Order.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update order');
      }
    } catch (e) {
      throw Exception('Error updating order: $e');
    }
  }

  // Admin - Products
  static Future<Product> createProduct(Product product) async {
    try {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/api/products'),
        headers: _headers,
        body: json.encode(product.toJson()),
      );

      if (response.statusCode == 201) {
        return Product.fromJson(json.decode(response.body));
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Failed to create product');
      }
    } catch (e) {
      throw Exception('Error creating product: $e');
    }
  }

  static Future<Product> updateProduct(String id, Product product) async {
    try {
      final response = await http.put(
        Uri.parse('${Config.baseUrl}/api/products/$id'),
        headers: _headers,
        body: json.encode(product.toJson()),
      );

      if (response.statusCode == 200) {
        return Product.fromJson(json.decode(response.body));
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Failed to update product');
      }
    } catch (e) {
      throw Exception('Error updating product: $e');
    }
  }

  static Future<void> deleteProduct(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('${Config.baseUrl}/api/products/$id'),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Failed to delete product');
      }
    } catch (e) {
      throw Exception('Error deleting product: $e');
    }
  }

  // Auth
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Error logging in: $e');
    }
  }

  static Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'name': name,
        'email': email,
        'password': password,
      };
      if (phone != null && phone.isNotEmpty) {
        body['phone'] = phone;
      }
      
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('Error registering: $e');
    }
  }

  static Future<Map<String, dynamic>> forgotPassword({
    required String email,
    required String phone,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/api/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'phone': phone,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Failed to reset password');
      }
    } catch (e) {
      throw Exception('Error resetting password: $e');
    }
  }

  // User Profile
  static Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/api/user/profile'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Failed to load profile');
      }
    } catch (e) {
      throw Exception('Error fetching profile: $e');
    }
  }

  static Future<Map<String, dynamic>> updateUserProfile({
    String? name,
    String? email,
    String? phone,
    String? address,
  }) async {
    try {
      final Map<String, dynamic> body = {};
      if (name != null) body['name'] = name;
      if (email != null) body['email'] = email;
      if (phone != null) body['phone'] = phone;
      if (address != null) body['address'] = address;

      final response = await http.put(
        Uri.parse('${Config.baseUrl}/api/user/profile'),
        headers: _headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Failed to update profile');
      }
    } catch (e) {
      throw Exception('Error updating profile: $e');
    }
  }
}

