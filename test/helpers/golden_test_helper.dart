import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:finanapp/models/trade.dart';
import 'package:finanapp/blocs/trade/trade_barrel.dart';
import 'package:finanapp/services/error_handler.dart';
import 'package:finanapp/utils/constants.dart';

// Mock BLoC for testing
class MockTradeBloc extends Mock implements TradeBloc {}

// Test data - same trades every time for consistent golden images
class TestData {
  static List<Trade> get sampleTrades => [
    Trade(
      title: 'Supermercado Extra',
      value: 150.75,
      date: DateTime(2024, 1, 15), // Fixed date for consistent tests
      isExpense: true,
    ),
    Trade(
      title: 'Salário Janeiro',
      value: 3500.00,
      date: DateTime(2024, 1, 1),
      isExpense: false,
    ),
    Trade(
      title: 'Conta de Luz',
      value: 89.50,
      date: DateTime(2024, 1, 10),
      isExpense: true,
    ),
  ];

  static List<Trade> get emptyTrades => [];

  static List<Trade> get negativeBalanceTrades => [
    Trade(
      title: 'Carro Novo',
      value: 5000.00,
      date: DateTime(2024, 1, 5),
      isExpense: true,
    ),
    Trade(
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
  required TradeState mockState,
}) {
  final mockBloc = MockTradeBloc();

  // Setup the mock to return our test state
  when(() => mockBloc.state).thenReturn(mockState);

  return BlocProvider<TradeBloc>.value(
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
  static TradeLoaded get withTrades =>
      TradeLoaded(trades: TestData.sampleTrades);

  static TradeLoaded get empty =>
      const TradeLoaded(trades: []);

  static TradeLoaded get negativeBalance =>
      TradeLoaded(trades: TestData.negativeBalanceTrades);

  static TradeLoading get loading => const TradeLoading();

  static TradeError get error => const TradeError(
    error: AppError(
      message: 'Failed to load trades',
      type: ErrorType.database,
    ),
  );

  static TradeLoaded get addingTrade => TradeLoaded(
    trades: TestData.sampleTrades,
    isAddingTrade: true,
  );
}