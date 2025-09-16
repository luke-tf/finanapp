# 🧪 Testing Guide

This document covers all testing strategies and practices used in Finanapp.

## 📖 Table of Contents
- [Overview](#overview)
- [Golden Tests](#golden-tests)
- [BLoC Testing](#bloc-testing)
- [Widget Testing](#widget-testing)
- [Unit Testing](#unit-testing)
- [Test Structure](#test-structure)
- [Running Tests](#running-tests)
- [Best Practices](#best-practices)

## 🎯 Overview

Finanapp uses a comprehensive testing strategy with multiple types of tests:

- **Golden Tests** - Visual regression testing for UI components
- **BLoC Tests** - Business logic and state management testing
- **Widget Tests** - Individual widget behavior testing
- **Unit Tests** - Pure function and service testing

### Testing Pyramid
```
    Unit Tests        ← Fastest, Most Isolated
       ↑
   Widget Tests       ← Medium Speed, Component Level  
       ↑
  Integration Tests   ← Slower, Full App Testing
       ↑
   Golden Tests       ← Visual Regression, UI Testing
```

## 🖼️ Golden Tests

Golden tests capture screenshots of widgets and compare them against reference images to catch visual regressions.

### Setup

```dart
// test/flutter_test_config.dart
import 'dart:async';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  return testMain();
}
```

### Basic Golden Test Structure

```dart
// test/golden/balance_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:finanapp/widgets/balance/balance_card.dart';

void main() {
  group('BalanceCard Golden Tests', () {
    testGoldens('BalanceCard with positive balance', (tester) async {
      final widget = MaterialApp(
        home: Scaffold(
          body: Center(
            child: BalanceCard(balance: 1500.75),
          ),
        ),
      );

      await tester.pumpWidgetBuilder(
        widget,
        surfaceSize: const Size(400, 300),
      );

      await screenMatchesGolden(tester, 'balance_card_positive');
    });
  });
}
```

### Running Golden Tests

```bash
# Create/update golden files (first time or after UI changes)
flutter test test/golden/ --update-goldens

# Run golden tests (compare against existing goldens)
flutter test test/golden/

# Run specific golden test
flutter test test/golden/balance_card_test.dart

# Run with verbose output
flutter test test/golden/ --reporter=expanded
```

### Golden Test Categories

#### 1. Widget-Level Tests
Test individual components in isolation:

```dart
// Testing different states of a widget
testGoldens('BalanceCard states', (tester) async {
  final scenarios = [
    ('positive', 1500.50),
    ('negative', -250.75),
    ('zero', 0.0),
    ('large', 999999.99),
  ];
  
  for (final (name, balance) in scenarios) {
    await tester.pumpWidgetBuilder(
      MaterialApp(
        home: Scaffold(
          body: BalanceCard(balance: balance),
        ),
      ),
      surfaceSize: const Size(400, 200),
    );
    
    await screenMatchesGolden(tester, 'balance_card_$name');
  }
});
```

#### 2. Screen-Level Tests
Test complete screens with different states:

```dart
// Testing home screen with mock data
testGoldens('HomeScreen with transactions', (tester) async {
  final mockBloc = MockTransactionBloc();
  when(() => mockBloc.state).thenReturn(
    TransactionLoaded(transactions: testTransactions),
  );
  
  await tester.pumpWidgetBuilder(
    BlocProvider<TransactionBloc>.value(
      value: mockBloc,
      child: const MyHomePage(),
    ),
    surfaceSize: const Size(400, 800),
  );
  
  await screenMatchesGolden(tester, 'home_screen_with_data');
});
```

#### 3. Responsive Tests
Test different screen sizes:

```dart
testGoldens('TransactionItem responsive', (tester) async {
  final sizes = [
    (Size(320, 568), 'phone_small'),  // iPhone SE
    (Size(375, 667), 'phone_medium'), // iPhone 8
    (Size(414, 896), 'phone_large'),  // iPhone 11 Pro Max
    (Size(768, 1024), 'tablet'),      // iPad
  ];
  
  for (final (size, name) in sizes) {
    await tester.pumpWidgetBuilder(
      MaterialApp(
        home: Scaffold(
          body: TransactionItem(/* ... */),
        ),
      ),
      surfaceSize: size,
    );
    
    await screenMatchesGolden(tester, 'transaction_item_$name');
  }
});
```

### Golden Test Best Practices

#### ✅ Do
- **Fixed Data** - Use consistent, predictable test data
- **Fixed Dates** - Use `DateTime(2024, 1, 15)` instead of `DateTime.now()`
- **Multiple States** - Test all possible UI states
- **Descriptive Names** - Clear golden file names
- **Size Consistency** - Use consistent surface sizes

#### ❌ Don't
- **Dynamic Content** - Avoid timestamps, random data
- **External Dependencies** - Mock all external services
- **Platform-Specific** - Tests should work on all platforms
- **Too Large** - Keep surface sizes reasonable
- **Nested Describes** - Keep test structure flat

### Golden Test File Organization

```
test/golden/
├── goldens/                    # Reference images
│   ├── balance_card_positive.png
│   ├── transaction_item_expense.png
│   └── home_screen_empty.png
├── failures/                   # Failed test images (auto-generated)
│   └── balance_card_positive_masterImage.png
├── widgets/                    # Widget-level tests
│   ├── balance_card_test.dart
│   └── transaction_item_test.dart
└── screens/                    # Screen-level tests
    └── home_screen_test.dart
```

## 🏛️ BLoC Testing

Test business logic and state management using `bloc_test`.

### Setup

```dart
// test/blocs/transaction_bloc_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:finanapp/blocs/transaction/transaction_barrel.dart';
import 'package:finanapp/services/transaction_service.dart';

class MockTransactionService extends Mock implements TransactionService {}

void main() {
  group('TransactionBloc', () {
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
    
    // Tests go here...
  });
}
```

### Basic BLoC Test Structure

```dart
blocTest<TransactionBloc, TransactionState>(
  'emits [Loading, Loaded] when LoadTransactions succeeds',
  build: () {
    when(() => mockTransactionService.getAllTransactions())
        .thenAnswer((_) async => mockTransactions);
    return transactionBloc;
  },
  act: (bloc) => bloc.add(const LoadTransactions()),
  expect: () => [
    const TransactionLoading(),
    TransactionLoaded(transactions: mockTransactions),
  ],
);
```

### Testing Different Scenarios

#### Success Scenarios
```dart
group('LoadTransactions', () {
  blocTest<TransactionBloc, TransactionState>(
    'loads transactions successfully',
    build: () {
      when(() => mockTransactionService.getAllTransactions())
          .thenAnswer((_) async => mockTransactions);
      return transactionBloc;
    },
    act: (bloc) => bloc.add(const LoadTransactions()),
    expect: () => [
      const TransactionLoading(),
      TransactionLoaded(transactions: mockTransactions),
    ],
  );
  
  blocTest<TransactionBloc, TransactionState>(
    'loads empty transactions successfully',
    build: () {
      when(() => mockTransactionService.getAllTransactions())
          .thenAnswer((_) async => []);
      return transactionBloc;
    },
    act: (bloc) => bloc.add(const LoadTransactions()),
    expect: () => [
      const TransactionLoading(),
      const TransactionLoaded(transactions: []),
    ],
  );
});
```

#### Error Scenarios
```dart
group('LoadTransactions Errors', () {
  blocTest<TransactionBloc, TransactionState>(
    'emits TransactionError when service throws exception',
    build: () {
      when(() => mockTransactionService.getAllTransactions())
          .thenThrow(Exception('Database error'));
      return transactionBloc;
    },
    act: (bloc) => bloc.add(const LoadTransactions()),
    expect: () => [
      const TransactionLoading(),
      isA<TransactionError>()
          .having((state) => state.error.message, 'message', contains('error')),
    ],
  );
  
  blocTest<TransactionBloc, TransactionState>(
    'preserves previous transactions on error',
    build: () {
      when(() => mockTransactionService.getAllTransactions())
          .thenThrow(Exception('Network error'));
      return transactionBloc;
    },
    seed: () => TransactionLoaded(transactions: mockTransactions),
    act: (bloc) => bloc.add(const RefreshTransactions()),
    expect: () => [
      isA<TransactionError>()
          .having((state) => state.previousTransactions, 'previousTransactions', 
                 equals(mockTransactions)),
    ],
  );
});
```

#### Complex Scenarios
```dart
group('AddTransaction', () {
  blocTest<TransactionBloc, TransactionState>(
    'adds transaction and shows success message',
    build: () {
      when(() => mockTransactionService.addTransaction(
            title: any(named: 'title'),
            value: any(named: 'value'),
            isExpense: any(named: 'isExpense'),
          )).thenAnswer((_) async {});
      when(() => mockTransactionService.getAllTransactions())
          .thenAnswer((_) async => updatedMockTransactions);
      return transactionBloc;
    },
    seed: () => TransactionLoaded(transactions: mockTransactions),
    act: (bloc) => bloc.add(const AddTransaction(
      title: 'Test Transaction',
      value: 100.0,
      isExpense: true,
    )),
    expect: () => [
      // First: Set adding state
      TransactionLoaded(
        transactions: mockTransactions,
        isAddingTransaction: true,
      ),
      // Then: Show success
      TransactionOperationSuccess(
        message: AppConstants.expenseAddedSuccess,
        transactions: updatedMockTransactions,
        operationType: TransactionOperationType.add,
      ),
      // Finally: Return to loaded state
      TransactionLoaded(transactions: updatedMockTransactions),
    ],
    verify: (_) {
      verify(() => mockTransactionService.addTransaction(
        title: 'Test Transaction',
        value: 100.0,
        isExpense: true,
      )).called(1);
    },
  );
});
```

### Testing State Properties
```dart
group('TransactionLoaded State', () {
  test('currentBalance calculates correctly', () {
    final transactions = [
      Transaction(title: 'Income', value: 1000, isExpense: false),
      Transaction(title: 'Expense', value: 300, isExpense: true),
    ];
    
    final state = TransactionLoaded(transactions: transactions);
    
    expect(state.currentBalance, equals(700.0));
  });
  
  test('displayTransactions returns filtered when filters active', () {
    final allTransactions = [
      Transaction(title: 'Income', value: 1000, isExpense: false),
      Transaction(title: 'Expense', value: 300, isExpense: true),
    ];
    
    final filteredTransactions = [allTransactions.first];
    
    final state = TransactionLoaded(
      transactions: allTransactions,
      filteredTransactions: filteredTransactions,
      searchQuery: 'Income',
    );
    
    expect(state.displayTransactions, equals(filteredTransactions));
    expect(state.hasFilters, isTrue);
  });
});
```

## 🧩 Widget Testing

Test individual widget behavior and interactions.

### Basic Widget Test
```dart
// test/widgets/balance_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finanapp/widgets/balance/balance_card.dart';

void main() {
  group('BalanceCard Widget Tests', () {
    testWidgets('displays positive balance correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BalanceCard(balance: 1500.75),
          ),
        ),
      );
      
      expect(find.text('Saldo Atual'), findsOneWidget);
      expect(find.text('R\$ 1500.75'), findsOneWidget);
    });
    
    testWidgets('displays negative balance correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BalanceCard(balance: -250.50),
          ),
        ),
      );
      
      expect(find.text('R\$ -250.50'), findsOneWidget);
    });
  });
}
```

### Testing User Interactions
```dart
group('TransactionItem Interactions', () {
  testWidgets('calls delete callback when delete button pressed', (tester) async {
    bool deleteWasCalled = false;
    int deletedId = -1;
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TransactionItem(
            id: 1,
            title: 'Test Transaction',
            value: 100.0,
            date: DateTime(2024, 1, 15),
            isExpense: true,
            deleteTx: (id) {
              deleteWasCalled = true;
              deletedId = id;
            },
            editTx: (id) {},
          ),
        ),
      ),
    );
    
    // Find and tap delete button
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    
    // Find and tap confirm in dialog
    await tester.tap(find.text('Excluir'));
    await tester.pumpAndSettle();
    
    expect(deleteWasCalled, isTrue);
    expect(deletedId, equals(1));
  });
  
  testWidgets('calls edit callback on long press', (tester) async {
    bool editWasCalled = false;
    int editedId = -1;
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TransactionItem(
            id: 2,
            title: 'Test Transaction',
            value: 100.0,
            date: DateTime(2024, 1, 15),
            isExpense: true,
            deleteTx: (id) {},
            editTx: (id) {
              editWasCalled = true;
              editedId = id;
            },
          ),
        ),
      ),
    );
    
    // Long press on the list tile
    await tester.longPress(find.byType(ListTile));
    await tester.pumpAndSettle();
    
    expect(editWasCalled, isTrue);
    expect(editedId, equals(2));
  });
});
```

### Testing Form Widgets
```dart
group('NewTransactionForm Widget Tests', () {
  testWidgets('validates required fields', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider(
            create: (_) => TransactionBloc(),
            child: const NewTransactionForm(),
          ),
        ),
      ),
    );
    
    // Try to submit empty form
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    
    // Should show validation errors
    expect(find.text('Por favor, insira um título'), findsOneWidget);
    expect(find.text('Por favor, insira um valor'), findsOneWidget);
  });
  
  testWidgets('submits valid transaction', (tester) async {
    final mockBloc = MockTransactionBloc();
    when(() => mockBloc.state).thenReturn(
      const TransactionLoaded(transactions: []),
    );
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<TransactionBloc>.value(
            value: mockBloc,
            child: const NewTransactionForm(),
          ),
        ),
      ),
    );
    
    // Fill form
    await tester.enterText(find.byType(TextFormField).first, 'Test Transaction');
    await tester.enterText(find.byType(TextFormField).last, '100.50');
    
    // Submit form
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    
    // Verify event was dispatched
    verify(() => mockBloc.add(const AddTransaction(
      title: 'Test Transaction',
      value: 100.50,
      isExpense: true,
    ))).called(1);
  });
});
```

## 🔧 Unit Testing

Test pure functions, services, and utilities in isolation.

### Service Testing
```dart
// test/services/transaction_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:finanapp/services/transaction_service.dart';
import 'package:finanapp/services/database_service.dart';

class MockDatabaseService extends Mock implements DatabaseService {}

void main() {
  group('TransactionService', () {
    late TransactionService transactionService;
    late MockDatabaseService mockDatabaseService;
    
    setUp(() {
      mockDatabaseService = MockDatabaseService();
      transactionService = TransactionService(
        databaseService: mockDatabaseService,
      );
    });
    
    group('calculateBalance', () {
      test('calculates positive balance correctly', () {
        final transactions = [
          Transaction(title: 'Income', value: 1000, isExpense: false),
          Transaction(title: 'Expense', value: 300, isExpense: true),
        ];
        
        final balance = transactionService.calculateBalance(transactions);
        
        expect(balance, equals(700.0));
      });
      
      test('handles empty transaction list', () {
        final balance = transactionService.calculateBalance([]);
        
        expect(balance, equals(0.0));
      });
      
      test('calculates negative balance correctly', () {
        final transactions = [
          Transaction(title: 'Income', value: 500, isExpense: false),
          Transaction(title: 'Expense', value: 800, isExpense: true),
        ];
        
        final balance = transactionService.calculateBalance(transactions);
        
        expect(balance, equals(-300.0));
      });
    });
    
    group('getBalanceImagePath', () {
      test('returns happy pig for positive balance', () {
        final imagePath = transactionService.getBalanceImagePath(100.0);
        
        expect(imagePath, equals(AppConstants.happyPigImage));
      });
      
      test('returns sad pig for negative balance', () {
        final imagePath = transactionService.getBalanceImagePath(-50.0);
        
        expect(imagePath, equals(AppConstants.sadPigImage));
      });
      
      test('returns neutral pig for zero balance', () {
        final imagePath = transactionService.getBalanceImagePath(0.0);
        
        expect(imagePath, equals(AppConstants.neutralPigImage));
      });
    });
  });
}
```

### Model Testing
```dart
// test/models/transaction_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:finanapp/models/transaction.dart';

void main() {
  group('Transaction Model', () {
    test('creates transaction with default values', () {
      final transaction = Transaction();
      
      expect(transaction.title, equals(''));
      expect(transaction.value, equals(0.0));
      expect(transaction.isExpense, equals(true));
      expect(transaction.date, isA<DateTime>());
    });
    
    test('creates transaction with provided values', () {
      final date = DateTime(2024, 1, 15);
      final transaction = Transaction(
        title: 'Test Transaction',
        value: 100.50,
        date: date,
        isExpense: false,
      );
      
      expect(transaction.title, equals('Test Transaction'));
      expect(transaction.value, equals(100.50));
      expect(transaction.date, equals(date));
      expect(transaction.isExpense, equals(false));
    });
    
    test('toString returns correct format', () {
      final transaction = Transaction(
        title: 'Test',
        value: 50.0,
        date: DateTime(2024, 1, 15),
        isExpense: true,
      );
      
      final string = transaction.toString();
      
      expect(string, contains('Test'));
      expect(string, contains('50.0'));
      expect(string, contains('true'));
    });
  });
}
```

## 📁 Test Structure

### Recommended File Organization
```
test/
├── blocs/                      # BLoC tests
│   ├── transaction/
│   │   ├── transaction_bloc_test.dart
│   │   ├── transaction_event_test.dart
│   │   └── transaction_state_test.dart
│   └── ...
├── golden/                     # Golden tests
│   ├── goldens/               # Reference images
│   ├── failures/              # Failed test images
│   ├── widgets/               # Widget golden tests
│   └── screens/               # Screen golden tests
├── helpers/                   # Test utilities
│   ├── golden_test_helper.dart
│   ├── mock_data.dart
│   └── test_utils.dart
├── models/                    # Model tests
│   └── transaction_test.dart
├── services/                  # Service tests
│   ├── database_service_test.dart
│   ├── transaction_service_test.dart
│   └── error_handler_test.dart
├── widgets/                   # Widget tests
│   ├── balance/
│   │   ├── balance_card_test.dart
│   │   └── balance_display_test.dart
│   └── transaction/
│       ├── transaction_item_test.dart
│       └── new_transaction_form_test.dart
└── flutter_test_config.dart  # Global test configuration
```

### Test Naming Conventions
- **Files**: `widget_name_test.dart`
- **Groups**: `'WidgetName Tests'` or `'ServiceName Tests'`
- **Tests**: `'should do something when condition'`
- **Golden Files**: `widget_name_state` (e.g., `balance_card_positive`)

## 🚀 Running Tests

### Command Reference
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/blocs/transaction_bloc_test.dart

# Run tests with coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html

# Run golden tests
flutter test test/golden/ --update-goldens  # Update goldens
flutter test test/golden/                   # Run normally

# Run with specific reporter
flutter test --reporter=expanded           # Verbose output
flutter test --reporter=json              # JSON output

# Run tests matching pattern
flutter test --plain-name="balance"       # Tests containing "balance"

# Watch mode (re-run on file changes)
flutter test --watch

# Run tests on specific platform
flutter test -d macos                     # Run on macOS
flutter test -d chrome                    # Run on Chrome
```

### CI/CD Integration
```yaml
# .github/workflows/test.yml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.x'
          channel: 'stable'
      
      - name: Get dependencies
        run: flutter pub get
      
      - name: Run code generation
        run: flutter packages pub run build_runner build
      
      - name: Run tests
        run: flutter test --coverage
      
      - name: Run golden tests
        run: flutter test test/golden/
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: coverage/lcov.info
```

## 🎯 Best Practices

### General Testing Principles
- **AAA Pattern** - Arrange, Act, Assert
- **Descriptive Names** - Tests should read like documentation
- **Single Responsibility** - One test, one behavior
- **Independent Tests** - Tests shouldn't depend on each other
- **Fast Execution** - Keep tests fast and reliable

### BLoC Testing Best Practices
- **Mock Dependencies** - Always mock external services
- **Test All Paths** - Happy path, error path, edge cases
- **Verify Interactions** - Check that services are called correctly
- **State Equality** - Use Equatable for proper state comparison
- **Resource Cleanup** - Always close BLoCs in tearDown

### Golden Testing Best Practices
- **Fixed Data** - Use consistent test data
- **Multiple States** - Test all visual states
- **Responsive Design** - Test different screen sizes
- **Theme Testing** - Test light and dark themes
- **Regular Updates** - Update goldens when UI intentionally changes

### Widget Testing Best Practices
- **Minimal Setup** - Only test the widget, not the entire app
- **Mock Callbacks** - Use mock functions for testing interactions
- **Pump and Settle** - Always wait for animations to complete
- **Find by Semantics** - Use semantic labels for accessibility
- **Test Edge Cases** - Long text, empty states, error conditions

### Common Anti-Patterns to Avoid
```dart
// ❌ Don't test implementation details
expect(find.byType(Container), findsOneWidget);

// ✅ Test user-visible behavior
expect(find.text('Expected Text'), findsOneWidget);

// ❌ Don't use real services in unit tests
final realService = TransactionService();

// ✅ Mock external dependencies
final mockService = MockTransactionService();

// ❌ Don't use DateTime.now() in tests
final transaction = Transaction(date: DateTime.now());

// ✅ Use fixed dates for consistency
final transaction = Transaction(date: DateTime(2024, 1, 15));
```

## 📊 Test Coverage

### Coverage Goals
- **Statements**: > 80%
- **Branches**: > 80%
- **Functions**: > 80%
- **Lines**: > 80%

### Generating Coverage Reports
```bash
# Generate coverage
flutter test --coverage

# Convert to HTML
genhtml coverage/lcov.info -o coverage/html

# Open coverage report
open coverage/html/index.html
```

### Coverage Analysis
```bash
# Install lcov_parser
dart pub global activate lcov_parser

# Parse coverage
flutter test --coverage
lcov_parser coverage/lcov.info
```

## 🔧 Test Configuration

### Global Test Configuration
```dart
// test/flutter_test_config.dart
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  // Set up global test environment
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Mock system fonts
  const MethodChannel('plugins.flutter.io/path_provider')
      .setMockMethodCallHandler((MethodCall methodCall) async {
    return '/tmp';
  });
  
  return testMain();
}
```

### Custom Matchers
```dart
// test/helpers/custom_matchers.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:finanapp/blocs/transaction/transaction_state.dart';

Matcher isTransactionLoadedWithCount(int count) {
  return isA<TransactionLoaded>()
      .having((state) => state.transactions.length, 'transaction count', count);
}

Matcher hasBalance(double expectedBalance) {
  return isA<TransactionLoaded>()
      .having((state) => state.currentBalance, 'balance', expectedBalance);
}
```

## 📚 Related Documentation
- [BLoC Architecture](BLOC_ARCHITECTURE.md)
- [UI Components](UI_COMPONENTS.md) 
- [Development Guide](DEVELOPMENT.md)
- [Contributing Guidelines](CONTRIBUTING.md)