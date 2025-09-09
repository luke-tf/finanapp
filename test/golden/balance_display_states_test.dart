import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:finanapp/widgets/balance/balance_display.dart';
import 'package:finanapp/utils/constants.dart';
import '../helpers/golden_test_helper.dart';

void main() {
  group('BalanceDisplay with Different States', () {
    testGoldens('BalanceDisplay with positive balance', (tester) async {
      // Calculate balance from our test data
      final transactions = TestData.sampleTransactions;
      final balance = transactions.fold<double>(
        0.0,
        (sum, tx) => tx.isExpense ? sum - tx.value : sum + tx.value,
      );

      final widget = createTestApp(
        mockState: MockStates.withTransactions,
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                BalanceDisplay(
                  currentBalance: balance,
                  getBalanceImagePath: () => balance >= 0
                      ? AppConstants.happyPigImage
                      : AppConstants.sadPigImage,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpWidgetBuilder(widget, surfaceSize: const Size(400, 600));

      await screenMatchesGolden(tester, 'balance_display_positive_balance');
    });

    testGoldens('BalanceDisplay with negative balance', (tester) async {
      final transactions = TestData.negativeBalanceTransactions;
      final balance = transactions.fold<double>(
        0.0,
        (sum, tx) => tx.isExpense ? sum - tx.value : sum + tx.value,
      );

      final widget = createTestApp(
        mockState: MockStates.negativeBalance,
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                BalanceDisplay(
                  currentBalance: balance,
                  getBalanceImagePath: () => balance >= 0
                      ? AppConstants.happyPigImage
                      : AppConstants.sadPigImage,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpWidgetBuilder(widget, surfaceSize: const Size(400, 600));

      await screenMatchesGolden(tester, 'balance_display_negative_balance');
    });

    testGoldens('BalanceDisplay with zero balance', (tester) async {
      final widget = createTestApp(
        mockState: MockStates.empty,
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                BalanceDisplay(
                  currentBalance: 0.0,
                  getBalanceImagePath: () => AppConstants.neutralPigImage,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpWidgetBuilder(widget, surfaceSize: const Size(400, 600));

      await screenMatchesGolden(tester, 'balance_display_zero_balance');
    });
  });
}
