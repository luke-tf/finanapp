# Finanapp - Technical Specifications

**Version**: 1.0.0  
**Last Updated**: October 2024  
**Target Framework**: Flutter 3.8.1+  
**Target Dart**: 3.8.1+

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [State Management](#state-management)
3. [Data Layer](#data-layer)
4. [Business Logic Layer](#business-logic-layer)
5. [Presentation Layer](#presentation-layer)
6. [Error Handling Strategy](#error-handling-strategy)
7. [Code Conventions](#code-conventions)
8. [Development Workflow](#development-workflow)
9. [Testing Strategy](#testing-strategy)
10. [Troubleshooting](#troubleshooting)

---

## Architecture Overview

### Design Principles

Finanapp follows **Clean Architecture** with clear separation of concerns:

```
┌──────────────────────────────────────────────────────────────┐
│                     PRESENTATION LAYER                        │
│  ┌────────────┐  ┌────────────┐  ┌────────────────────────┐  │
│  │  Screens   │  │  Widgets   │  │    BLoC (UI State)     │  │
│  └────────────┘  └────────────┘  └────────────────────────┘  │
├──────────────────────────────────────────────────────────────┤
│                   BUSINESS LOGIC LAYER                        │
│  ┌────────────────────┐  ┌──────────────────────────────┐   │
│  │  TradeService      │  │  ErrorHandler                │   │
│  │  (Repository)      │  │  (Error Management)          │   │
│  └────────────────────┘  └──────────────────────────────┘   │
├──────────────────────────────────────────────────────────────┤
│                        DATA LAYER                             │
│  ┌────────────────────┐  ┌──────────────────────────────┐   │
│  │  DatabaseService   │  │  Trade Model                 │   │
│  │  (Hive)            │  │  (Data Entity)               │   │
│  └────────────────────┘  └──────────────────────────────┘   │
└──────────────────────────────────────────────────────────────┘
```

### Data Flow

```
User Action → Widget → TradeBloc → TradeService → DatabaseService → Hive
                         ↓
                    TradeState → Widget Update
```

### Key Architectural Decisions

1. **BLoC Pattern**: Chosen for predictable, testable state management
2. **Hive Database**: Selected for fast, offline-first, type-safe storage
3. **Single Responsibility**: Each class has one clear purpose
4. **Dependency Injection**: Services passed via constructors for testability
5. **Immutability**: State objects are immutable using `copyWith` pattern

---

## State Management

### BLoC Architecture

#### TradeBloc (`lib/blocs/trade/trade_bloc.dart`)

**Purpose**: Manages all trade-related state and business logic.

**Events**:
```dart
LoadTrades            // Initial load of all trades
RefreshTrades         // Pull-to-refresh
AddTrade              // Create new trade
UpdateTrade           // Modify existing trade
DeleteTrade           // Remove trade
ClearAllTrades        // Delete all trades
SearchTrades          // Search by title
FilterTradesByDateRange  // Filter by date
FilterTradesByType    // Filter expense/income
ClearFilters          // Reset all filters
```

**States**:
```dart
TradeInitial          // Initial state before loading
TradeLoading          // Loading data
TradeLoaded           // Data loaded successfully
TradeError            // Error occurred
TradeOperationSuccess // Operation completed successfully
```

**State Properties** (TradeLoaded):
```dart
List<Trade> trades              // All trades
List<Trade> filteredTrades      // Filtered subset
bool isAddingTrade             // Adding in progress
bool isDeletingTrade           // Deleting in progress
bool isUpdatingTrade           // Updating in progress
String? searchQuery            // Current search
DateTime? filterStartDate      // Date range start
DateTime? filterEndDate        // Date range end
bool? filterByType             // null=all, true=expense, false=income
```

**Key Methods**:
```dart
displayTrades          // Returns filtered or all trades
currentBalance         // Calculates total balance
totalIncome           // Sum of all income
totalExpenses         // Sum of all expenses
hasFilters            // Check if any filter is active
```

### Event Flow Examples

#### Adding a Trade
```
1. User fills form → taps Save
2. Widget dispatches: AddTrade(title, value, isExpense)
3. TradeBloc:
   - Validates input via TradeService
   - Calls DatabaseService.addTrade()
   - Emits TradeOperationSuccess with updated list
   - Emits TradeLoaded with new data
4. Widget rebuilds with updated list
5. Home screen shows success snackbar
```

#### Filtering Trades
```
1. User types in search box
2. Widget dispatches: SearchTrades(query)
3. TradeBloc:
   - Filters trades in memory (no DB call)
   - Emits TradeLoaded with filteredTrades updated
4. Widget rebuilds showing filtered results
```

---

## Data Layer

### Trade Model (`lib/models/trade.dart`)

```dart
@HiveType(typeId: 0)
class Trade extends HiveObject {
  @HiveField(0) late String title;
  @HiveField(1) late double value;
  @HiveField(2) late DateTime date;
  @HiveField(3) late bool isExpense;
  
  // Inherited from HiveObject:
  // int? key  // Unique identifier assigned by Hive
}
```

**Key Points**:
- Extends `HiveObject` for automatic key management
- `key` property is the unique identifier (auto-assigned)
- All fields are late-initialized for Hive compatibility
- Date defaults to `DateTime.now()` if not provided

### DatabaseService (`lib/services/database_service.dart`)

**Purpose**: Low-level Hive database operations.

**Initialization**:
```dart
await DatabaseService().initialize();
// - Initializes Hive
// - Registers TradeAdapter
// - Opens 'trades' box
```

**API**:
```dart
Future<List<Trade>> getAllTrades()
Future<void> addTrade(Trade trade)
Future<void> updateTrade(Trade trade)
Future<void> deleteTrade(int key)
Future<void> clearAllData()
```

**Design Decisions**:
- Singleton pattern for global access
- Platform-aware initialization (mobile vs web)
- Validates trades before storage (non-empty title, positive value)
- Comprehensive error logging

**Error Handling**:
- Throws exceptions with descriptive messages
- Validates key existence before operations
- Filters out corrupted trades on read

---

## Business Logic Layer

### TradeService (`lib/services/trade_service.dart`)

**Purpose**: Business logic and validation layer between BLoC and Database.

**Key Methods**:

```dart
// CRUD Operations
Future<List<Trade>> getAllTrades()
Future<void> addTrade({required String title, required double value, required bool isExpense})
Future<void> updateTrade(Trade trade)
Future<void> deleteTrade(int key)
Future<void> clearAllTrades()

// Calculations (Pure Functions)
double calculateBalance(List<Trade> trades)
String getBalanceImagePath(double balance)
Map<String, double> getFinancialSummary(List<Trade> trades)

// Filtering
List<Trade> getTradesByType(List<Trade> trades, {required bool isExpense})
List<Trade> getRecentTrades(List<Trade> trades, {int days = 30})
```

**Validation Rules**:
```dart
Title:
  - Cannot be empty
  - Max length: 100 characters
  
Value:
  - Must be > 0
  - Max value: 999,999,999.99
  
Date:
  - Cannot be in the future (enforced at UI level)
```

**Error Conversion**:
- Catches all exceptions from DatabaseService
- Converts to `AppError` with appropriate `ErrorType`
- Provides user-friendly messages

### ErrorHandler (`lib/services/error_handler.dart`)

**Purpose**: Centralized error management and user feedback.

**Error Types**:
```dart
enum ErrorType {
  validation,  // User input errors
  database,    // Hive/storage errors
  network,     // Future: sync errors
  unknown      // Unexpected errors
}
```

**AppError Structure**:
```dart
class AppError {
  final String message;      // User-facing message
  final String? details;     // Technical details
  final ErrorType type;      // Error category
  final String? code;        // Optional error code
}
```

**UI Feedback Methods**:
```dart
static void showErrorSnackBar(BuildContext context, AppError error)
static void showSuccessSnackBar(BuildContext context, String message)
static Future<void> showErrorDialog(BuildContext context, AppError error, {VoidCallback? onRetry})
```

**Error Colors & Icons**:
- Validation: Orange warning icon
- Database: Red storage icon
- Network: Blue wifi_off icon
- Unknown: Grey error icon

---

## Presentation Layer

### Screens

#### HomeScreen (`lib/screens/home_screen.dart`)

**Purpose**: Main application dashboard.

**Components**:
- AppBar with refresh button
- BalanceDisplay (piggy bank + balance card)
- TradeList or EmptyTradesWidget
- FloatingActionButton (add trade)

**State Handling**:
```dart
TradeLoading → LoadingWidget
TradeError → ErrorDisplayWidget with retry
TradeLoaded → BalanceDisplay + TradeList
Empty list → EmptyTradesWidget
```

**User Actions**:
- Tap FAB → Opens NewTradeForm modal
- Long-press trade → Opens EditTradeScreen
- Tap delete icon → Shows confirmation dialog
- Pull down → Refreshes trades

#### EditTradeScreen (`lib/screens/edit_trade_screen.dart`)

**Purpose**: Edit existing trade details.

**Features**:
- Pre-populated form with current values
- Real-time validation
- Disable form during save operation
- Visual feedback with loading indicator

**Workflow**:
```
1. Receive Trade object via constructor
2. User modifies fields
3. On save:
   - Validate form
   - Update Trade object properties
   - Dispatch UpdateTrade event
   - Listen for success/error
   - Pop screen on success
```

### Widget Catalog

#### Balance Widgets

**BalanceDisplay** (`lib/widgets/balance/balance_display.dart`)
- Combines BalanceImage + BalanceCard
- Props: `currentBalance`, `getBalanceImagePath()`

**BalanceImage** (`lib/widgets/balance/balance_image.dart`)
- Displays piggy bank based on balance
- Happy (>0), Neutral (=0), Sad (<0)
- Responsive height (20% of screen)

**BalanceCard** (`lib/widgets/balance/balance_card.dart`)
- Blue card showing formatted balance
- Currency symbol and 2 decimal places

#### Trade Widgets

**NewTradeForm** (`lib/widgets/trade/new_trade_form.dart`)
- Modal bottom sheet for adding trades
- Features:
  - Auto-focus on title field
  - Character counter (100 max)
  - Radio buttons for expense/income selection
  - Real-time validation
  - Clear/Cancel/Save buttons
  - Shows current balance hint

**TradeList** (`lib/widgets/trade/trade_list.dart`)
- ListView.builder displaying trades
- Uses ValueKey for performance
- Passes delete/edit callbacks

**TradeItem** (`lib/widgets/trade/trade_item.dart`)
- Individual trade card
- Features:
  - Colored indicators (red=expense, green=income)
  - Formatted date (dd/MM/yyyy)
  - Delete button with confirmation
  - Long-press to edit

**EmptyTradesWidget** (`lib/widgets/trade/empty_trades_widget.dart`)
- Shown when no trades exist
- Large icon + message
- "First Trade" button

#### Common Widgets

**LoadingWidget** (`lib/widgets/common/loading_widget.dart`)
- Centered CircularProgressIndicator
- Optional custom message

**ErrorDisplayWidget** (`lib/widgets/error/error_display_widget.dart`)
- Error icon colored by type
- Error message
- Retry button
- Optional details button

### Constants (`lib/utils/constants.dart`)

**Categories**:
```dart
App Info         // appName, version
Asset Paths      // Image paths
UI Text          // Labels, titles, messages
Button Labels    // All button text
Messages         // Success/error messages
Validation       // Error messages
Database         // DB-related messages
Dimensions       // Padding, sizes, radius
Text Sizes       // Font sizes
Durations        // Animation durations
Currency         // Symbols, prefixes
Date Formats     // Date format strings
```

**Responsive Helpers**:
```dart
getResponsivePadding(BuildContext context)
getResponsiveIconSize(BuildContext context)
getBalanceImageHeight(BuildContext context)
```

---

## Error Handling Strategy

### Error Flow

```
Exception → ErrorHandler.handleException() → AppError → UI Feedback
```

### Handling Patterns

#### In Services
```dart
try {
  await _databaseService.addTrade(trade);
} catch (e) {
  throw ErrorHandler.handleException(e);
}
```

#### In BLoC
```dart
try {
  await _tradeService.addTrade(...);
  emit(TradeOperationSuccess(...));
} catch (e) {
  final error = e is AppError ? e : ErrorHandler.handleException(e);
  emit(TradeError(error: error));
}
```

#### In UI
```dart
BlocListener<TradeBloc, TradeState>(
  listener: (context, state) {
    if (state is TradeOperationSuccess) {
      ErrorHandler.showSuccessSnackBar(context, state.message);
    } else if (state is TradeError) {
      ErrorHandler.showErrorSnackBar(context, state.error);
    }
  },
  child: ...
)
```

### Error Recovery

**Validation Errors**:
- Show inline form validation
- Orange snackbar with specific message
- No retry action

**Database Errors**:
- Red snackbar
- Details button for technical info
- Retry action when applicable
- Preserve previous state if possible

**Unknown Errors**:
- Generic message to user
- Full stack trace logged to console
- Contact support suggestion

---

## Code Conventions

### Naming Conventions

**Files**:
- `lowercase_with_underscores.dart`
- Screens: `*_screen.dart`
- Widgets: `*_widget.dart` or descriptive name
- Services: `*_service.dart`
- BLoC: `*_bloc.dart`, `*_event.dart`, `*_state.dart`

**Classes**:
- `PascalCase` for all classes
- Descriptive names: `TradeItem`, `BalanceDisplay`

**Variables & Functions**:
- `camelCase` for variables and functions
- Private members: `_leadingUnderscore`
- Constants: `camelCase` in class, `SCREAMING_SNAKE_CASE` for enums

**Widgets**:
- Always `const` constructors when possible
- `key` parameter first: `const MyWidget({super.key, ...})`

### Code Organization

**Import Order**:
```dart
// 1. Dart imports
import 'dart:async';

// 2. Flutter imports
import 'package:flutter/material.dart';

// 3. Package imports
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

// 4. Project imports (absolute paths)
import 'package:finanapp/models/trade.dart';
import 'package:finanapp/services/trade_service.dart';
```

**File Structure**:
```dart
// 1. Imports

// 2. Main class
class MyWidget extends StatelessWidget {
  // 3. Final fields
  final String title;
  
  // 4. Constructor
  const MyWidget({super.key, required this.title});
  
  // 5. Lifecycle methods
  @override
  void initState() { ... }
  
  // 6. Public methods
  void publicMethod() { ... }
  
  // 7. Private methods
  void _privateMethod() { ... }
  
  // 8. Build method (last)
  @override
  Widget build(BuildContext context) { ... }
}
```

### Best Practices

**State Management**:
- Use `BlocProvider.value` when passing existing BLoC to new routes
- Always check if widget is mounted before showing dialogs/snackbars
- Emit loading states before async operations
- Preserve previous state in error cases when possible

**Widgets**:
- Extract complex widgets into separate files
- Use `const` constructors to improve performance
- Prefer composition over inheritance
- Keep build methods small and readable

**Null Safety**:
- Use `late` only when guaranteed initialization
- Prefer `??` and `?.` over explicit null checks
- Use `required` for mandatory parameters
- Avoid `!` operator unless absolutely certain

**Error Handling**:
- Never silently catch exceptions
- Always log errors with context
- Provide user-friendly messages
- Include recovery actions when possible

---

## Development Workflow

### Adding a New Feature

1. **Create Feature Branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```

2. **Update Models** (if needed)
   ```dart
   // lib/models/trade.dart
   @HiveField(4) late String? category; // New field
   ```
   
   Regenerate:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

3. **Add BLoC Events/States** (if needed)
   ```dart
   // lib/blocs/trade/trade_event.dart
   class FilterByCategory extends TradeEvent { ... }
   
   // lib/blocs/trade/trade_bloc.dart
   on<FilterByCategory>(_onFilterByCategory);
   ```

4. **Update Services**
   ```dart
   // lib/services/trade_service.dart
   List<Trade> getTradesByCategory(List<Trade> trades, String category) { ... }
   ```

5. **Create/Update UI**
   ```dart
   // lib/widgets/trade/category_filter_widget.dart
   ```

6. **Test Manually**
   - Run on multiple screen sizes
   - Test error cases
   - Check state persistence

7. **Commit & Push**
   ```bash
   git add .
   git commit -m "feat: Add category filtering"
   git push origin feature/amazing-feature
   ```

### Modifying Existing Features

**Example: Adding a field to Trade**

1. Update `Trade` model with new `@HiveField`
2. Increment `typeId` if structure changed significantly
3. Run build_runner
4. Update `TradeService` validation
5. Update `NewTradeForm` and `EditTradeScreen`
6. Update `TradeItem` display
7. Test migration from old data

### Code Generation

**When to Run**:
- After modifying Hive models
- After adding/removing `@HiveField` annotations
- After changing `typeId`

**Commands**:
```bash
# Generate once
flutter pub run build_runner build

# Delete conflicting files
flutter pub run build_runner build --delete-conflicting-outputs

# Watch for changes (dev mode)
flutter pub run build_runner watch
```

---

## Testing Strategy

### Test Structure (To Be Implemented)

```
test/
├── unit/
│   ├── services/
│   │   ├── trade_service_test.dart
│   │   └── database_service_test.dart
│   └── models/
│       └── trade_test.dart
├── bloc/
│   └── trade_bloc_test.dart
├── widget/
│   ├── trade_item_test.dart
│   └── balance_display_test.dart
├── golden/
│   ├── home_screen_test.dart
│   └── trade_item_test.dart
└── helpers/
    └── test_data.dart
```

### Unit Tests

**Services**:
```dart
group('TradeService', () {
  test('calculateBalance returns correct sum', () {
    // Arrange
    final trades = [
      Trade(value: 100, isExpense: false),
      Trade(value: 50, isExpense: true),
    ];
    
    // Act
    final balance = service.calculateBalance(trades);
    
    // Assert
    expect(balance, 50.0);
  });
});
```

**Validation**:
```dart
test('addTrade throws on empty title', () {
  expect(
    () => service.addTrade(title: '', value: 10, isExpense: true),
    throwsA(isA<AppError>()),
  );
});
```

### BLoC Tests

```dart
blocTest<TradeBloc, TradeState>(
  'emits [TradeLoading, TradeLoaded] when LoadTrades succeeds',
  build: () => TradeBloc(tradeService: mockService),
  act: (bloc) => bloc.add(const LoadTrades()),
  expect: () => [
    isA<TradeLoading>(),
    isA<TradeLoaded>(),
  ],
);
```

### Widget Tests

```dart
testWidgets('TradeItem displays title and value', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: TradeItem(
        id: 1,
        title: 'Coffee',
        value: 5.50,
        date: DateTime.now(),
        isExpense: true,
        deleteTx: (_) {},
        editTx: (_) {},
      ),
    ),
  );
  
  expect(find.text('Coffee'), findsOneWidget);
  expect(find.text('- R\$ 5.50'), findsOneWidget);
});
```

### Golden Tests

```dart
testGoldens('TradeItem matches golden', (tester) async {
  await tester.pumpWidgetBuilder(
    TradeItem(...),
    surfaceSize: const Size(400, 100),
  );
  
  await screenMatchesGolden(tester, 'trade_item');
});
```

**Running Golden Tests**:
```bash
# Update goldens
flutter test --update-goldens

# Verify goldens
flutter test test/golden/
```

---

## Troubleshooting

### Common Issues

#### Hive Initialization Error
```
Error: MissingPluginException(No implementation found for method getApplicationDocumentsDirectory)
```

**Solution**: Ensure `WidgetsFlutterBinding.ensureInitialized()` is called before Hive init.

#### Build Runner Conflicts
```
Error: Conflicting outputs were detected...
```

**Solution**:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

#### State Not Updating
**Symptoms**: UI doesn't reflect BLoC state changes

**Checklist**:
1. Is `BlocBuilder` wrapping the widget?
2. Are you emitting new state instances (not mutating)?
3. Is `equatable` properly implemented in state classes?
4. Check BLoC listener for state type

#### Trades Not Persisting
**Symptoms**: Trades disappear on app restart

**Checklist**:
1. Is `DatabaseService().initialize()` called in main?
2. Is `build_runner` generated code up to date?
3. Check Hive box name matches ("trades")
4. Verify `Trade` extends `HiveObject`

#### Form Validation Not Working
**Symptoms**: Can submit invalid data

**Checklist**:
1. Is `_formKey.currentState!.validate()` called?
2. Are validator functions returning `String?`
3. Is form wrapped in `Form` widget?
4. Check validator logic for edge cases

### Debugging Tips

**Enable BLoC Observer**:
```dart
// main.dart
void main() {
  Bloc.observer = SimpleBlocObserver();
  runApp(MyApp());
}

class SimpleBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    print('${bloc.runtimeType} $change');
  }
}
```

**Hive Box Inspection**:
```dart
final box = Hive.box<Trade>('trades');
print('Total trades: ${box.length}');
print('All keys: ${box.keys}');
```

**State Logging**:
```dart
BlocBuilder<TradeBloc, TradeState>(
  builder: (context, state) {
    print('Current state: $state');
    return ...;
  },
)
```

### Performance Issues

**Large Trade Lists**:
- Implement pagination if >1000 trades
- Use `ListView.builder` (already implemented)
- Consider indexing in Hive

**Slow Filtering**:
- Cache filtered results
- Debounce search input
- Use lazy evaluation

**Build Method Too Heavy**:
- Extract widgets into separate classes
- Use `const` constructors
- Profile with Flutter DevTools

---

## Appendix

### Dependencies

```yaml
dependencies:
  flutter_bloc: ^8.1.6      # State management
  equatable: ^2.0.5         # Value equality
  hive: ^2.2.3              # NoSQL database
  hive_flutter: ^1.1.0      # Hive Flutter integration
  path_provider: ^2.1.3     # File system paths
  intl: ^0.20.2             # Internationalization
  animated_list_plus: ^0.5.2 # List animations

dev_dependencies:
  hive_generator: ^2.0.1    # Code generation
  build_runner: ^2.4.6      # Build tool
  bloc_test: ^9.1.6         # BLoC testing utilities
  mocktail: ^1.0.0          # Mocking library
  golden_toolkit: ^0.15.0   # Golden file testing
```

### Useful Commands

```bash
# Clean build
flutter clean && flutter pub get

# Run with verbose logging
flutter run -v

# Build APK
flutter build apk --release

# Analyze code
flutter analyze

# Format code
dart format .

# Check outdated packages
flutter pub outdated
```

### Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [BLoC Library](https://bloclibrary.dev)
- [Hive Documentation](https://docs.hivedb.dev)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)
- [Flutter Best Practices](https://flutter.dev/docs/perf/best-practices)

---

**Document Version**: 1.0  
**Maintained By**: Development Team  
**Last Review**: October 2024