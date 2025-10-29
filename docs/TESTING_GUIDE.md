# Testing Guide

**Testing Strategies (To Be Implemented)**

---

## Overview

This document outlines the testing strategy for Finanapp. Tests are **planned** but not yet implemented.

## Test Structure

```
test/
├── unit/                    # Unit tests
│   ├── services/
│   │   ├── trade_service_test.dart
│   │   └── database_service_test.dart
│   └── models/
│       └── trade_test.dart
├── bloc/                    # BLoC tests
│   └── trade_bloc_test.dart
├── widget/                  # Widget tests
│   ├── trade_item_test.dart
│   ├── balance_display_test.dart
│   └── new_trade_form_test.dart
├── golden/                  # Golden/snapshot tests
│   ├── home_screen_test.dart
│   └── trade_item_test.dart
└── helpers/                 # Test utilities
    ├── test_data.dart
    └── mock_services.dart
```

---

## Unit Tests

### Purpose

Test individual functions and methods in isolation.

### TradeService Tests

**File**: `test/unit/services/trade_service_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:finanapp/services/trade_service.dart';
import 'package:finanapp/models/trade.dart';

class MockDatabaseService extends Mock implements DatabaseService {}

void main() {
  late TradeService service;
  late MockDatabaseService mockDb;

  setUp(() {
    mockDb = MockDatabaseService();
    service = TradeService(databaseService: mockDb);
  });

  group('TradeService', () {
    group('calculateBalance', () {
      test('returns 0 for empty list', () {
        expect(service.calculateBalance([]), 0.0);
      });

      test('calculates positive balance correctly', () {
        final trades = [
          Trade(value: 100, isExpense: false),
          Trade(value: 50, isExpense: true),
        ];
        expect(service.calculateBalance(trades), 50.0);
      });

      test('calculates negative balance correctly', () {
        final trades = [
          Trade(value: 50, isExpense: false),
          Trade(value: 100, isExpense: true),
        ];
        expect(service.calculateBalance(trades), -50.0);
      });
    });

    group('getBalanceImagePath', () {
      test('returns happy pig for positive balance', () {
        expect(
          service.getBalanceImagePath(10.0),
          AppConstants.happyPigImage,
        );
      });

      test('returns neutral pig for zero balance', () {
        expect(
          service.getBalanceImagePath(0.0),
          AppConstants.neutralPigImage,
        );
      });

      test('returns sad pig for negative balance', () {
        expect(
          service.getBalanceImagePath(-10.0),
          AppConstants.sadPigImage,
        );
      });
    });

    group('addTrade', () {
      test('throws on empty title', () {
        expect(
          () => service.addTrade(
            title: '',
            value: 10,
            isExpense: true,
          ),
          throwsA(isA<AppError>()),
        );
      });

      test('throws on zero value', () {
        expect(
          () => service.addTrade(
            title: 'Test',
            value: 0,
            isExpense: true,
          ),
          throwsA(isA<AppError>()),
        );
      });

      test('throws on negative value', () {
        expect(
          () => service.addTrade(
            title: 'Test',
            value: -10,
            isExpense: true,
          ),
          throwsA(isA<AppError>()),
        );
      });

      test('calls database service on valid input', () async {
        when(() => mockDb.addTrade(any())).thenAnswer((_) async {});

        await service.addTrade(
          title: 'Coffee',
          value: 5.50,
          isExpense: true,
        );

        verify(() => mockDb.addTrade(any())).called(1);
      });
    });

    group('getFinancialSummary', () {
      test('returns correct summary', () {
        final trades = [
          Trade(value: 1000, isExpense: false),
          Trade(value: 500, isExpense: false),
          Trade(value: 300, isExpense: true),
          Trade(value: 200, isExpense: true),
        ];

        final summary = service.getFinancialSummary(trades);

        expect(summary['income'], 1500.0);
        expect(summary['expenses'], 500.0);
        expect(summary['balance'], 1000.0);
      });

      test('handles empty list', () {
        final summary = service.getFinancialSummary([]);

        expect(summary['income'], 0.0);
        expect(summary['expenses'], 0.0);
        expect(summary['balance'], 0.0);
      });
    });
  });
}
```

### DatabaseService Tests

**File**: `test/unit/services/database_service_test.dart`

```dart
void main() {
  late DatabaseService service;

  setUp(() async {
    // Use in-memory Hive for tests
    final directory = await getTemporaryDirectory();
    Hive.init(directory.path);
    Hive.registerAdapter(TradeAdapter());
    service = DatabaseService();
    await service.initialize();
  });

  tearDown(() async {
    await Hive.close();
  });

  group('DatabaseService', () {
    test('addTrade stores trade', () async {
      final trade = Trade(
        title: 'Test',
        value: 10.0,
        isExpense: true,
      );

      await service.addTrade(trade);
      final trades = await service.getAllTrades();

      expect(trades.length, 1);
      expect(trades.first.title, 'Test');
    });

    test('updateTrade modifies trade', () async {
      final trade = Trade(title: 'Original', value: 10.0);
      await service.addTrade(trade);

      trade.title = 'Updated';
      await service.updateTrade(trade);

      final trades = await service.getAllTrades();
      expect(trades.first.title, 'Updated');
    });

    test('deleteTrade removes trade', () async {
      final trade = Trade(title: 'Test', value: 10.0);
      await service.addTrade(trade);

      await service.deleteTrade(trade.key!);
      final trades = await service.getAllTrades();

      expect(trades.isEmpty, true);
    });
  });
}
```

---

## BLoC Tests

### Purpose

Test state transitions and business logic in BLoCs.

### TradeBloc Tests

**File**: `test/bloc/trade_bloc_test.dart`

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:finanapp/blocs/trade/trade_barrel.dart';
import 'package:finanapp/services/trade_service.dart';

class MockTradeService extends Mock implements TradeService {}

void main() {
  late TradeBloc bloc;
  late MockTradeService mockService;

  setUp(() {
    mockService = MockTradeService();
    bloc = TradeBloc(tradeService: mockService);
  });

  group('TradeBloc', () {
    test('initial state is TradeInitial', () {
      expect(bloc.state, const TradeInitial());
    });

    group('LoadTrades', () {
      final mockTrades = [
        Trade(title: 'Coffee', value: 5.50, isExpense: true),
        Trade(title: 'Salary', value: 1000.0, isExpense: false),
      ];

      blocTest<TradeBloc, TradeState>(
        'emits [TradeLoading, TradeLoaded] when successful',
        build: () {
          when(() => mockService.getAllTrades())
              .thenAnswer((_) async => mockTrades);
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadTrades()),
        expect: () => [
          isA<TradeLoading>(),
          isA<TradeLoaded>().having(
            (state) => state.trades,
            'trades',
            mockTrades,
          ),
        ],
        verify: (_) {
          verify(() => mockService.getAllTrades()).called(1);
        },
      );

      blocTest<TradeBloc, TradeState>(
        'emits [TradeLoading, TradeError] when fails',
        build: () {
          when(() => mockService.getAllTrades())
              .thenThrow(Exception('Database error'));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadTrades()),
        expect: () => [
          isA<TradeLoading>(),
          isA<TradeError>(),
        ],
      );
    });

    group('AddTrade', () {
      blocTest<TradeBloc, TradeState>(
        'emits success states when trade added',
        build: () {
          when(() => mockService.addTrade(
            title: any(named: 'title'),
            value: any(named: 'value'),
            isExpense: any(named: 'isExpense'),
          )).thenAnswer((_) async {});
          
          when(() => mockService.getAllTrades())
              .thenAnswer((_) async => []);
          
          return bloc;
        },
        seed: () => const TradeLoaded(trades: []),
        act: (bloc) => bloc.add(
          const AddTrade(
            title: 'Coffee',
            value: 5.50,
            isExpense: true,
          ),
        ),
        expect: () => [
          isA<TradeLoaded>().having(
            (s) => s.isAddingTrade,
            'isAddingTrade',
            true,
          ),
          isA<TradeOperationSuccess>(),
          isA<TradeLoaded>(),
        ],
      );
    });

    group('SearchTrades', () {
      final trades = [
        Trade(title: 'Coffee Shop', value: 5.0),
        Trade(title: 'Salary', value: 1000.0),
      ];

      blocTest<TradeBloc, TradeState>(
        'filters trades by title',
        build: () => bloc,
        seed: () => TradeLoaded(trades: trades),
        act: (bloc) => bloc.add(const SearchTrades(query: 'coffee')),
        expect: () => [
          isA<TradeLoaded>().having(
            (s) => s.filteredTrades.length,
            'filteredTrades length',
            1,
          ).having(
            (s) => s.filteredTrades.first.title,
            'filtered trade title',
            'Coffee Shop',
          ),
        ],
      );
    });
  });
}
```

---

## Widget Tests

### Purpose

Test individual widgets and user interactions.

### TradeItem Tests

**File**: `test/widget/trade_item_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finanapp/widgets/trade/trade_item.dart';

void main() {
  group('TradeItem', () {
    testWidgets('displays title and value', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TradeItem(
              id: 1,
              title: 'Coffee',
              value: 5.50,
              date: DateTime(2024, 10, 28),
              isExpense: true,
              deleteTx: (_) {},
              editTx: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Coffee'), findsOneWidget);
      expect(find.text('- R\$ 5.50'), findsOneWidget);
      expect(find.text('28/10/2024'), findsOneWidget);
    });

    testWidgets('shows red color for expenses', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TradeItem(
              id: 1,
              title: 'Coffee',
              value: 5.50,
              date: DateTime.now(),
              isExpense: true,
              deleteTx: (_) {},
              editTx: (_) {},
            ),
          ),
        ),
      );

      // Find text with minus sign (expense indicator)
      expect(find.text('- R\$ 5.50'), findsOneWidget);
    });

    testWidgets('shows green color for income', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TradeItem(
              id: 1,
              title: 'Salary',
              value: 1000.0,
              date: DateTime.now(),
              isExpense: false,
              deleteTx: (_) {},
              editTx: (_) {},
            ),
          ),
        ),
      );

      // Find text with plus sign (income indicator)
      expect(find.text('+ R\$ 1000.00'), findsOneWidget);
    });

    testWidgets('calls deleteTx when delete button tapped', (tester) async {
      int? deletedId;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TradeItem(
              id: 42,
              title: 'Test',
              value: 10.0,
              date: DateTime.now(),
              isExpense: true,
              deleteTx: (id) => deletedId = id,
              editTx: (_) {},
            ),
          ),
        ),
      );

      // Tap delete button
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      // Confirm dialog
      await tester.tap(find.text('Excluir'));
      await tester.pumpAndSettle();

      expect(deletedId, 42);
    });

    testWidgets('calls editTx on long press', (tester) async {
      int? editedId;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TradeItem(
              id: 42,
              title: 'Test',
              value: 10.0,
              date: DateTime.now(),
              isExpense: true,
              deleteTx: (_) {},
              editTx: (id) => editedId = id,
            ),
          ),
        ),
      );

      await tester.longPress(find.byType(TradeItem));
      await tester.pumpAndSettle();

      expect(editedId, 42);
    });
  });
}
```

---

## Golden Tests

### Purpose

Visual regression testing - ensure UI doesn't change unintentionally.

### Setup

Add to `pubspec.yaml`:
```yaml
dev_dependencies:
  golden_toolkit: ^0.15.0
```

### TradeItem Golden Test

**File**: `test/golden/trade_item_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:finanapp/widgets/trade/trade_item.dart';

void main() {
  group('TradeItem Golden Tests', () {
    testGoldens('expense trade', (tester) async {
      await tester.pumpWidgetBuilder(
        TradeItem(
          id: 1,
          title: 'Coffee Shop',
          value: 5.50,
          date: DateTime(2024, 10, 28),
          isExpense: true,
          deleteTx: (_) {},
          editTx: (_) {},
        ),
        surfaceSize: const Size(400, 100),
      );

      await screenMatchesGolden(tester, 'trade_item_expense');
    });

    testGoldens('income trade', (tester) async {
      await tester.pumpWidgetBuilder(
        TradeItem(
          id: 2,
          title: 'Salary',
          value: 1000.0,
          date: DateTime(2024, 10, 28),
          isExpense: false,
          deleteTx: (_) {},
          editTx: (_) {},
        ),
        surfaceSize: const Size(400, 100),
      );

      await screenMatchesGolden(tester, 'trade_item_income');
    });
  });
}
```

### Running Golden Tests

```bash
# Generate/update golden files
flutter test --update-goldens

# Run golden tests
flutter test test/golden/

# Run all tests
flutter test
```

---

## Test Helpers

### Mock Data

**File**: `test/helpers/test_data.dart`

```dart
import 'package:finanapp/models/trade.dart';

class TestData {
  static Trade createExpense({
    String title = 'Test Expense',
    double value = 10.0,
    DateTime? date,
  }) {
    return Trade(
      title: title,
      value: value,
      date: date ?? DateTime(2024, 10, 28),
      isExpense: true,
    );
  }

  static Trade createIncome({
    String title = 'Test Income',
    double value = 100.0,
    DateTime? date,
  }) {
    return Trade(
      title: title,
      value: value,
      date: date ?? DateTime(2024, 10, 28),
      isExpense: false,
    );
  }

  static List<Trade> createSampleTrades() {
    return [
      createExpense(title: 'Coffee', value: 5.50),
      createExpense(title: 'Lunch', value: 15.00),
      createIncome(title: 'Salary', value: 1000.0),
      createIncome(title: 'Freelance', value: 200.0),
    ];
  }
}
```

### Mock Services

**File**: `test/helpers/mock_services.dart`

```dart
import 'package:mocktail/mocktail.dart';
import 'package:finanapp/services/trade_service.dart';
import 'package:finanapp/services/database_service.dart';

class MockTradeService extends Mock implements TradeService {}
class MockDatabaseService extends Mock implements DatabaseService {}
```

---

## Running Tests

### Commands

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit/services/trade_service_test.dart

# Run tests with coverage
flutter test --coverage

# Run only unit tests
flutter test test/unit/

# Run only widget tests
flutter test test/widget/

# Run only BLoC tests
flutter test test/bloc/

# Update golden files
flutter test --update-goldens

# Run in watch mode (install first: dart pub global activate test_runner)
flutter test --watch
```

### Coverage

Generate HTML coverage report:

```bash
# 1. Run tests with coverage
flutter test --coverage

# 2. Generate HTML report (requires lcov)
genhtml coverage/lcov.info -o coverage/html

# 3. Open in browser
open coverage/html/index.html
```

---

## Best Practices

### ✅ Do

- Write tests before fixing bugs
- Test edge cases (empty, null, extreme values)
- Use descriptive test names
- Group related tests
- Mock external dependencies
- Keep tests fast
- Test user behavior, not implementation
- Use setUp/tearDown for common initialization

### ❌ Don't

- Test implementation details
- Write flaky tests
- Depend on test execution order
- Share state between tests
- Test third-party libraries
- Ignore failing tests
- Over-mock (mock only what you need)

---

**Next**: [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Common issues