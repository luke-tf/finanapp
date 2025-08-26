// transaction_provider.dart

import 'package:flutter/foundation.dart';
import 'package:finanapp/models/transaction.dart';
import 'package:finanapp/services/transaction_service.dart';
import 'package:finanapp/services/error_handler.dart';

enum TransactionState { initial, loading, loaded, error }

class TransactionProvider with ChangeNotifier {
  final TransactionService _transactionService = TransactionService();

  // Private state variables
  List<Transaction> _transactions = [];
  TransactionState _state = TransactionState.initial;
  AppError? _error;
  bool _isAddingTransaction = false;
  bool _isDeletingTransaction = false;

  // Public getters
  List<Transaction> get transactions => List.unmodifiable(_transactions);
  TransactionState get state => _state;
  AppError? get error => _error;
  bool get isAddingTransaction => _isAddingTransaction;
  bool get isDeletingTransaction => _isDeletingTransaction;
  bool get isLoading => _state == TransactionState.loading;
  bool get hasError => _state == TransactionState.error;
  bool get hasTransactions => _transactions.isNotEmpty;

  // Computed properties
  double get currentBalance =>
      _transactionService.calculateBalance(_transactions);

  String get balanceImagePath =>
      _transactionService.getBalanceImagePath(currentBalance);

  Map<String, double> get financialSummary =>
      _transactionService.getFinancialSummary(_transactions);

  List<Transaction> get expenses =>
      _transactionService.getTransactionsByType(_transactions, isExpense: true);

  List<Transaction> get incomes => _transactionService.getTransactionsByType(
    _transactions,
    isExpense: false,
  );

  List<Transaction> get recentTransactions =>
      _transactionService.getRecentTransactions(_transactions);

  // Load all transactions
  Future<void> loadTransactions() async {
    if (_state == TransactionState.loading) return; // Prevent multiple loading

    _setState(TransactionState.loading);
    _error = null;

    try {
      _transactions = await _transactionService.getAllTransactions();
      _setState(TransactionState.loaded);
    } catch (e) {
      _error = e is AppError ? e : ErrorHandler.handleException(e);
      _setState(TransactionState.error);
    }
  }

  // Add new transaction
  Future<bool> addTransaction({
    required String title,
    required double value,
    required bool isExpense,
  }) async {
    if (_isAddingTransaction) return false; // Prevent multiple additions

    _isAddingTransaction = true;
    notifyListeners();

    try {
      await _transactionService.addTransaction(
        title: title,
        value: value,
        isExpense: isExpense,
      );

      // Refresh transactions list
      await loadTransactions();

      _isAddingTransaction = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isAddingTransaction = false;
      _error = e is AppError ? e : ErrorHandler.handleException(e);
      notifyListeners();
      return false;
    }
  }

  // Delete transaction
  Future<bool> deleteTransaction(int key) async {
    if (_isDeletingTransaction) return false; // Prevent multiple deletions

    _isDeletingTransaction = true;
    notifyListeners();

    try {
      await _transactionService.deleteTransaction(key);

      // Refresh transactions list
      await loadTransactions();

      _isDeletingTransaction = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isDeletingTransaction = false;
      _error = e is AppError ? e : ErrorHandler.handleException(e);
      notifyListeners();
      return false;
    }
  }

  // Clear all transactions (for debugging/reset)
  Future<bool> clearAllTransactions() async {
    if (_state == TransactionState.loading) return false;

    _setState(TransactionState.loading);

    try {
      await _transactionService.clearAllTransactions();
      _transactions.clear();
      _setState(TransactionState.loaded);
      return true;
    } catch (e) {
      _error = e is AppError ? e : ErrorHandler.handleException(e);
      _setState(TransactionState.error);
      return false;
    }
  }

  // Refresh transactions (for pull-to-refresh)
  Future<void> refreshTransactions() async {
    await loadTransactions();
  }

  // Clear error state
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Filter transactions by date range
  List<Transaction> getTransactionsByDateRange(DateTime start, DateTime end) {
    return _transactions.where((transaction) {
      return transaction.date.isAfter(
            start.subtract(const Duration(days: 1)),
          ) &&
          transaction.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  // Get transactions by month
  List<Transaction> getTransactionsByMonth(int year, int month) {
    return _transactions.where((transaction) {
      return transaction.date.year == year && transaction.date.month == month;
    }).toList();
  }

  // Search transactions by title
  List<Transaction> searchTransactions(String query) {
    if (query.isEmpty) return _transactions;

    final lowercaseQuery = query.toLowerCase();
    return _transactions.where((transaction) {
      return transaction.title.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Get balance for specific date range
  double getBalanceForDateRange(DateTime start, DateTime end) {
    final transactions = getTransactionsByDateRange(start, end);
    return _transactionService.calculateBalance(transactions);
  }

  // Private helper method to update state
  void _setState(TransactionState newState) {
    _state = newState;
    notifyListeners();
  }

  // Reset provider state (useful for logout/reset scenarios)
  void reset() {
    _transactions.clear();
    _state = TransactionState.initial;
    _error = null;
    _isAddingTransaction = false;
    _isDeletingTransaction = false;
    notifyListeners();
  }

  @override
  void dispose() {
    // Clean up resources if needed
    super.dispose();
  }
}
