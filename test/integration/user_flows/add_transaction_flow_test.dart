import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:finanapp/main.dart' as app;
import '../helpers/integration_test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Add Transaction User Flow', () {
    testWidgets('Complete add expense transaction flow', (tester) async {
      // Arrange - Start the app
      app.main();
      await tester.pumpAndSettle();

      // Act & Assert - Navigate to add transaction
      final addButton = find.byType(FloatingActionButton);
      expect(addButton, findsOneWidget);

      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // Fill transaction form
      await IntegrationTestHelpers.fillTransactionForm(
        tester,
        title: 'Integration Test Expense',
        amount: '50.25',
        isExpense: true,
      );

      // Submit form
      final submitButton = find.text('Add Transaction');
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Verify transaction appears in list
      expect(find.text('Integration Test Expense'), findsOneWidget);
      expect(find.text('-\$50.25'), findsOneWidget);

      // Verify balance updated
      await IntegrationTestHelpers.verifyBalanceUpdate(tester, -50.25);
    });

    testWidgets('Add income transaction updates balance correctly', (
      tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      // Record initial balance
      final initialBalance = await IntegrationTestHelpers.getCurrentBalance(
        tester,
      );

      // Add income transaction
      await IntegrationTestHelpers.addTransaction(
        tester,
        title: 'Test Income',
        amount: '100.00',
        isExpense: false,
      );

      // Verify final balance
      final expectedBalance = initialBalance + 100.00;
      await IntegrationTestHelpers.verifyBalanceUpdate(tester, expectedBalance);
    });
  });
}
