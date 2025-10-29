# Services Documentation

**Business Logic Layer**

---

## Overview

Services implement business rules, validation, and coordinate between BLoC and Database layers.

## TradeService

**Location**: `lib/services/trade_service.dart`

### Purpose

- Validate trade data
- Implement business rules
- Transform data for UI
- Coordinate database operations
- Calculate financial metrics

### CRUD Operations

#### getAllTrades()

```dart
Future<List<Trade>> getAllTrades()
```

**Returns**: All trades from database  
**Throws**: AppError if database fails  
**Use**: Load initial data

```dart
final trades = await TradeService().getAllTrades();
```

#### addTrade()

```dart
Future<void> addTrade({
  required String title,
  required double value,
  required bool isExpense,
})
```

**Validates**:
- Title: 1-100 characters, not empty
- Value: > 0, <= 999,999,999.99

**Creates**: Trade with current timestamp

**Throws**: AppError with validation message

```dart
await TradeService().addTrade(
  title: 'Coffee',
  value: 5.50,
  isExpense: true,
);
```

#### updateTrade()

```dart
Future<void> updateTrade(Trade trade)
```

**Validates**:
- Trade has non-null key
- Title: 1-100 characters
- Value: > 0, <= 999,999,999.99

**Throws**: AppError if validation fails

```dart
trade.title = 'Updated';
await TradeService().updateTrade(trade);
```

#### deleteTrade()

```dart
Future<void> deleteTrade(int key)
```

**Validates**: Key >= 0

**Throws**: AppError if key invalid

```dart
await TradeService().deleteTrade(tradeKey);
```

#### clearAllTrades()

```dart
Future<void> clearAllTrades()
```

**Warning**: Deletes all trades permanently

```dart
await TradeService().clearAllTrades();
```

### Calculation Methods

#### calculateBalance()

```dart
double calculateBalance(List<Trade> trades)
```

**Pure function** - No side effects

**Logic**:
```
balance = Σ(incomes) - Σ(expenses)
```

**Returns**: Total balance (can be negative)

```dart
final balance = TradeService().calculateBalance(trades);
// Example: +200.00 (income) -150.00 (expenses) = 50.00
```

#### getBalanceImagePath()

```dart
String getBalanceImagePath(double balance)
```

**Pure function** - No side effects

**Returns**:
- `AppConstants.happyPigImage` if balance > 0
- `AppConstants.neutralPigImage` if balance == 0
- `AppConstants.sadPigImage` if balance < 0

```dart
final imagePath = TradeService().getBalanceImagePath(50.0);
// Returns: 'assets/images/porquinho_feliz.png'
```

#### getFinancialSummary()

```dart
Map<String, double> getFinancialSummary(List<Trade> trades)
```

**Returns**:
```dart
{
  'income': 1000.00,     // Total income
  'expenses': 750.00,    // Total expenses
  'balance': 250.00,     // Net balance
}
```

**Handles**: Invalid trades (negative values) are skipped

```dart
final summary = TradeService().getFinancialSummary(trades);
print('Income: ${summary['income']}');
print('Expenses: ${summary['expenses']}');
print('Balance: ${summary['balance']}');
```

### Filtering Methods

#### getTradesByType()

```dart
List<Trade> getTradesByType(
  List<Trade> trades, {
  required bool isExpense,
})
```

**Parameters**:
- `isExpense`: true for expenses, false for income

**Returns**: Filtered list

```dart
final expenses = TradeService().getTradesByType(
  trades,
  isExpense: true,
);
```

#### getRecentTrades()

```dart
List<Trade> getRecentTrades(
  List<Trade> trades, {
  int days = 30,
})
```

**Parameters**:
- `days`: Number of days to look back (default: 30)

**Validates**: days > 0

**Returns**: Trades from last N days

```dart
final recentTrades = TradeService().getRecentTrades(
  trades,
  days: 7,  // Last week
);
```

### Validation Logic

#### Input Validation

Performed in `_validateTradeInput()` (private method):

```dart
void _validateTradeInput(String title, double value) {
  final errors = <String>[];

  // Title validation
  if (title.trim().isEmpty) {
    errors.add('O título não pode estar vazio');
  }
  if (title.trim().length > 100) {
    errors.add('O título não pode ter mais que 100 caracteres');
  }

  // Value validation
  if (value <= 0) {
    errors.add('O valor deve ser maior que zero');
  }
  if (value > 999999999.99) {
    errors.add('O valor é muito alto');
  }

  if (errors.isNotEmpty) {
    throw AppError(
      message: errors.join('\n'),
      type: ErrorType.validation,
    );
  }
}
```

#### Validation Rules

**Title**:
- ✅ Min length: 1 character (after trim)
- ✅ Max length: 100 characters
- ❌ Cannot be empty or whitespace only

**Value**:
- ✅ Min value: 0.01
- ✅ Max value: 999,999,999.99
- ❌ Cannot be zero or negative
- ❌ Cannot exceed max limit

**Date**:
- Automatically set to `DateTime.now()`
- UI can restrict to past dates only

### Error Handling

All public methods use try-catch and convert exceptions:

```dart
try {
  // Database operation
  await _databaseService.addTrade(trade);
} catch (e) {
  // Convert to AppError
  throw ErrorHandler.handleException(e);
}
```

**Error Propagation**:
```
DatabaseService throws Exception
          ↓
TradeService catches
          ↓
ErrorHandler converts to AppError
          ↓
Throw AppError to BLoC
          ↓
BLoC emits TradeError state
```

## ErrorHandler

**Location**: `lib/services/error_handler.dart`

### Purpose

Centralized error management and user feedback.

### ErrorType Enum

```dart
enum ErrorType {
  validation,   // User input errors (orange)
  database,     // Storage errors (red)
  network,      // Connection errors (blue)
  unknown,      // Unexpected errors (grey)
}
```

### AppError Class

```dart
class AppError {
  final String message;      // User-facing message
  final String? details;     // Technical details (optional)
  final ErrorType type;      // Error category
  final String? code;        // Error code (optional)
}
```

**Example**:
```dart
AppError(
  message: 'O título não pode estar vazio',
  type: ErrorType.validation,
)

AppError(
  message: 'Erro no banco de dados',
  details: 'HiveError: Box not open',
  type: ErrorType.database,
)
```

### Static Methods

#### handleException()

```dart
static AppError handleException(dynamic exception)
```

**Converts** any exception to user-friendly AppError

**Detection Logic**:
- Already AppError → Return as-is
- Contains 'database', 'hive', 'box' → Database error
- Contains 'título', 'valor', 'vazio' → Validation error
- Contains 'network', 'connection' → Network error
- Otherwise → Unknown error

```dart
try {
  // Risky operation
} catch (e) {
  final error = ErrorHandler.handleException(e);
  // error is always AppError
}
```

#### showErrorSnackBar()

```dart
static void showErrorSnackBar(
  BuildContext context,
  AppError error, {
  Duration duration = AppConstants.snackBarDuration,
})
```

**Shows**: Floating snackbar with error

**Features**:
- Color-coded by error type
- Icon based on type
- "Details" button (except validation)
- Auto-dismiss after duration

```dart
ErrorHandler.showErrorSnackBar(
  context,
  AppError(
    message: 'Failed to save',
    type: ErrorType.database,
  ),
);
```

#### showSuccessSnackBar()

```dart
static void showSuccessSnackBar(
  BuildContext context,
  String message, {
  Duration duration = AppConstants.successSnackBarDuration,
})
```

**Shows**: Green snackbar with checkmark

```dart
ErrorHandler.showSuccessSnackBar(
  context,
  'Trade added successfully!',
);
```

#### showErrorDialog()

```dart
static Future<void> showErrorDialog(
  BuildContext context,
  AppError error, {
  VoidCallback? onRetry,
})
```

**Shows**: Modal dialog for critical errors

**Features**:
- Retry button (if callback provided)
- Expandable details section
- Cannot be dismissed (barrierDismissible: false)

```dart
await ErrorHandler.showErrorDialog(
  context,
  error,
  onRetry: () {
    context.read<TradeBloc>().add(const LoadTrades());
  },
);
```

### UI Feedback Strategy

**Validation Errors**:
- Orange snackbar
- No retry button
- Inline form errors

**Database Errors**:
- Red snackbar
- Details button
- Retry option when applicable

**Network Errors** (Future):
- Blue snackbar
- Retry button
- Offline mode indicator

**Unknown Errors**:
- Grey snackbar
- Details for debugging
- Generic user message

### Error Colors & Icons

```dart
ErrorType.validation → Colors.orange, Icons.warning
ErrorType.database   → Colors.red, Icons.storage
ErrorType.network    → Colors.blue, Icons.wifi_off
ErrorType.unknown    → Colors.grey, Icons.error
```

## Best Practices

### ✅ Do

- Validate all inputs in TradeService
- Use pure functions for calculations
- Catch and convert all exceptions
- Provide user-friendly messages
- Log errors with context
- Return safe defaults from pure functions
- Check context.mounted before showing UI

### ❌ Don't

- Put validation in database layer
- Silently catch exceptions
- Show technical errors to users
- Access database directly from services
- Mix UI code in services
- Throw generic Exceptions
- Forget to handle null cases

## Testing Services

### Unit Tests

```dart
group('TradeService', () {
  late TradeService service;
  late MockDatabaseService mockDb;

  setUp(() {
    mockDb = MockDatabaseService();
    service = TradeService(databaseService: mockDb);
  });

  test('calculateBalance returns correct sum', () {
    final trades = [
      Trade(value: 100, isExpense: false),
      Trade(value: 50, isExpense: true),
    ];
    
    expect(service.calculateBalance(trades), 50.0);
  });

  test('addTrade throws on empty title', () {
    expect(
      () => service.addTrade(
        title: '',
        value: 10,
        isExpense: true,
      ),
      throwsA(isA<AppError>()),
    );
  });

  test('addTrade throws on zero value', () {
    expect(
      () => service.addTrade(
        title: 'Test',
        value: 0,
        isExpense: true,
      ),
      throwsA(isA<AppError>().having(
        (e) => e.type,
        'type',
        ErrorType.validation,
      )),
    );
  });
});
```

### Mock Services

```dart
class MockTradeService extends Mock implements TradeService {}

// In tests
when(() => mockService.getAllTrades())
  .thenAnswer((_) async => [testTrade]);
```

---

**Next**: [UI_COMPONENTS.md](UI_COMPONENTS.md) - Widgets and screens