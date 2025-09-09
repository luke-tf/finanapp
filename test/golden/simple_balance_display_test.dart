import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:finanapp/widgets/balance/balance_display.dart';
import 'package:finanapp/utils/constants.dart';

void main() {
  group('Simple BalanceDisplay Golden Tests', () {
    testGoldens('BalanceDisplay with positive balance', (tester) async {
      final widget = MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: BalanceDisplay(
              currentBalance: 2500.50,
              getBalanceImagePath: () => AppConstants.happyPigImage,
            ),
          ),
        ),
      );

      await tester.pumpWidgetBuilder(widget, surfaceSize: const Size(400, 400));

      await screenMatchesGolden(tester, 'simple_balance_display_positive');
    });

    testGoldens('BalanceDisplay with negative balance', (tester) async {
      final widget = MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: BalanceDisplay(
              currentBalance: -1250.75,
              getBalanceImagePath: () => AppConstants.sadPigImage,
            ),
          ),
        ),
      );

      await tester.pumpWidgetBuilder(widget, surfaceSize: const Size(400, 400));

      await screenMatchesGolden(tester, 'simple_balance_display_negative');
    });

    testGoldens('BalanceDisplay with zero balance', (tester) async {
      final widget = MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: BalanceDisplay(
              currentBalance: 0.0,
              getBalanceImagePath: () => AppConstants.neutralPigImage,
            ),
          ),
        ),
      );

      await tester.pumpWidgetBuilder(widget, surfaceSize: const Size(400, 400));

      await screenMatchesGolden(tester, 'simple_balance_display_zero');
    });

    testGoldens('BalanceDisplay with large balance', (tester) async {
      final widget = MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: BalanceDisplay(
              currentBalance: 99999.99,
              getBalanceImagePath: () => AppConstants.happyPigImage,
            ),
          ),
        ),
      );

      await tester.pumpWidgetBuilder(widget, surfaceSize: const Size(400, 400));

      await screenMatchesGolden(tester, 'simple_balance_display_large');
    });
  });
}
