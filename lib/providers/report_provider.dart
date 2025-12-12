import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ReportProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  Map<String, dynamic>? _report;
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();

  Map<String, dynamic>? get report => _report;
  bool get isLoading => _isLoading;
  DateTime get selectedDate => _selectedDate;

  Future<void> loadReport() async {
    _isLoading = true;
    notifyListeners();

    try {
      final report = await _apiService.getMonthlyReport(
        _selectedDate.year,
        _selectedDate.month,
      );
      _report = report;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }
}