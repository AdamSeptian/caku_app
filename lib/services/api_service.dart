// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api';
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<void> _removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // Auth Methods
  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
        }),
      );

      print('Register Response Status: ${response.statusCode}');
      print('Register Response Body: ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await _saveToken(data['token']);
        return data;
      } else {
        // Try to parse error message
        try {
          final error = jsonDecode(response.body);
          throw Exception(error['message'] ?? 'Registration failed');
        } catch (e) {
          throw Exception('Server error: ${response.statusCode}. Check if Laravel is running at $baseUrl');
        }
      }
    } catch (e) {
      print('Register Error: $e');
      if (e.toString().contains('SocketException') || e.toString().contains('Connection refused')) {
        throw Exception('Cannot connect to server. Please check:\n1. Laravel is running\n2. URL is correct: $baseUrl\n3. Phone and computer on same WiFi');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('Login Response Status: ${response.statusCode}');
      print('Login Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveToken(data['token']);
        return data;
      } else {
        // Try to parse error message
        try {
          final error = jsonDecode(response.body);
          throw Exception(error['message'] ?? 'Login failed');
        } catch (e) {
          throw Exception('Server error: ${response.statusCode}. Check if Laravel is running at $baseUrl');
        }
      }
    } catch (e) {
      print('Login Error: $e');
      if (e.toString().contains('SocketException') || e.toString().contains('Connection refused')) {
        throw Exception('Cannot connect to server. Please check:\n1. Laravel is running\n2. URL is correct: $baseUrl\n3. Phone and computer on same WiFi');
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    final token = await _getToken();
    await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    await _removeToken();
  }

  // Transaction Methods
  Future<List<dynamic>> getTransactions() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/transactions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load transactions');
    }
  }

  Future<Map<String, dynamic>> createTransaction(Map<String, dynamic> data) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/transactions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create transaction');
    }
  }

  Future<Map<String, dynamic>> updateTransaction(int id, Map<String, dynamic> data) async {
    final token = await _getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/transactions/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update transaction');
    }
  }

  Future<void> deleteTransaction(int id) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/transactions/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete transaction');
    }
  }

  Future<Map<String, dynamic>> getBalance() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/balance'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load balance');
    }
  }

  Future<Map<String, dynamic>> getMonthlyReport(int year, int month) async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/monthly-report?year=$year&month=$month'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Monthly Report Response Status: ${response.statusCode}');
      print('Monthly Report Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Ensure income_by_category and expense_by_category are Maps
        if (data['income_by_category'] == null) {
          data['income_by_category'] = {};
        }
        if (data['expense_by_category'] == null) {
          data['expense_by_category'] = {};
        }
        
        return data;
      } else {
        throw Exception('Failed to load monthly report');
      }
    } catch (e) {
      print('Monthly Report Error: $e');
      rethrow;
    }
  }
}