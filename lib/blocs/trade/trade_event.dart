import 'package:equatable/equatable.dart';
import 'package:finanapp/models/trade.dart';

abstract class TradeEvent extends Equatable {
  const TradeEvent();

  @override
  List<Object?> get props => [];
}

// Load all trades
class LoadTrades extends TradeEvent {
  const LoadTrades();
}

// Refresh trades (for pull-to-refresh)
class RefreshTrades extends TradeEvent {
  const RefreshTrades();
}

// Add a new trade
class AddTrade extends TradeEvent {
  final String title;
  final double value;
  final bool isExpense;

  const AddTrade({
    required this.title,
    required this.value,
    required this.isExpense,
  });

  @override
  List<Object> get props => [title, value, isExpense];
}

// Update an existing trade
class UpdateTrade extends TradeEvent {
  final Trade trade;

  const UpdateTrade({required this.trade});

  @override
  List<Object> get props => [trade];
}

// Delete a trade
class DeleteTrade extends TradeEvent {
  final int key;

  const DeleteTrade({required this.key});

  @override
  List<Object> get props => [key];
}

// Clear all trades
class ClearAllTrades extends TradeEvent {
  const ClearAllTrades();
}

// Search trades
class SearchTrades extends TradeEvent {
  final String query;

  const SearchTrades({required this.query});

  @override
  List<Object> get props => [query];
}

// Filter trades by date range
class FilterTradesByDateRange extends TradeEvent {
  final DateTime startDate;
  final DateTime endDate;

  const FilterTradesByDateRange({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object> get props => [startDate, endDate];
}

// Filter trades by type (expense/income)
class FilterTradesByType extends TradeEvent {
  final bool? isExpense; // null = all, true = expenses, false = income

  const FilterTradesByType({required this.isExpense});

  @override
  List<Object?> get props => [isExpense];
}

// Clear any active filters
class ClearFilters extends TradeEvent {
  const ClearFilters();
}