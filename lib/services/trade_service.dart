import 'package:finanapp/services/database_service.dart';
import 'package:finanapp/models/trade.dart';
import 'package:finanapp/services/error_handler.dart';
import 'package:finanapp/utils/constants.dart';

class TradeService {
  final DatabaseService _databaseService = DatabaseService();

  // Get all trades with proper error handling
  Future<List<Trade>> getAllTrades() async {
    try {
      return await _databaseService.getAllTrades();
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  // Add a new trade with comprehensive validation
  Future<void> addTrade({
    required String title,
    required double value,
    required bool isExpense,
  }) async {
    try {
      // Input validation
      _validateTradeInput(title, value);

      final trade = Trade(
        title: title.trim(),
        value: value,
        date: DateTime.now(),
        isExpense: isExpense,
      );

      await _databaseService.addTrade(trade);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  // Delete trade with validation
  Future<void> deleteTrade(int key) async {
    try {
      if (key < 0) {
        throw const AppError(
          message: 'ID da transação inválido', // TODO: Refactor this
          type: ErrorType.validation,
        );
      }

      await _databaseService.deleteTrade(key);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  // Calculate current balance (pure function - no errors expected)
  double calculateBalance(List<Trade> trades) {
    double totalBalance = 0.0;

    for (final trade in trades) {
      if (trade.isExpense) {
        totalBalance -= trade.value;
      } else {
        totalBalance += trade.value;
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
  Map<String, double> getFinancialSummary(List<Trade> trades) {
    try {
      double totalIncome = 0.0;
      double totalExpenses = 0.0;

      for (final trade in trades) {
        // Additional validation
        if (trade.value < 0) {
          continue; // Skip invalid trades
        }

        if (trade.isExpense) {
          totalExpenses += trade.value;
        } else {
          totalIncome += trade.value;
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

  // Get trades filtered by type
  List<Trade> getTradesByType(
    List<Trade> trades, {
    required bool isExpense,
  }) {
    try {
      return trades
          .where((trade) => trade.isExpense == isExpense)
          .toList();
    } catch (e) {
      return []; // Return empty list on error
    }
  }

  // Get trades from last N days
  List<Trade> getRecentTrades(
    List<Trade> trades, {
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
      return trades
          .where((trade) => trade.date.isAfter(cutoffDate))
          .toList();
    } catch (e) {
      if (e is AppError) rethrow;
      return []; // Return empty list on unexpected errors
    }
  }

  // Clear all data with confirmation
  Future<void> clearAllTrades() async {
    try {
      await _databaseService.clearAllData();
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  Future<void> updateTrade(Trade trade) async {
    try {
      if (trade.key == null) {
        throw const AppError(
          message: 'Transação inválida para atualização: chave ausente', // TODO: Refactor this
          type: ErrorType.validation,
        );
      }
      _validateTradeInput(trade.title, trade.value);
      await _databaseService.updateTrade(trade);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  // Private validation method
  void _validateTradeInput(String title, double value) {
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
    } else if (value > AppConstants.maxTradeValue) { 
      errors.add('O valor é muito alto');
    }

    // Throw validation error if any issues found
    if (errors.isNotEmpty) {
      throw AppError(message: errors.join('\n'), type: ErrorType.validation);
    }
  }
}