import 'package:equatable/equatable.dart';
import 'package:finanapp/models/transaction.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

// Load all transactions
class LoadTransactions extends TransactionEvent {
  const LoadTransactions();
}

// Refresh transactions (for pull-to-refresh)
class RefreshTransactions extends TransactionEvent {
  const RefreshTransactions();
}

// Add a new transaction
class AddTransaction extends TransactionEvent {
  final String title;
  final double value;
  final bool isExpense;

  const AddTransaction({
    required this.title,
    required this.value,
    required this.isExpense,
  });

  @override
  List<Object> get props => [title, value, isExpense];
}

// Update an existing transaction
class UpdateTransaction extends TransactionEvent {
  final Transaction transaction;

  const UpdateTransaction({required this.transaction});

  @override
  List<Object> get props => [transaction];
}

// Delete a transaction
class DeleteTransaction extends TransactionEvent {
  final int key;

  const DeleteTransaction({required this.key});

  @override
  List<Object> get props => [key];
}

// Clear all transactions
class ClearAllTransactions extends TransactionEvent {
  const ClearAllTransactions();
}

// Search transactions
class SearchTransactions extends TransactionEvent {
  final String query;

  const SearchTransactions({required this.query});

  @override
  List<Object> get props => [query];
}

// Filter transactions by date range
class FilterTransactionsByDateRange extends TransactionEvent {
  final DateTime startDate;
  final DateTime endDate;

  const FilterTransactionsByDateRange({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object> get props => [startDate, endDate];
}

// Filter transactions by type (expense/income)
class FilterTransactionsByType extends TransactionEvent {
  final bool? isExpense; // null = all, true = expenses, false = income

  const FilterTransactionsByType({required this.isExpense});

  @override
  List<Object?> get props => [isExpense];
}

// Clear any active filters
class ClearFilters extends TransactionEvent {
  const ClearFilters();
}
