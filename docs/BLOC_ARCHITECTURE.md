# 🏛️ BLoC Architecture Guide

This document explains the BLoC (Business Logic Component) architecture implementation in Finanapp.

## 📖 Table of Contents
- [Overview](#overview)
- [Architecture Pattern](#architecture-pattern)
- [Events](#events)
- [States](#states)
- [BLoC Implementation](#bloc-implementation)
- [Usage Examples](#usage-examples)
- [Testing](#testing)
- [Best Practices](#best-practices)

## 🎯 Overview

BLoC is a design pattern that separates business logic from the UI. It uses reactive programming to manage application state through streams of events and states.

### Why BLoC?
- **Separation of Concerns** - UI and business logic are separate
- **Testability** - Easy to test business logic in isolation
- **Reusability** - BLoC can be shared between different UI components
- **Predictability** - Clear data flow and state management
- **Scalability** - Easy to add new features and states

## 🏗️ Architecture Pattern

```
┌─────────────┐    Events     ┌──────────────┐    Method Calls    ┌─────────────────┐
│     UI      │ ────────────► │     BLoC     │ ──────────────────► │    Services     │
│  (Widgets)  │               │ (Business    │                     │ (Data Sources)  │
│             │ ◄──────────── │   Logic)     │ ◄────────────────── │                 │
└─────────────┘    States     └──────────────┘    Responses       └─────────────────┘
```

### Data Flow
1. **UI emits Events** to BLoC (user interactions)
2. **BLoC processes Events** and calls appropriate services
3. **Services** interact with data sources (database, API)
4. **BLoC emits States** based on service responses
5. **UI rebuilds** based on new states

## 🎬 Events

Events represent user intentions and system triggers. They are immutable objects that extend `Equatable`.

### Transaction Events

```dart
// Load all transactions
class LoadTransactions extends TransactionEvent {
  const LoadTransactions();
}

// Add new transaction
class AddTransaction extends TransactionEvent {
  final String title;
  final double value;
  final bool isExpense;
  
  const AddTransaction({
    required this.title,
    required this.value,
    required this.isExpense,
  });
}

// Update existing transaction
class UpdateTransaction extends TransactionEvent {
  final Transaction transaction;
  
  const UpdateTransaction({required this.transaction});
}

// Delete transaction
class DeleteTransaction extends TransactionEvent {
  final int key;
  
  const DeleteTransaction({required this.key});
}
```

### Event Guidelines
- **Immutable** - All events should be immutable
- **Descriptive Names** - Clear action names (LoadTransactions, not LoadData)
- **Required Data** - Include only data needed for the operation
- **Validation** - Basic validation can be done in event constructors

## 🏛️ States

States represent the current condition of the application. They are also immutable and extend `Equatable`.

### Transaction States

```dart
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
  
  const TransactionLoaded({
    required this.transactions,
    this.filteredTransactions = const [],
    this.isAddingTransaction = false,
    this.isDeletingTransaction = false,
    this.isUpdatingTransaction = false,
  });
}

// Error state
class TransactionError extends TransactionState {
  final AppError error;
  final List<Transaction> previousTransactions;
  
  const TransactionError({
    required this.error,
    this.previousTransactions = const [],
  });
}

// Success state for operations
class TransactionOperationSuccess extends TransactionState {
  final String message;
  final List<Transaction> transactions;
  final TransactionOperationType operationType;
  
  const TransactionOperationSuccess({
    required this.message,
    required this.transactions,
    required this.operationType,
  });
}
```

### State Guidelines
- **Single Responsibility** - Each state represents one condition
- **Complete Information** - States should contain all data needed by UI
- **Computed Properties** - Use getters for derived data
- **Preserve Context** - Error states can preserve previous data

## 🧠 BLoC Implementation

### TransactionBloc Structure

```dart
class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionService _transactionService;
  
  TransactionBloc({TransactionService? transactionService})
      : _transactionService = transactionService ?? TransactionService(),
        super(const TransactionInitial()) {
    
    // Register event handlers
    on<LoadTransactions>(_onLoadTransactions);
    on<AddTransaction>(_onAddTransaction);
    on<UpdateTransaction>(_onUpdateTransaction);
    on<DeleteTransaction>(_onDeleteTransaction);
    on<SearchTransactions>(_onSearchTransactions);
  }
}
```

### Event Handler Pattern

```dart
Future<void> _onAddTransaction(
  AddTransaction event,
  Emitter<TransactionState> emit,
) async {
  // Get current state
  if (state is! TransactionLoaded) return;
  final currentState = state as TransactionLoaded;
  
  // Emit loading sub-state
  emit(currentState.copyWith(isAddingTransaction: true));
  
  try {
    // Call service
    await _transactionService.addTransaction(
      title: event.title,
      value: event.value,
      isExpense: event.isExpense,
    );
    
    // Reload data
    final transactions = await _transactionService.getAllTransactions();
    
    // Emit success state
    emit(TransactionOperationSuccess(
      message: event.isExpense 
          ? AppConstants.expenseAddedSuccess 
          : AppConstants.incomeAddedSuccess,
      transactions: transactions,
      operationType: TransactionOperationType.add,
    ));
    
    // Return to normal loaded state
    emit(TransactionLoaded(transactions: transactions));
    
  } catch (e) {
    // Handle errors
    final error = e is AppError ? e : ErrorHandler.handleException(e);
    emit(currentState.copyWith(isAddingTransaction: false));
    emit(TransactionError(
      error: error, 
      previousTransactions: currentState.transactions
    ));
  }
}
```

## 💡 Usage Examples

### In Widgets - BlocBuilder

```dart
BlocBuilder<TransactionBloc, TransactionState>(
  builder: (context, state) {
    if (state is TransactionLoading) {
      return const CircularProgressIndicator();
    }
    
    if (state is TransactionLoaded) {
      return TransactionList(
        transactions: state.displayTransactions,
        onDelete: (key) => context.read<TransactionBloc>()
            .add(DeleteTransaction(key: key)),
        onEdit: (transaction) => context.read<TransactionBloc>()
            .add(UpdateTransaction(transaction: transaction)),
      );
    }
    
    if (state is TransactionError) {
      return ErrorWidget(error: state.error);
    }
    
    return const SizedBox.shrink();
  },
)
```

### In Widgets - BlocListener

```dart
BlocListener<TransactionBloc, TransactionState>(
  listener: (context, state) {
    // Handle side effects
    if (state is TransactionOperationSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
    
    if (state is TransactionError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.error.message)),
      );
    }
  },
  child: YourWidget(),
)
```

### In Widgets - BlocConsumer

```dart
BlocConsumer<TransactionBloc, TransactionState>(
  listener: (context, state) {
    // Side effects (navigation, snackbars, etc.)
    if (state is TransactionOperationSuccess) {
      Navigator.of(context).pop();
    }
  },
  builder: (context, state) {
    // UI building logic
    return YourWidget(state);
  },
)
```

### Dispatching Events

```dart
// Simple event
context.read<TransactionBloc>().add(const LoadTransactions());

// Event with data
context.read<TransactionBloc>().add(AddTransaction(
  title: 'Groceries',
  value: 50.0,
  isExpense: true,
));

// Complex event
context.read<TransactionBloc>().add(FilterTransactionsByDateRange(
  startDate: DateTime(2024, 1, 1),
  endDate: DateTime(2024, 1, 31),
));
```

## 🧪 Testing

### BLoC Testing with bloc_test

```dart
group('TransactionBloc Tests', () {
  late TransactionBloc transactionBloc;
  late MockTransactionService mockTransactionService;
  
  setUp(() {
    mockTransactionService = MockTransactionService();
    transactionBloc = TransactionBloc(
      transactionService: mockTransactionService,
    );
  });
  
  tearDown(() {
    transactionBloc.close();
  });
  
  blocTest<TransactionBloc, TransactionState>(
    'emits [TransactionLoading, TransactionLoaded] when LoadTransactions succeeds',
    build: () {
      when(() => mockTransactionService.getAllTransactions())
          .thenAnswer((_) async => [mockTransaction]);
      return transactionBloc;
    },
    act: (bloc) => bloc.add(const LoadTransactions()),
    expect: () => [
      const TransactionLoading(),
      TransactionLoaded(transactions: [mockTransaction]),
    ],
  );
  
  blocTest<TransactionBloc, TransactionState>(
    'emits [TransactionLoading, TransactionError] when LoadTransactions fails',
    build: () {
      when(() => mockTransactionService.getAllTransactions())
          .thenThrow(Exception('Database error'));
      return transactionBloc;
    },
    act: (bloc) => bloc.add(const LoadTransactions()),
    expect: () => [
      const TransactionLoading(),
      isA<TransactionError>(),
    ],
  );
});
```

## 🎯 Best Practices

### Event Design
- **One Purpose** - Each event should have a single clear purpose
- **Immutable** - Always use `const` constructors and final fields
- **Validation** - Validate input data in events when possible
- **Naming** - Use verb-noun pattern (LoadTransactions, AddTransaction)

### State Design
- **Complete** - States should contain all data needed by UI
- **Immutable** - Never modify state objects directly
- **Granular** - Create specific states rather than generic ones
- **Preserve Context** - Keep important data across state transitions

### BLoC Implementation
- **Single Responsibility** - One BLoC per feature/domain
- **Service Layer** - Use services for business logic, BLoC for state management
- **Error Handling** - Always handle errors gracefully
- **Resource Management** - Close streams and dispose resources properly

### UI Integration
- **BlocBuilder** - For building UI based on state
- **BlocListener** - For side effects (navigation, dialogs, snackbars)
- **BlocConsumer** - When you need both building and listening
- **BlocProvider** - Provide BLoC to widget tree

### Testing
- **Unit Tests** - Test BLoC logic in isolation
- **Mock Dependencies** - Mock services and external dependencies
- **Test All Paths** - Test success, error, and edge cases
- **Golden Tests** - Test UI components with different states

## 🚫 Common Pitfalls

### ❌ Don't Do
```dart
// Don't emit states directly in UI
FloatingActionButton(
  onPressed: () {
    bloc.emit(TransactionLoading()); // ❌ Wrong
  }
)

// Don't store mutable objects in states
class TransactionLoaded extends TransactionState {
  final List<Transaction> transactions; // ❌ Mutable list
}

// Don't call async operations in states
class TransactionLoaded extends TransactionState {
  Future<double> get balance async { // ❌ Async getter
    return await calculateBalance();
  }
}
```

### ✅ Do Instead
```dart
// Emit events, not states
FloatingActionButton(
  onPressed: () {
    bloc.add(LoadTransactions()); // ✅ Correct
  }
)

// Use immutable collections
class TransactionLoaded extends TransactionState {
  final List<Transaction> transactions; // ✅ List.unmodifiable in getter
  
  List<Transaction> get immutableTransactions => 
      List.unmodifiable(transactions);
}

// Calculate in BLoC, store in state
class TransactionLoaded extends TransactionState {
  final double balance; // ✅ Pre-calculated
  
  const TransactionLoaded({
    required this.transactions,
    required this.balance,
  });
}
```

## 🔗 Related Documentation
- [Testing Guide](TESTING.md)
- [UI Components](UI_COMPONENTS.md)
- [Database Service](DATABASE.md)
- [Error Handling](ERROR_HANDLING.md)