import 'package:finanapp/services/database_service.dart';
import 'package:finanapp/models/transaction.dart';
import 'package:finanapp/services/error_handler.dart';
import 'package:finanapp/utils/constants.dart';

class TransactionService {
  final DatabaseService _databaseService = DatabaseService();

  // Get all transactions with proper error handling
  Future<List<Transaction>> getAllTransactions() async {
    try {
      return await _databaseService.getAllTransactions();
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  // Add a new transaction with comprehensive validation
  Future<void> addTransaction({
    required String title,
    required double value,
    required bool isExpense,
  }) async {
    try {
      // Input validation
      _validateTransactionInput(title, value);

      final transaction = Transaction(
        title: title.trim(),
        value: value,
        date: DateTime.now(),
        isExpense: isExpense,
      );

      await _databaseService.addTransaction(transaction);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  // Delete transaction with validation
  Future<void> deleteTransaction(int key) async {
    try {
      if (key < 0) {
        throw const AppError(
          message: 'ID da transação inválido',
          type: ErrorType.validation,
        );
      }

      await _databaseService.deleteTransaction(key);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  // Calculate current balance (pure function - no errors expected)
  double calculateBalance(List<Transaction> transactions) {
    double totalBalance = 0.0;

    for (final transaction in transactions) {
      if (transaction.isExpense) {
        totalBalance -= transaction.value;
      } else {
        totalBalance += transaction.value;
      }
    }

    return totalBalance;
  }

  // Get balance image path (pure function - no errors expected)
  String getBalanceImagePath(double balance) {
    if (balance < 0) {
      return AppConstants.sadPigImage;
    } else if (balance == 0) {
      return AppConstants.neutralPigImage;
    } else {
      return AppConstants.happyPigImage;
    }
  }

  // Get financial summary with error handling
  Map<String, double> getFinancialSummary(List<Transaction> transactions) {
    try {
      double totalIncome = 0.0;
      double totalExpenses = 0.0;

      for (final transaction in transactions) {
        // Additional validation
        if (transaction.value < 0) {
          continue; // Skip invalid transactions
        }

        if (transaction.isExpense) {
          totalExpenses += transaction.value;
        } else {
          totalIncome += transaction.value;
        }
      }

      return {
        'income': totalIncome,
        'expenses': totalExpenses,
        'balance': totalIncome - totalExpenses,
      };
    } catch (e) {
      // Return safe defaults if calculation fails
      return {'income': 0.0, 'expenses': 0.0, 'balance': 0.0};
    }
  }

  // Get transactions filtered by type
  List<Transaction> getTransactionsByType(
    List<Transaction> transactions, {
    required bool isExpense,
  }) {
    try {
      return transactions
          .where((transaction) => transaction.isExpense == isExpense)
          .toList();
    } catch (e) {
      return []; // Return empty list on error
    }
  }

  // Get transactions from last N days
  List<Transaction> getRecentTransactions(
    List<Transaction> transactions, {
    int days = 30,
  }) {
    try {
      if (days <= 0) {
        throw const AppError(
          message: 'Número de dias deve ser positivo',
          type: ErrorType.validation,
        );
      }

      final cutoffDate = DateTime.now().subtract(Duration(days: days));
      return transactions
          .where((transaction) => transaction.date.isAfter(cutoffDate))
          .toList();
    } catch (e) {
      if (e is AppError) rethrow;
      return []; // Return empty list on unexpected errors
    }
  }

  // Clear all data with confirmation
  Future<void> clearAllTransactions() async {
    try {
      await _databaseService.clearAllData();
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  Future<void> updateTransaction(Transaction transaction) async {
    try {
      if (transaction.key == null) {
        throw const AppError(
          message: 'Transação inválida para atualização: chave ausente',
          type: ErrorType.validation,
        );
      }
      _validateTransactionInput(transaction.title, transaction.value);
      await _databaseService.updateTransaction(transaction);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  // Private validation method
  void _validateTransactionInput(String title, double value) {
    final errors = <String>[];

    // Title validation
    if (title.trim().isEmpty) {
      errors.add('O título não pode estar vazio');
    } else if (title.trim().length > AppConstants.maxTitleLength) {
      errors.add('O título não pode ter mais que 100 caracteres');
    }

    // Value validation
    if (value <= 0) {
      errors.add('O valor deve ser maior que zero');
    } else if (value > AppConstants.maxTransactionValue) {
      errors.add('O valor é muito alto');
    }

    // Throw validation error if any issues found
    if (errors.isNotEmpty) {
      throw AppError(message: errors.join('\n'), type: ErrorType.validation);
    }
  }
}
