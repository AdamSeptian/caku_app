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

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      await _saveToken(data['token']);
      return data;
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Registration failed');
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _saveToken(data['token']);
      return data;
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Login failed');
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
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/monthly-report?year=$year&month=$month'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load monthly report');
    }
  }
}