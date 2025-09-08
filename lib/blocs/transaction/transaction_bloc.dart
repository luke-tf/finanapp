import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finanapp/blocs/transaction/transaction_event.dart';
import 'package:finanapp/blocs/transaction/transaction_state.dart';
import 'package:finanapp/services/transaction_service.dart';
import 'package:finanapp/services/error_handler.dart';
import 'package:finanapp/models/transaction.dart';
import 'package:finanapp/utils/constants.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionService _transactionService;

  TransactionBloc({TransactionService? transactionService})
    : _transactionService = transactionService ?? TransactionService(),
      super(const TransactionInitial()) {
    // Register event handlers
    on<LoadTransactions>(_onLoadTransactions);
    on<RefreshTransactions>(_onRefreshTransactions);
    on<AddTransaction>(_onAddTransaction);
    on<UpdateTransaction>(_onUpdateTransaction);
    on<DeleteTransaction>(_onDeleteTransaction);
    on<ClearAllTransactions>(_onClearAllTransactions);
    on<SearchTransactions>(_onSearchTransactions);
    on<FilterTransactionsByDateRange>(_onFilterByDateRange);
    on<FilterTransactionsByType>(_onFilterByType);
    on<ClearFilters>(_onClearFilters);
  }

  // Load transactions
  Future<void> _onLoadTransactions(
    LoadTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    emit(const TransactionLoading());

    try {
      final transactions = await _transactionService.getAllTransactions();
      emit(TransactionLoaded(transactions: transactions));
    } catch (e) {
      final error = e is AppError ? e : ErrorHandler.handleException(e);
      emit(TransactionError(error: error));
    }
  }

  // Refresh transactions
  Future<void> _onRefreshTransactions(
    RefreshTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    // Don't show loading if we already have data
    if (state is! TransactionLoaded) {
      emit(const TransactionLoading());
    }

    try {
      final transactions = await _transactionService.getAllTransactions();
      emit(TransactionLoaded(transactions: transactions));
    } catch (e) {
      final error = e is AppError ? e : ErrorHandler.handleException(e);
      final previousTransactions = state is TransactionLoaded
          ? (state as TransactionLoaded).transactions
          : <Transaction>[];
      emit(
        TransactionError(
          error: error,
          previousTransactions: previousTransactions,
        ),
      );
    }
  }

  // Add transaction
  Future<void> _onAddTransaction(
    AddTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    if (state is! TransactionLoaded) return;

    final currentState = state as TransactionLoaded;
    emit(currentState.copyWith(isAddingTransaction: true));

    try {
      await _transactionService.addTransaction(
        title: event.title,
        value: event.value,
        isExpense: event.isExpense,
      );

      // Reload transactions after adding
      final transactions = await _transactionService.getAllTransactions();

      // Show success message
      emit(
        TransactionOperationSuccess(
          message: event.isExpense
              ? AppConstants.expenseAddedSuccess
              : AppConstants.incomeAddedSuccess,
          transactions: transactions,
          operationType: TransactionOperationType.add,
        ),
      );

      // Return to loaded state with updated data
      emit(TransactionLoaded(transactions: transactions));
    } catch (e) {
      final error = e is AppError ? e : ErrorHandler.handleException(e);
      emit(currentState.copyWith(isAddingTransaction: false));
      emit(
        TransactionError(
          error: error,
          previousTransactions: currentState.transactions,
        ),
      );
    }
  }

  // Update transaction
  Future<void> _onUpdateTransaction(
    UpdateTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    if (state is! TransactionLoaded) return;

    final currentState = state as TransactionLoaded;
    emit(currentState.copyWith(isUpdatingTransaction: true));

    try {
      await _transactionService.updateTransaction(event.transaction);

      // Reload transactions after updating
      final transactions = await _transactionService.getAllTransactions();

      // Show success message
      emit(
        TransactionOperationSuccess(
          message: 'Transação atualizada com sucesso!',
          transactions: transactions,
          operationType: TransactionOperationType.update,
        ),
      );

      // Return to loaded state with updated data
      emit(TransactionLoaded(transactions: transactions));
    } catch (e) {
      final error = e is AppError ? e : ErrorHandler.handleException(e);
      emit(currentState.copyWith(isUpdatingTransaction: false));
      emit(
        TransactionError(
          error: error,
          previousTransactions: currentState.transactions,
        ),
      );
    }
  }

  // Delete transaction
  Future<void> _onDeleteTransaction(
    DeleteTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    if (state is! TransactionLoaded) return;

    final currentState = state as TransactionLoaded;
    emit(currentState.copyWith(isDeletingTransaction: true));

    try {
      await _transactionService.deleteTransaction(event.key);

      // Reload transactions after deleting
      final transactions = await _transactionService.getAllTransactions();

      // Show success message
      emit(
        TransactionOperationSuccess(
          message: AppConstants.transactionRemovedSuccess,
          transactions: transactions,
          operationType: TransactionOperationType.delete,
        ),
      );

      // Return to loaded state with updated data
      emit(TransactionLoaded(transactions: transactions));
    } catch (e) {
      final error = e is AppError ? e : ErrorHandler.handleException(e);
      emit(currentState.copyWith(isDeletingTransaction: false));
      emit(
        TransactionError(
          error: error,
          previousTransactions: currentState.transactions,
        ),
      );
    }
  }

  // Clear all transactions
  Future<void> _onClearAllTransactions(
    ClearAllTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    if (state is! TransactionLoaded) return;

    final currentState = state as TransactionLoaded;

    try {
      await _transactionService.clearAllTransactions();

      // Show success message
      emit(
        const TransactionOperationSuccess(
          message: 'Todas as transações foram removidas',
          transactions: [],
          operationType: TransactionOperationType.clear,
        ),
      );

      // Return to loaded state with empty data
      emit(const TransactionLoaded(transactions: []));
    } catch (e) {
      final error = e is AppError ? e : ErrorHandler.handleException(e);
      emit(
        TransactionError(
          error: error,
          previousTransactions: currentState.transactions,
        ),
      );
    }
  }

  // Search transactions
  void _onSearchTransactions(
    SearchTransactions event,
    Emitter<TransactionState> emit,
  ) {
    if (state is! TransactionLoaded) return;

    final currentState = state as TransactionLoaded;

    if (event.query.isEmpty) {
      emit(
        currentState.copyWith(
          filteredTransactions: [],
          searchQuery: null,
          clearSearch: true,
        ),
      );
      return;
    }

    final filteredTransactions = _applyFilters(
      currentState.transactions,
      searchQuery: event.query,
      filterStartDate: currentState.filterStartDate,
      filterEndDate: currentState.filterEndDate,
      filterByType: currentState.filterByType,
    );

    emit(
      currentState.copyWith(
        filteredTransactions: filteredTransactions,
        searchQuery: event.query,
      ),
    );
  }

  // Filter by date range
  void _onFilterByDateRange(
    FilterTransactionsByDateRange event,
    Emitter<TransactionState> emit,
  ) {
    if (state is! TransactionLoaded) return;

    final currentState = state as TransactionLoaded;

    final filteredTransactions = _applyFilters(
      currentState.transactions,
      searchQuery: currentState.searchQuery,
      filterStartDate: event.startDate,
      filterEndDate: event.endDate,
      filterByType: currentState.filterByType,
    );

    emit(
      currentState.copyWith(
        filteredTransactions: filteredTransactions,
        filterStartDate: event.startDate,
        filterEndDate: event.endDate,
      ),
    );
  }

  // Filter by type
  void _onFilterByType(
    FilterTransactionsByType event,
    Emitter<TransactionState> emit,
  ) {
    if (state is! TransactionLoaded) return;

    final currentState = state as TransactionLoaded;

    final filteredTransactions = _applyFilters(
      currentState.transactions,
      searchQuery: currentState.searchQuery,
      filterStartDate: currentState.filterStartDate,
      filterEndDate: currentState.filterEndDate,
      filterByType: event.isExpense,
    );

    emit(
      currentState.copyWith(
        filteredTransactions: filteredTransactions,
        filterByType: event.isExpense,
      ),
    );
  }

  // Clear all filters
  void _onClearFilters(ClearFilters event, Emitter<TransactionState> emit) {
    if (state is! TransactionLoaded) return;

    final currentState = state as TransactionLoaded;

    emit(
      currentState.copyWith(
        filteredTransactions: [],
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
  List<Transaction> _applyFilters(
    List<Transaction> transactions, {
    String? searchQuery,
    DateTime? filterStartDate,
    DateTime? filterEndDate,
    bool? filterByType,
  }) {
    var filtered = transactions;

    // Apply search filter
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final lowercaseQuery = searchQuery.toLowerCase();
      filtered = filtered.where((transaction) {
        return transaction.title.toLowerCase().contains(lowercaseQuery);
      }).toList();
    }

    // Apply date range filter
    if (filterStartDate != null && filterEndDate != null) {
      filtered = filtered.where((transaction) {
        return transaction.date.isAfter(
              filterStartDate.subtract(const Duration(days: 1)),
            ) &&
            transaction.date.isBefore(
              filterEndDate.add(const Duration(days: 1)),
            );
      }).toList();
    }

    // Apply type filter
    if (filterByType != null) {
      filtered = filtered.where((transaction) {
        return transaction.isExpense == filterByType;
      }).toList();
    }

    return filtered;
  }
}
