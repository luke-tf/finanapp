import 'package:equatable/equatable.dart';
import 'package:finanapp/models/trade.dart';
import 'package:finanapp/services/error_handler.dart';

abstract class TradeState extends Equatable {
  const TradeState();

  @override
  List<Object?> get props => [];
}

// Initial state
class TradeInitial extends TradeState {
  const TradeInitial();
}

// Loading state
class TradeLoading extends TradeState {
  const TradeLoading();
}

// Loaded state with data
class TradeLoaded extends TradeState {
  final List<Trade> trades;
  final List<Trade> filteredTrades;
  final bool isAddingTrade;
  final bool isDeletingTrade;
  final bool isUpdatingTrade;
  final String? searchQuery;
  final DateTime? filterStartDate;
  final DateTime? filterEndDate;
  final bool? filterByType; // null = all, true = expenses, false = income

  const TradeLoaded({
    required this.trades,
    this.filteredTrades = const [],
    this.isAddingTrade = false,
    this.isDeletingTrade = false,
    this.isUpdatingTrade = false,
    this.searchQuery,
    this.filterStartDate,
    this.filterEndDate,
    this.filterByType,
  });

  // Convenience getters
  List<Trade> get displayTrades =>
      filteredTrades.isNotEmpty ||
          searchQuery != null ||
          filterStartDate != null ||
          filterByType != null
      ? filteredTrades
      : trades;

  bool get hasTrades => trades.isNotEmpty;
  bool get hasFilters =>
      searchQuery != null || filterStartDate != null || filterByType != null;

  double get currentBalance {
    return displayTrades.fold<double>(0.0, (sum, trade) {
      return trade.isExpense
          ? sum - trade.value
          : sum + trade.value;
    });
  }

  double get totalIncome {
    return displayTrades
        .where((t) => !t.isExpense)
        .fold<double>(0.0, (sum, trade) => sum + trade.value);
  }

  double get totalExpenses {
    return displayTrades
        .where((t) => t.isExpense)
        .fold<double>(0.0, (sum, trade) => sum + trade.value);
  }

  List<Trade> get recentTrades {
    final cutoffDate = DateTime.now().subtract(const Duration(days: 30));
    return displayTrades
        .where((trade) => trade.date.isAfter(cutoffDate))
        .toList();
  }

  @override
  List<Object?> get props => [
    trades,
    filteredTrades,
    isAddingTrade,
    isDeletingTrade,
    isUpdatingTrade,
    searchQuery,
    filterStartDate,
    filterEndDate,
    filterByType,
  ];

  // CopyWith method for state updates
  TradeLoaded copyWith({
    List<Trade>? trades,
    List<Trade>? filteredTrades,
    bool? isAddingTrade,
    bool? isDeletingTrade,
    bool? isUpdatingTrade,
    String? searchQuery,
    DateTime? filterStartDate,
    DateTime? filterEndDate,
    bool? filterByType,
    bool clearSearch = false,
    bool clearDateFilter = false,
    bool clearTypeFilter = false,
  }) {
    return TradeLoaded(
      trades: trades ?? this.trades,
      filteredTrades: filteredTrades ?? this.filteredTrades,
      isAddingTrade: isAddingTrade ?? this.isAddingTrade,
      isDeletingTrade:
          isDeletingTrade ?? this.isDeletingTrade,
      isUpdatingTrade:
          isUpdatingTrade ?? this.isUpdatingTrade,
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
class TradeError extends TradeState {
  final AppError error;
  final List<Trade> previousTrades;

  const TradeError({
    required this.error,
    this.previousTrades = const [],
  });

  @override
  List<Object> get props => [error, previousTrades];
}

// Operation success state (for showing success messages)
class TradeOperationSuccess extends TradeState {
  final String message;
  final List<Trade> trades;
  final TradeOperationType operationType;

  const TradeOperationSuccess({
    required this.message,
    required this.trades,
    required this.operationType,
  });

  @override
  List<Object> get props => [message, trades, operationType];
}

enum TradeOperationType { add, update, delete, clear }