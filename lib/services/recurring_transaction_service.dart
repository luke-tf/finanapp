import 'package:finanapp/services/database_service.dart';
import 'package:finanapp/models/transaction.dart';
import 'package:finanapp/models/recurring_transaction.dart';
import 'package:finanapp/services/error_handler.dart';
import 'package:finanapp/utils/constants.dart';

class RecurringTransactionService {
  final DatabaseService _databaseService = DatabaseService();

  // Get all recurring transactions with proper error handling
  Future<List<RecurringTransaction>> getAllRecurringTransactions() async {
    try {
      return await _databaseService.getAllRecurringTransactions();
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  // Get only active recurring transactions
  Future<List<RecurringTransaction>> getActiveRecurringTransactions() async {
    try {
      final allRecurring = await _databaseService.getAllRecurringTransactions();
      return allRecurring.where((r) => r.isActive && !r.isCompleted).toList();
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  // Add a new recurring transaction and create all installment transactions
  Future<void> addRecurringTransaction({
    required String title,
    required double value,
    required bool isExpense,
    required int totalInstallments,
    required DateTime startDate,
    required int paymentDay,
  }) async {
    try {
      // Input validation
      _validateRecurringTransactionInput(
        title: title,
        value: value,
        totalInstallments: totalInstallments,
        paymentDay: paymentDay,
      );

      // Create the recurring transaction record
      final recurringTransaction = RecurringTransaction(
        title: title.trim(),
        value: value,
        isExpense: isExpense,
        totalInstallments: totalInstallments,
        currentInstallment: 1,
        startDate: startDate,
        paymentDay: paymentDay,
        nextOccurrenceDate: startDate,
        isActive: true,
      );

      // Save the recurring transaction
      await _databaseService.addRecurringTransaction(recurringTransaction);

      // Create all installment transactions
      await _createAllInstallmentTransactions(recurringTransaction);

      print('Transação recorrente criada com ${totalInstallments} parcelas');
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  // Create all installment transactions at once
  Future<void> _createAllInstallmentTransactions(
    RecurringTransaction recurring,
  ) async {
    try {
      for (int i = 1; i <= recurring.totalInstallments; i++) {
        // Calculate the date for this installment
        final installmentDate = _calculateInstallmentDate(
          recurring.startDate,
          i - 1, // 0-indexed for first installment
          recurring.paymentDay,
        );

        // Create the transaction with installment info in title
        final transaction = Transaction(
          title: '${recurring.title} (${i}/${recurring.totalInstallments})',
          value: recurring.value,
          date: installmentDate,
          isExpense: recurring.isExpense,
        );

        await _databaseService.addTransaction(transaction);
      }

      print('${recurring.totalInstallments} parcelas criadas com sucesso');
    } catch (e) {
      print('Erro ao criar parcelas: $e');
      rethrow;
    }
  }

  // Calculate the date for a specific installment
  DateTime _calculateInstallmentDate(
    DateTime startDate,
    int monthsToAdd,
    int paymentDay,
  ) {
    // Add months to the start date
    int targetYear = startDate.year;
    int targetMonth = startDate.month + monthsToAdd;

    // Handle year overflow
    while (targetMonth > 12) {
      targetMonth -= 12;
      targetYear += 1;
    }

    // Ensure the day is valid for the target month
    int targetDay = paymentDay;
    final lastDayOfMonth = DateTime(targetYear, targetMonth + 1, 0).day;
    if (targetDay > lastDayOfMonth) {
      targetDay = lastDayOfMonth;
    }

    return DateTime(
      targetYear,
      targetMonth,
      targetDay,
      startDate.hour,
      startDate.minute,
      startDate.second,
    );
  }

  // Cancel/deactivate a recurring transaction
  Future<void> cancelRecurringTransaction(
    RecurringTransaction recurring,
  ) async {
    try {
      if (recurring.key == null) {
        throw const AppError(
          message: 'Transação recorrente inválida',
          type: ErrorType.validation,
        );
      }

      recurring.isActive = false;
      await _databaseService.updateRecurringTransaction(recurring);

      print('Transação recorrente cancelada: ${recurring.title}');
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  // Delete a recurring transaction
  Future<void> deleteRecurringTransaction(int key) async {
    try {
      if (key < 0) {
        throw const AppError(
          message: 'ID da transação recorrente inválido',
          type: ErrorType.validation,
        );
      }

      await _databaseService.deleteRecurringTransaction(key);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  // Get financial summary for recurring transactions
  Map<String, dynamic> getRecurringSummary(
    List<RecurringTransaction> recurringTransactions,
  ) {
    try {
      double totalCommitted = 0.0;
      double totalRemaining = 0.0;
      int activeCount = 0;

      for (final recurring in recurringTransactions) {
        if (recurring.isActive && !recurring.isCompleted) {
          totalCommitted += recurring.totalAmount;
          totalRemaining += recurring.remainingAmount;
          activeCount++;
        }
      }

      return {
        'totalCommitted': totalCommitted,
        'totalRemaining': totalRemaining,
        'activeCount': activeCount,
      };
    } catch (e) {
      return {'totalCommitted': 0.0, 'totalRemaining': 0.0, 'activeCount': 0};
    }
  }

  // Private validation method
  void _validateRecurringTransactionInput({
    required String title,
    required double value,
    required int totalInstallments,
    required int paymentDay,
  }) {
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

    // Installments validation
    if (totalInstallments <= 0) {
      errors.add('O número de parcelas deve ser maior que zero');
    } else if (totalInstallments > 360) {
      errors.add('O número de parcelas não pode ser maior que 360 (30 anos)');
    }

    // Payment day validation
    if (paymentDay < 1 || paymentDay > 31) {
      errors.add('O dia de pagamento deve estar entre 1 e 31');
    }

    // Throw validation error if any issues found
    if (errors.isNotEmpty) {
      throw AppError(message: errors.join('\n'), type: ErrorType.validation);
    }
  }
}
