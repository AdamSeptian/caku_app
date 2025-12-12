import 'package:flutter/material.dart';
import '../services/api_service.dart';

class TransactionProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<dynamic> _transactions = [];
  Map<String, dynamic> _balance = {
    'income': 0.0,
    'expense': 0.0,
    'balance': 0.0,
  };
  bool _isLoading = true;
  bool _deleteMode = false;
  Set<int> _selectedTransactions = {};

  List<dynamic> get transactions => _transactions;
  Map<String, dynamic> get balance => _balance;
  bool get isLoading => _isLoading;
  bool get deleteMode => _deleteMode;
  Set<int> get selectedTransactions => _selectedTransactions;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final transactions = await _apiService.getTransactions();
      final balance = await _apiService.getBalance();
      _transactions = transactions;
      _balance = balance;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleDeleteMode() {
    _deleteMode = !_deleteMode;
    if (!_deleteMode) {
      _selectedTransactions.clear();
    }
    notifyListeners();
  }

  void toggleTransactionSelection(int id) {
    if (_selectedTransactions.contains(id)) {
      _selectedTransactions.remove(id);
    } else {
      _selectedTransactions.add(id);
    }
    notifyListeners();
  }

  void clearSelection() {
    _selectedTransactions.clear();
    notifyListeners();
  }

  Future<void> deleteSelectedTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      for (final id in _selectedTransactions) {
        await _apiService.deleteTransaction(id);
      }
      await loadData();
      _selectedTransactions.clear();
      _deleteMode = false;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTransaction(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.createTransaction(data);
      await loadData();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTransaction(int id, Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.updateTransaction(id, data);
      await loadData();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}