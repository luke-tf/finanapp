import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:finanapp/screens/home_screen.dart';
import '../../helpers/test_data.dart';
import '../../helpers/widget_test_helpers.dart';

void main() {
  group('HomeScreen Visual Tests', () {
    testGoldens('HomeScreen with transactions', (tester) async {
      await tester.pumpWidgetBuilder(
        FinanAppTestHelpers.createTestApp(
          child: const HomeScreen(),
          mockState: FinanAppTestStates.withBasicTransactions,
        ),
      );

      await multiScreenGolden(tester, 'home_screen_with_transactions');
    });

    testGoldens('HomeScreen empty state', (tester) async {
      await tester.pumpWidgetBuilder(
        FinanAppTestHelpers.createTestApp(
          child: const HomeScreen(),
          mockState: FinanAppTestStates.empty,
        ),
      );

      await multiScreenGolden(tester, 'home_screen_empty_state');
    });

    testGoldens('HomeScreen error state', (tester) async {
      await tester.pumpWidgetBuilder(
        FinanAppTestHelpers.createTestApp(
          child: const HomeScreen(),
          mockState: FinanAppTestStates.error,
        ),
      );

      await multiScreenGolden(tester, 'home_screen_error_state');
    });
  });
}
