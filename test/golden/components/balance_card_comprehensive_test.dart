import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:finanapp/widgets/balance/balance_card.dart';
import '../../helpers/test_data.dart';
import '../../helpers/widget_test_helpers.dart';

void main() {
  group('BalanceCard Comprehensive Visual Tests', () {
    testGoldens('BalanceCard states comparison', (tester) async {
      final builder = GoldenBuilder.grid(columns: 2, widthToHeightRatio: 1.2)
        ..addScenario(
          'Positive Balance',
          FinanAppTestHelpers.wrapWithPadding(BalanceCard(balance: 2500.75)),
        )
        ..addScenario(
          'Negative Balance',
          FinanAppTestHelpers.wrapWithPadding(BalanceCard(balance: -1250.50)),
        )
        ..addScenario(
          'Zero Balance',
          FinanAppTestHelpers.wrapWithPadding(BalanceCard(balance: 0.0)),
        )
        ..addScenario(
          'Large Amount',
          FinanAppTestHelpers.wrapWithPadding(BalanceCard(balance: 999999.99)),
        );

      await tester.pumpWidgetBuilder(
        builder.build(),
        wrapper: (child) => FinanAppTestHelpers.createTestApp(child: child),
      );

      await multiScreenGolden(tester, 'balance_card_all_states');
    });

    testGoldens('BalanceCard responsive behavior', (tester) async {
      const widget = BalanceCard(balance: 1234.56);

      await tester.pumpWidgetBuilder(
        FinanAppTestHelpers.createTestApp(
          child: FinanAppTestHelpers.wrapWithScaffold(Center(child: widget)),
        ),
      );

      await multiScreenGolden(
        tester,
        'balance_card_responsive',
        devices: [Device.phone, Device.tabletPortrait, Device.tabletLandscape],
      );
    });

    testGoldens('BalanceCard with different themes', (tester) async {
      final lightThemeWidget = FinanAppTestHelpers.createTestApp(
        theme: ThemeData.light(),
        child: FinanAppTestHelpers.wrapWithScaffold(
          Center(child: BalanceCard(balance: 1500.00)),
        ),
      );

      final darkThemeWidget = FinanAppTestHelpers.createTestApp(
        theme: ThemeData.dark(),
        child: FinanAppTestHelpers.wrapWithScaffold(
          Center(child: BalanceCard(balance: 1500.00)),
        ),
      );

      final builder = GoldenBuilder.column()
        ..addScenario('Light Theme', lightThemeWidget)
        ..addScenario('Dark Theme', darkThemeWidget);

      await tester.pumpWidgetBuilder(builder.build());
      await screenMatchesGolden(tester, 'balance_card_themes');
    });

    testGoldens('BalanceCard edge cases', (tester) async {
      final builder = GoldenBuilder.grid(columns: 2, widthToHeightRatio: 1.0);

      // Test various edge cases
      final testCases = [
        ('Minimum Positive', 0.01),
        ('Maximum Safe Integer', 9007199254740991.0),
        ('Very Small Negative', -0.01),
        ('Decimal Precision', 123.456789),
      ];

      for (final (label, amount) in testCases) {
        builder.addScenario(
          label,
          FinanAppTestHelpers.wrapWithPadding(BalanceCard(balance: amount)),
        );
      }

      await tester.pumpWidgetBuilder(
        builder.build(),
        wrapper: (child) => FinanAppTestHelpers.createTestApp(child: child),
      );

      await screenMatchesGolden(tester, 'balance_card_edge_cases');
    });
  });
}
