import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:finanapp/models/transaction.dart';
import 'package:finanapp/blocs/transaction/transaction_barrel.dart';
import 'package:finanapp/services/error_handler.dart';
import 'package:finanapp/utils/constants.dart';

// Mock BLoC for testing
class MockTransactionBloc extends Mock implements TransactionBloc {}

// Test data - same transactions every time for consistent golden images
class TestData {
  static List<Transaction> get sampleTransactions => [
    Transaction(
      title: 'Supermercado Extra',
      value: 150.75,
      date: DateTime(2024, 1, 15), // Fixed date for consistent tests
      isExpense: true,
    ),
    Transaction(
      title: 'Salário Janeiro',
      value: 3500.00,
      date: DateTime(2024, 1, 1),
      isExpense: false,
    ),
    Transaction(
      title: 'Conta de Luz',
      value: 89.50,
      date: DateTime(2024, 1, 10),
      isExpense: true,
    ),
  ];

  static List<Transaction> get emptyTransactions => [];

  static List<Transaction> get negativeBalanceTransactions => [
    Transaction(
      title: 'Carro Novo',
      value: 5000.00,
      date: DateTime(2024, 1, 5),
      isExpense: true,
    ),
    Transaction(
      title: 'Salário',
      value: 2000.00,
      date: DateTime(2024, 1, 1),
      isExpense: false,
    ),
  ];
}

// Helper to create a test app with mock BLoC
Widget createTestApp({
  required Widget child,
  required TransactionState mockState,
}) {
  final mockBloc = MockTransactionBloc();

  // Setup the mock to return our test state
  when(() => mockBloc.state).thenReturn(mockState);

  return BlocProvider<TransactionBloc>.value(
    value: mockBloc,
    child: MaterialApp(
      title: AppConstants.appName,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
        ),
      ),
      home: child,
    ),
  );
}

// Helper to create different BLoC states for testing
class MockStates {
  static TransactionLoaded get withTransactions =>
      TransactionLoaded(transactions: TestData.sampleTransactions);

  static TransactionLoaded get empty =>
      const TransactionLoaded(transactions: []);

  static TransactionLoaded get negativeBalance =>
      TransactionLoaded(transactions: TestData.negativeBalanceTransactions);

  static TransactionLoading get loading => const TransactionLoading();

  static TransactionError get error => const TransactionError(
    error: AppError(
      message: 'Failed to load transactions',
      type: ErrorType.database,
    ),
  );

  static TransactionLoaded get addingTransaction => TransactionLoaded(
    transactions: TestData.sampleTransactions,
    isAddingTransaction: true,
  );
}
