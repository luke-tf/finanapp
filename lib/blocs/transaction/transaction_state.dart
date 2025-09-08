import 'package:equatable/equatable.dart';
import 'package:finanapp/models/transaction.dart';
import 'package:finanapp/services/error_handler.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => [];
}

// Initial state
class TransactionInitial extends TransactionState {
  const TransactionInitial();
}

// Loading state
class TransactionLoading extends TransactionState {
  const TransactionLoading();
}

// Loaded state with data
class TransactionLoaded extends TransactionState {
  final List<Transaction> transactions;
  final List<Transaction> filteredTransactions;
  final bool isAddingTransaction;
  final bool isDeletingTransaction;
  final bool isUpdatingTransaction;
  final String? searchQuery;
  final DateTime? filterStartDate;
  final DateTime? filterEndDate;
  final bool? filterByType; // null = all, true = expenses, false = income

  const TransactionLoaded({
    required this.transactions,
    this.filteredTransactions = const [],
    this.isAddingTransaction = false,
    this.isDeletingTransaction = false,
    this.isUpdatingTransaction = false,
    this.searchQuery,
    this.filterStartDate,
    this.filterEndDate,
    this.filterByType,
  });

  // Convenience getters
  List<Transaction> get displayTransactions =>
      filteredTransactions.isNotEmpty ||
          searchQuery != null ||
          filterStartDate != null ||
          filterByType != null
      ? filteredTransactions
      : transactions;

  bool get hasTransactions => transactions.isNotEmpty;
  bool get hasFilters =>
      searchQuery != null || filterStartDate != null || filterByType != null;

  double get currentBalance {
    return displayTransactions.fold<double>(0.0, (sum, transaction) {
      return transaction.isExpense
          ? sum - transaction.value
          : sum + transaction.value;
    });
  }

  double get totalIncome {
    return displayTransactions
        .where((t) => !t.isExpense)
        .fold<double>(0.0, (sum, transaction) => sum + transaction.value);
  }

  double get totalExpenses {
    return displayTransactions
        .where((t) => t.isExpense)
        .fold<double>(0.0, (sum, transaction) => sum + transaction.value);
  }

  List<Transaction> get recentTransactions {
    final cutoffDate = DateTime.now().subtract(const Duration(days: 30));
    return displayTransactions
        .where((transaction) => transaction.date.isAfter(cutoffDate))
        .toList();
  }

  @override
  List<Object?> get props => [
    transactions,
    filteredTransactions,
    isAddingTransaction,
    isDeletingTransaction,
    isUpdatingTransaction,
    searchQuery,
    filterStartDate,
    filterEndDate,
    filterByType,
  ];

  // CopyWith method for state updates
  TransactionLoaded copyWith({
    List<Transaction>? transactions,
    List<Transaction>? filteredTransactions,
    bool? isAddingTransaction,
    bool? isDeletingTransaction,
    bool? isUpdatingTransaction,
    String? searchQuery,
    DateTime? filterStartDate,
    DateTime? filterEndDate,
    bool? filterByType,
    bool clearSearch = false,
    bool clearDateFilter = false,
    bool clearTypeFilter = false,
  }) {
    return TransactionLoaded(
      transactions: transactions ?? this.transactions,
      filteredTransactions: filteredTransactions ?? this.filteredTransactions,
      isAddingTransaction: isAddingTransaction ?? this.isAddingTransaction,
      isDeletingTransaction:
          isDeletingTransaction ?? this.isDeletingTransaction,
      isUpdatingTransaction:
          isUpdatingTransaction ?? this.isUpdatingTransaction,
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
      filterStartDate: clearDateFilter
          ? null
          : (filterStartDate ?? this.filterStartDate),
      filterEndDate: clearDateFilter
          ? null
          : (filterEndDate ?? this.filterEndDate),
      filterByType: clearTypeFilter
          ? null
          : (filterByType ?? this.filterByType),
    );
  }
}

// Error state
class TransactionError extends TransactionState {
  final AppError error;
  final List<Transaction> previousTransactions;

  const TransactionError({
    required this.error,
    this.previousTransactions = const [],
  });

  @override
  List<Object> get props => [error, previousTransactions];
}

// Operation success state (for showing success messages)
class TransactionOperationSuccess extends TransactionState {
  final String message;
  final List<Transaction> transactions;
  final TransactionOperationType operationType;

  const TransactionOperationSuccess({
    required this.message,
    required this.transactions,
    required this.operationType,
  });

  @override
  List<Object> get props => [message, transactions, operationType];
}

enum TransactionOperationType { add, update, delete, clear }
