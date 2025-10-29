# State Management Documentation

**BLoC Pattern Implementation**

---

## Overview

Finanapp uses the **BLoC (Business Logic Component)** pattern for state management, providing predictable, testable, and reactive state handling.

## TradeBloc

**Location**: `lib/blocs/trade/trade_bloc.dart`

**Purpose**: Manages all trade-related state and coordinates business logic.

## Events

All events extend `TradeEvent` and use Equatable for value comparison.

### CRUD Events

```dart
// Initial load
LoadTrades()

// Pull-to-refresh
RefreshTrades()

// Create
AddTrade({
  required String title,
  required double value,
  required bool isExpense,
})

// Update
UpdateTrade({
  required Trade trade,
})

// Delete
DeleteTrade({
  required int key,
})

// Clear all
ClearAllTrades()
```

### Filter Events

```dart
// Search by title
SearchTrades({
  required String query,
})

// Filter by date range
FilterTradesByDateRange({
  required DateTime startDate,
  required DateTime endDate,
})

// Filter by type
FilterTradesByType({
  required bool? isExpense,  // null=all, true=expense, false=income
})

// Clear all filters
ClearFilters()
```

## States

All states extend `TradeState` and use Equatable.

### State Types

```dart
// Initial state before any data
TradeInitial()

// Loading data
TradeLoading()

// Data loaded successfully
TradeLoaded({
  required List<Trade> trades,
  List<Trade> filteredTrades = const [],
  bool isAddingTrade = false,
  bool isDeletingTrade = false,
  bool isUpdatingTrade = false,
  String? searchQuery,
  DateTime? filterStartDate,
  DateTime? filterEndDate,
  bool? filterByType,
})

// Error occurred
TradeError({
  required AppError error,
  List<Trade> previousTrades = const [],
})

// Operation completed successfully
TradeOperationSuccess({
  required String message,
  required List<Trade> trades,
  required TradeOperationType operationType,
})
```

### TradeLoaded Properties

**Core Data**:
- `trades`: All trades from database
- `filteredTrades`: Subset based on active filters

**Operation Flags**:
- `isAddingTrade`: True during add operation
- `isDeletingTrade`: True during delete operation
- `isUpdatingTrade`: True during update operation

**Filter State**:
- `searchQuery`: Current search text
- `filterStartDate`: Start of date range
- `filterEndDate`: End of date range
- `filterByType`: null=all, true=expenses, false=income

**Computed Properties**:
```dart
List<Trade> displayTrades        // Returns filtered or all trades
bool hasTransactions             // Has any trades
bool hasFilters                  // Has active filters
double currentBalance            // Sum of all trades
double totalIncome              // Sum of income trades
double totalExpenses            // Sum of expense trades
List<Trade> recentTransactions  // Last 30 days
```

## Event Flows

### Adding a Trade

```
┌─────────────────────────────────────────────────────────────┐
│ 1. User fills form → taps Save                              │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 2. Widget dispatches:                                        │
│    context.read<TradeBloc>().add(                           │
│      AddTrade(title: '...', value: 100, isExpense: true)   │
│    )                                                         │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 3. TradeBloc._onAddTrade()                                  │
│    - Emits loading flag: isAddingTrade = true               │
│    - Calls TradeService.addTrade()                          │
│      - Validates input                                       │
│      - Calls DatabaseService.addTrade()                     │
│    - Reloads all trades                                      │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 4. BLoC emits states:                                        │
│    a) TradeOperationSuccess (message + updated trades)      │
│    b) TradeLoaded (new stable state)                        │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 5. Widget rebuilds                                           │
│    - BlocListener shows success snackbar                    │
│    - List updates with new trade                            │
│    - Modal closes automatically                             │
└─────────────────────────────────────────────────────────────┘
```

### Filtering Trades

```
┌─────────────────────────────────────────────────────────────┐
│ 1. User types in search box                                  │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 2. Widget dispatches:                                        │
│    SearchTrades(query: 'coffee')                            │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 3. TradeBloc._onSearchTrades()                              │
│    - Filters trades in memory (NO database call)            │
│    - Uses _applyFilters() helper                            │
│    - Combines with existing filters (date, type)            │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 4. BLoC emits TradeLoaded with:                             │
│    - Same trades list                                        │
│    - Updated filteredTrades                                  │
│    - searchQuery = 'coffee'                                  │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 5. Widget rebuilds showing filtered results                  │
│    - displayTrades returns filteredTrades                   │
│    - Balance recalculates from filtered trades              │
└─────────────────────────────────────────────────────────────┘
```

### Error Handling

```
┌─────────────────────────────────────────────────────────────┐
│ Operation fails (validation, database, etc.)                 │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ Service throws AppError or generic exception                 │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ BLoC catches and converts:                                   │
│ final error = e is AppError ? e : ErrorHandler.handle(e);   │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ BLoC emits TradeError state with:                           │
│ - AppError with user message                                 │
│ - previousTrades (to restore UI if possible)                │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ Widget shows error:                                          │
│ - BlocListener shows error snackbar                         │
│ - ErrorDisplayWidget if critical                            │
│ - Reset loading flags                                        │
└─────────────────────────────────────────────────────────────┘
```

## State Transitions

### Valid Transitions

```
TradeInitial → TradeLoading → TradeLoaded
                            → TradeError

TradeLoaded → TradeLoading (refresh)
           → TradeOperationSuccess → TradeLoaded
           → TradeError
           → TradeLoaded (filters, no loading)

TradeError → TradeLoading (retry)
          → TradeLoaded (if previousTrades exist)
```

### Invalid Transitions

❌ TradeInitial → TradeOperationSuccess  
❌ TradeError → TradeOperationSuccess  
❌ TradeLoading → TradeLoading

## BLoC in Widgets

### BlocProvider Setup

```dart
// In main.dart
BlocProvider(
  create: (context) => TradeBloc()..add(const LoadTrades()),
  child: MaterialApp(
    home: HomeScreen(),
  ),
)
```

### BlocBuilder (Display State)

```dart
BlocBuilder<TradeBloc, TradeState>(
  builder: (context, state) {
    if (state is TradeLoading) {
      return LoadingWidget();
    }
    if (state is TradeError) {
      return ErrorDisplayWidget(error: state.error);
    }
    if (state is TradeLoaded) {
      return TradeList(trades: state.displayTrades);
    }
    return Container();
  },
)
```

### BlocListener (Side Effects)

```dart
BlocListener<TradeBloc, TradeState>(
  listener: (context, state) {
    if (state is TradeOperationSuccess) {
      ErrorHandler.showSuccessSnackBar(context, state.message);
    }
    if (state is TradeError) {
      ErrorHandler.showErrorSnackBar(context, state.error);
    }
  },
  child: YourWidget(),
)
```

### BlocConsumer (Both)

```dart
BlocConsumer<TradeBloc, TradeState>(
  listener: (context, state) {
    // Handle side effects
  },
  builder: (context, state) {
    // Build UI
  },
)
```

### Dispatching Events

```dart
// Access BLoC
context.read<TradeBloc>().add(const LoadTrades());

// Add trade
context.read<TradeBloc>().add(
  AddTrade(
    title: 'Coffee',
    value: 5.50,
    isExpense: true,
  ),
);

// Delete trade
context.read<TradeBloc>().add(DeleteTrade(key: tradeKey));
```

### Passing BLoC to Routes

```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (ctx) => BlocProvider.value(
      value: context.read<TradeBloc>(),
      child: EditTradeScreen(trade: trade),
    ),
  ),
);
```

## Best Practices

### ✅ Do

- Emit new state instances (never mutate)
- Use `copyWith()` for state updates
- Handle all possible states in UI
- Check `context.mounted` before async operations
- Use `BlocProvider.value` when passing existing BLoC
- Log state changes in development

### ❌ Don't

- Mutate state objects directly
- Access BLoC after widget disposal
- Emit same state instance twice
- Mix business logic in widgets
- Use BLoC for local widget state
- Forget to handle loading/error states

## Testing BLoC

### Using bloc_test

```dart
blocTest<TradeBloc, TradeState>(
  'emits [TradeLoading, TradeLoaded] when LoadTrades succeeds',
  build: () {
    when(() => mockService.getAllTrades())
        .thenAnswer((_) async => [mockTrade]);
    return TradeBloc(tradeService: mockService);
  },
  act: (bloc) => bloc.add(const LoadTrades()),
  expect: () => [
    isA<TradeLoading>(),
    isA<TradeLoaded>().having(
      (s) => s.trades,
      'trades',
      [mockTrade],
    ),
  ],
);
```

### Testing Error Cases

```dart
blocTest<TradeBloc, TradeState>(
  'emits TradeError when service throws',
  build: () {
    when(() => mockService.getAllTrades())
        .thenThrow(Exception('DB Error'));
    return TradeBloc(tradeService: mockService);
  },
  act: (bloc) => bloc.add(const LoadTrades()),
  expect: () => [
    isA<TradeLoading>(),
    isA<TradeError>(),
  ],
);
```

## Performance Tips

### Avoid Unnecessary Rebuilds

```dart
// Use equatable in states
class TradeLoaded extends TradeState {
  @override
  List<Object?> get props => [trades, filteredTrades, ...];
}
```

### Selective Rebuilds

```dart
// Only rebuild specific widgets
BlocBuilder<TradeBloc, TradeState>(
  buildWhen: (previous, current) {
    // Only rebuild if trades changed
    return previous is! TradeLoaded || 
           current is! TradeLoaded ||
           previous.trades != current.trades;
  },
  builder: (context, state) { ... },
)
```

### Debounce Search

```dart
// In BLoC constructor
on<SearchTrades>(
  _onSearchTrades,
  transformer: debounceTime(const Duration(milliseconds: 300)),
);
```

---

**Next**: [DATA_LAYER.md](DATA_LAYER.md) - Models and database