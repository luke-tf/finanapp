import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finanapp/blocs/trade/trade_event.dart';
import 'package:finanapp/blocs/trade/trade_state.dart';
import 'package:finanapp/services/trade_service.dart';
import 'package:finanapp/services/error_handler.dart';
import 'package:finanapp/models/trade.dart';
import 'package:finanapp/utils/constants.dart';

class TradeBloc extends Bloc<TradeEvent, TradeState> {
  final TradeService _tradeService;

  TradeBloc({TradeService? tradeService})
    : _tradeService = tradeService ?? TradeService(),
      super(const TradeInitial()) {
    // Register event handlers
    on<LoadTrades>(_onLoadTrades);
    on<RefreshTrades>(_onRefreshTrades);
    on<AddTrade>(_onAddTrade);
    on<UpdateTrade>(_onUpdateTrade);
    on<DeleteTrade>(_onDeleteTrade);
    on<ClearAllTrades>(_onClearAllTrades);
    on<SearchTrades>(_onSearchTrades);
    on<FilterTradesByDateRange>(_onFilterByDateRange);
    on<FilterTradesByType>(_onFilterByType);
    on<ClearFilters>(_onClearFilters);
  }

  // Load trades
  Future<void> _onLoadTrades(LoadTrades event, Emitter<TradeState> emit) async {
    emit(const TradeLoading());

    try {
      final trades = await _tradeService.getAllTrades();
      emit(TradeLoaded(trades: trades));
    } catch (e) {
      final error = e is AppError ? e : ErrorHandler.handleException(e);
      emit(TradeError(error: error));
    }
  }

  // Refresh trades
  Future<void> _onRefreshTrades(
    RefreshTrades event,
    Emitter<TradeState> emit,
  ) async {
    // Don't show loading if we already have data
    if (state is! TradeLoaded) {
      emit(const TradeLoading());
    }

    try {
      final trades = await _tradeService.getAllTrades();
      emit(TradeLoaded(trades: trades));
    } catch (e) {
      final error = e is AppError ? e : ErrorHandler.handleException(e);
      final previousTrades = state is TradeLoaded
          ? (state as TradeLoaded).trades
          : <Trade>[];
      emit(TradeError(error: error, previousTrades: previousTrades));
    }
  }

  // Add trade
  Future<void> _onAddTrade(AddTrade event, Emitter<TradeState> emit) async {
    if (state is! TradeLoaded) return;

    final currentState = state as TradeLoaded;
    emit(currentState.copyWith(isAddingTrade: true));

    try {
      await _tradeService.addTrade(
        title: event.title,
        value: event.value,
        isExpense: event.isExpense,
      );

      // Reload trades after adding
      final trades = await _tradeService.getAllTrades();

      // Show success message
      emit(
        TradeOperationSuccess(
          message: event.isExpense
              ? AppConstants.expenseAddedSuccess
              : AppConstants.incomeAddedSuccess,
          trades: trades,
          operationType: TradeOperationType.add,
        ),
      );

      // Return to loaded state with updated data
      emit(TradeLoaded(trades: trades));
    } catch (e) {
      final error = e is AppError ? e : ErrorHandler.handleException(e);
      emit(currentState.copyWith(isAddingTrade: false));
      emit(TradeError(error: error, previousTrades: currentState.trades));
    }
  }

  // Update trade
  Future<void> _onUpdateTrade(
    UpdateTrade event,
    Emitter<TradeState> emit,
  ) async {
    if (state is! TradeLoaded) return;

    final currentState = state as TradeLoaded;
    emit(currentState.copyWith(isUpdatingTrade: true));

    try {
      await _tradeService.updateTrade(event.trade);

      // Reload trades after updating
      final trades = await _tradeService.getAllTrades();

      // Show success message
      emit(
        TradeOperationSuccess(
          message:
              'Transação atualizada com sucesso!', // TODO: Refactor this string
          trades: trades,
          operationType: TradeOperationType.update,
        ),
      );

      // Return to loaded state with updated data
      emit(TradeLoaded(trades: trades));
    } catch (e) {
      final error = e is AppError ? e : ErrorHandler.handleException(e);
      emit(currentState.copyWith(isUpdatingTrade: false));
      emit(TradeError(error: error, previousTrades: currentState.trades));
    }
  }

  // Delete trade
  Future<void> _onDeleteTrade(
    DeleteTrade event,
    Emitter<TradeState> emit,
  ) async {
    if (state is! TradeLoaded) return;

    final currentState = state as TradeLoaded;
    emit(currentState.copyWith(isDeletingTrade: true));

    try {
      await _tradeService.deleteTrade(event.key);

      // Reload trades after deleting
      final trades = await _tradeService.getAllTrades();

      // Show success message
      emit(
        TradeOperationSuccess(
          message: AppConstants.tradeRemovedSuccess, // TODO: Refactor this
          trades: trades,
          operationType: TradeOperationType.delete,
        ),
      );

      // Return to loaded state with updated data
      emit(TradeLoaded(trades: trades));
    } catch (e) {
      final error = e is AppError ? e : ErrorHandler.handleException(e);
      emit(currentState.copyWith(isDeletingTrade: false));
      emit(TradeError(error: error, previousTrades: currentState.trades));
    }
  }

  // Clear all trades
  Future<void> _onClearAllTrades(
    ClearAllTrades event,
    Emitter<TradeState> emit,
  ) async {
    if (state is! TradeLoaded) return;

    final currentState = state as TradeLoaded;

    try {
      await _tradeService.clearAllTrades();

      // Show success message
      emit(
        const TradeOperationSuccess(
          message: 'Todas as transações foram removidas', // TODO: Refactor this
          trades: [],
          operationType: TradeOperationType.clear,
        ),
      );

      // Return to loaded state with empty data
      emit(const TradeLoaded(trades: []));
    } catch (e) {
      final error = e is AppError ? e : ErrorHandler.handleException(e);
      emit(TradeError(error: error, previousTrades: currentState.trades));
    }
  }

  // Search trades
  void _onSearchTrades(SearchTrades event, Emitter<TradeState> emit) {
    if (state is! TradeLoaded) return;

    final currentState = state as TradeLoaded;

    if (event.query.isEmpty) {
      emit(
        currentState.copyWith(
          filteredTrades: [],
          searchQuery: null,
          clearSearch: true,
        ),
      );
      return;
    }

    final filteredTrades = _applyFilters(
      currentState.trades,
      searchQuery: event.query,
      filterStartDate: currentState.filterStartDate,
      filterEndDate: currentState.filterEndDate,
      filterByType: currentState.filterByType,
    );

    emit(
      currentState.copyWith(
        filteredTrades: filteredTrades,
        searchQuery: event.query,
      ),
    );
  }

  // Filter by date range
  void _onFilterByDateRange(
    FilterTradesByDateRange event,
    Emitter<TradeState> emit,
  ) {
    if (state is! TradeLoaded) return;

    final currentState = state as TradeLoaded;

    final filteredTrades = _applyFilters(
      currentState.trades,
      searchQuery: currentState.searchQuery,
      filterStartDate: event.startDate,
      filterEndDate: event.endDate,
      filterByType: currentState.filterByType,
    );

    emit(
      currentState.copyWith(
        filteredTrades: filteredTrades,
        filterStartDate: event.startDate,
        filterEndDate: event.endDate,
      ),
    );
  }

  // Filter by type
  void _onFilterByType(FilterTradesByType event, Emitter<TradeState> emit) {
    if (state is! TradeLoaded) return;

    final currentState = state as TradeLoaded;

    final filteredTrades = _applyFilters(
      currentState.trades,
      searchQuery: currentState.searchQuery,
      filterStartDate: currentState.filterStartDate,
      filterEndDate: currentState.filterEndDate,
      filterByType: event.isExpense,
    );

    emit(
      currentState.copyWith(
        filteredTrades: filteredTrades,
        filterByType: event.isExpense,
      ),
    );
  }

  // Clear all filters
  void _onClearFilters(ClearFilters event, Emitter<TradeState> emit) {
    if (state is! TradeLoaded) return;

    final currentState = state as TradeLoaded;

    emit(
      currentState.copyWith(
        filteredTrades: [],
        searchQuery: null,
        filterStartDate: null,
        filterEndDate: null,
        filterByType: null,
        clearSearch: true,
        clearDateFilter: true,
        clearTypeFilter: true,
      ),
    );
  }

  // Helper method to apply all filters
  List<Trade> _applyFilters(
    List<Trade> trades, {
    String? searchQuery,
    DateTime? filterStartDate,
    DateTime? filterEndDate,
    bool? filterByType,
  }) {
    var filtered = trades;

    // Apply search filter
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final lowercaseQuery = searchQuery.toLowerCase();
      filtered = filtered.where((trade) {
        return trade.title.toLowerCase().contains(lowercaseQuery);
      }).toList();
    }

    // Apply date range filter
    if (filterStartDate != null && filterEndDate != null) {
      filtered = filtered.where((trade) {
        return trade.date.isAfter(
              filterStartDate.subtract(const Duration(days: 1)),
            ) &&
            trade.date.isBefore(filterEndDate.add(const Duration(days: 1)));
      }).toList();
    }

    // Apply type filter
    if (filterByType != null) {
      filtered = filtered.where((trade) {
        return trade.isExpense == filterByType;
      }).toList();
    }

    return filtered;
  }
}
