import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:finanapp/widgets/trade/trade_item.dart';

void main() {
  group('TradeItem Golden Tests', () {
    testGoldens('TradeItem - Expense', (tester) async {
      final widget = MaterialApp(
        home: Scaffold(
          body: ListView(
            children: [
              TradeItem(
                id: 1,
                title: 'Supermercado Extra',
                value: 150.75,
                date: DateTime(2024, 1, 15), // Fixed date
                isExpense: true,
                deleteTx: (id) {}, // Empty callbacks for golden tests
                editTx: (id) {},
              ),
            ],
          ),
        ),
      );

      await tester.pumpWidgetBuilder(widget, surfaceSize: const Size(400, 200));

      await screenMatchesGolden(tester, 'trade_item_expense');
    });

    testGoldens('TradeItem - Income', (tester) async {
      final widget = MaterialApp(
        home: Scaffold(
          body: ListView(
            children: [
              TradeItem(
                id: 2,
                title: 'Salário Janeiro',
                value: 3500.00,
                date: DateTime(2024, 1, 1),
                isExpense: false,
                deleteTx: (id) {},
                editTx: (id) {},
              ),
            ],
          ),
        ),
      );

      await tester.pumpWidgetBuilder(widget, surfaceSize: const Size(400, 200));

      await screenMatchesGolden(tester, 'trade_item_income');
    });

    testGoldens('TradeItem - Long Title', (tester) async {
      final widget = MaterialApp(
        home: Scaffold(
          body: ListView(
            children: [
              TradeItem(
                id: 3,
                title:
                    'Título muito muito muito longo que pode quebrar o layout da interface',
                value: 99.99,
                date: DateTime(2024, 1, 20),
                isExpense: true,
                deleteTx: (id) {},
                editTx: (id) {},
              ),
            ],
          ),
        ),
      );

      await tester.pumpWidgetBuilder(widget, surfaceSize: const Size(400, 200));

      await screenMatchesGolden(tester, 'trade_item_long_title');
    });

    testGoldens('Multiple TradeItems', (tester) async {
      final widget = MaterialApp(
        home: Scaffold(
          body: ListView(
            children: [
              TradeItem(
                id: 1,
                title: 'Supermercado',
                value: 150.75,
                date: DateTime(2024, 1, 15),
                isExpense: true,
                deleteTx: (id) {},
                editTx: (id) {},
              ),
              TradeItem(
                id: 2,
                title: 'Salário',
                value: 3500.00,
                date: DateTime(2024, 1, 1),
                isExpense: false,
                deleteTx: (id) {},
                editTx: (id) {},
              ),
              TradeItem(
                id: 3,
                title: 'Conta de Luz',
                value: 89.50,
                date: DateTime(2024, 1, 10),
                isExpense: true,
                deleteTx: (id) {},
                editTx: (id) {},
              ),
            ],
          ),
        ),
      );

      await tester.pumpWidgetBuilder(widget, surfaceSize: const Size(400, 300));

      await screenMatchesGolden(tester, 'trade_items_multiple');
    });
  });
}