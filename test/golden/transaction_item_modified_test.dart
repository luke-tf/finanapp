import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:finanapp/widgets/transaction/transaction_item.dart';

void main() {
  group('TransactionItem Modified Tests', () {
    testGoldens('TransactionItem - Expense with CHANGES', (tester) async {
      final widget = MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.grey[50], // 👈 CHANGE 1: Added background
          body: Container(
            padding: const EdgeInsets.all(8.0), // 👈 CHANGE 2: Added padding
            child: ListView(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                  ), // 👈 CHANGE 3: Extra margin
                  child: TransactionItem(
                    id: 1,
                    title: 'Supermercado Extra',
                    value: 150.75,
                    date: DateTime(2024, 1, 15),
                    isExpense: true,
                    deleteTx: (id) {},
                    editTx: (id) {},
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpWidgetBuilder(widget, surfaceSize: const Size(400, 200));

      // 👈 IMPORTANT: Using the SAME golden file name as before
      await screenMatchesGolden(tester, 'transaction_item_expense');
    });

    testGoldens('TransactionItem - Income with CHANGES', (tester) async {
      final widget = MaterialApp(
        theme: ThemeData(
          // 👈 CHANGE 4: Different theme colors
          cardTheme: CardThemeData(color: Colors.blue[50], elevation: 8.0),
        ),
        home: Scaffold(
          body: ListView(
            children: [
              TransactionItem(
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

      // 👈 IMPORTANT: Using the SAME golden file name as before
      await screenMatchesGolden(tester, 'transaction_item_income');
    });
  });
}
