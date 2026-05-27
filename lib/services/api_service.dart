import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Base URL menggunakan IP lokal agar bisa diakses dari HP fisik
  static const String baseUrl = 'http://192.168.18.119:8082/api';
  
  static Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['token'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', data['token']);
          await prefs.setBool('isLoggedIn', true);
          if (data['user'] != null && data['user']['name'] != null) {
            await prefs.setString('store_name', data['user']['name']);
            await prefs.setString('user_email', data['user']['email']);
          }
          return true;
        }
      }
      return false;
    } catch (e) {
      // Catch network or parsing errors
      print('Login error: $e');
      return false;
    }
  }

  static Future<List<dynamic>> getOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$baseUrl/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      }
      return [];
    } catch (e) {
      print('Fetch orders error: $e');
      return [];
    }
  }

  static Future<List<dynamic>> getProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$baseUrl/products'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      }
      return [];
    } catch (e) {
      print('Fetch products error: $e');
      return [];
    }
  }

  static Future<List<dynamic>> getPaymentMethods() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$baseUrl/payment-methods'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      }
      return [];
    } catch (e) {
      print('Fetch payment methods error: $e');
      return [];
    }
  }
}
