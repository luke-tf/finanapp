import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:finanapp/blocs/transaction/transaction_barrel.dart';
import 'test_data.dart';

class FinanAppTestHelpers {
  static Widget createTestApp({
    required Widget child,
    TransactionState? mockState,
    ThemeData? theme,
  }) {
    final mockBloc = MockTransactionBloc();

    when(
      () => mockBloc.state,
    ).thenReturn(mockState ?? const TransactionLoaded(transactions: []));

    return MaterialApp(
      theme: theme ?? _createTestTheme(),
      home: BlocProvider<TransactionBloc>.value(value: mockBloc, child: child),
    );
  }

  static ThemeData _createTestTheme() {
    return ThemeData(
      primarySwatch: Colors.blue,
      useMaterial3: true,
      // Consistent theme for all tests
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        bodyMedium: TextStyle(fontSize: 16),
      ),
    );
  }

  static Widget wrapWithScaffold(Widget child) {
    return Scaffold(body: child);
  }

  static Widget wrapWithPadding(Widget child, {double padding = 16.0}) {
    return Padding(padding: EdgeInsets.all(padding), child: child);
  }
}

class FinanAppTestStates {
  static TransactionLoaded get withBasicTransactions =>
      TransactionLoaded(transactions: FinanAppTestData.basicTransactions);

  static TransactionLoaded get empty =>
      const TransactionLoaded(transactions: []);

  static TransactionLoaded get withLargeAmounts =>
      TransactionLoaded(transactions: FinanAppTestData.largeAmountTransactions);

  static TransactionError get error => const TransactionError(
    error: AppError(message: 'Test error message', type: ErrorType.network),
  );

  static TransactionLoading get loading => const TransactionLoading();
}

// Mock classes
class MockTransactionBloc extends Mock implements TransactionBloc {}
