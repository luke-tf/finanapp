// test/golden/balance_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:finanapp/widgets/balance/balance_card.dart';

void main() {
  group('BalanceCard Golden Tests', () {
    testGoldens('BalanceCard with positive balance', (tester) async {
      // Let's add a different background color to see the change
      final widget = MaterialApp(
        home: Scaffold(
          backgroundColor:
              Colors.grey[100], // 👈 CHANGED: Added background color
          body: Center(child: BalanceCard(balance: 1500.75)),
        ),
      );

      await tester.pumpWidgetBuilder(widget, surfaceSize: const Size(400, 300));

      await screenMatchesGolden(tester, 'balance_card_positive');
    });

    testGoldens('BalanceCard with negative balance', (tester) async {
      final widget = MaterialApp(
        home: Scaffold(body: Center(child: BalanceCard(balance: -250.50))),
      );

      await tester.pumpWidgetBuilder(widget, surfaceSize: const Size(400, 300));

      await screenMatchesGolden(tester, 'balance_card_negative');
    });

    testGoldens('BalanceCard with zero balance', (tester) async {
      final widget = MaterialApp(
        home: Scaffold(body: Center(child: BalanceCard(balance: 0.0))),
      );

      await tester.pumpWidgetBuilder(widget, surfaceSize: const Size(400, 300));

      await screenMatchesGolden(tester, 'balance_card_zero');
    });

    // 👆 Let's add a new test case
    testGoldens('BalanceCard with very large balance', (tester) async {
      final widget = MaterialApp(
        home: Scaffold(body: Center(child: BalanceCard(balance: 999999.99))),
      );

      await tester.pumpWidgetBuilder(widget, surfaceSize: const Size(400, 300));

      await screenMatchesGolden(tester, 'balance_card_large');
    });
  });
}
