import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finanapp/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Transaction Management Flow Tests', () {
    setUp(() async {
      // Setup fresh app state before each test
      app.main();
    });

    testWidgets('Complete transaction lifecycle - add, edit, delete', (
      tester,
    ) async {
      await tester.pumpAndSettle();

      // Step 1: Record initial state
      final initialBalance = await _getDisplayedBalance(tester);

      // Step 2: Add new expense transaction
      await _addTransaction(
        tester,
        title: 'Coffee Shop',
        amount: '4.50',
        isExpense: true,
      );

      // Verify transaction was added
      expect(find.text('Coffee Shop'), findsOneWidget);
      expect(find.text('-\$4.50'), findsOneWidget);

      // Verify balance updated
      final balanceAfterAdd = await _getDisplayedBalance(tester);
      expect(balanceAfterAdd, equals(initialBalance - 4.50));

      // Step 3: Edit the transaction
      await _editTransaction(
        tester,
        originalTitle: 'Coffee Shop',
        newTitle: 'Starbucks Coffee',
        newAmount: '5.25',
      );

      // Verify transaction was edited
      expect(find.text('Coffee Shop'), findsNothing);
      expect(find.text('Starbucks Coffee'), findsOneWidget);
      expect(find.text('-\$5.25'), findsOneWidget);

      // Verify balance updated after edit
      final balanceAfterEdit = await _getDisplayedBalance(tester);
      expect(balanceAfterEdit, equals(initialBalance - 5.25));

      // Step 4: Delete the transaction
      await _deleteTransaction(tester, title: 'Starbucks Coffee');

      // Verify transaction was deleted
      expect(find.text('Starbucks Coffee'), findsNothing);
      expect(find.text('-\$5.25'), findsNothing);

      // Verify balance returned to initial state
      final finalBalance = await _getDisplayedBalance(tester);
      expect(finalBalance, equals(initialBalance));
    });

    testWidgets('Multiple transactions affect balance correctly', (
      tester,
    ) async {
      await tester.pumpAndSettle();

      final initialBalance = await _getDisplayedBalance(tester);

      // Add multiple transactions
      await _addTransaction(
        tester,
        title: 'Income 1',
        amount: '1000.00',
        isExpense: false,
      );
      await _addTransaction(
        tester,
        title: 'Expense 1',
        amount: '200.00',
        isExpense: true,
      );
      await _addTransaction(
        tester,
        title: 'Income 2',
        amount: '500.00',
        isExpense: false,
      );
      await _addTransaction(
        tester,
        title: 'Expense 2',
        amount: '150.00',
        isExpense: true,
      );

      // Calculate expected balance: initial + 1000 - 200 + 500 - 150
      final expectedBalance =
          initialBalance + 1000.00 - 200.00 + 500.00 - 150.00;
      final actualBalance = await _getDisplayedBalance(tester);

      expect(actualBalance, equals(expectedBalance));

      // Verify all transactions are displayed
      expect(find.text('Income 1'), findsOneWidget);
      expect(find.text('Expense 1'), findsOneWidget);
      expect(find.text('Income 2'), findsOneWidget);
      expect(find.text('Expense 2'), findsOneWidget);
    });

    testWidgets('Balance display updates correctly with pig images', (
      tester,
    ) async {
      await tester.pumpAndSettle();

      // Start with positive balance
      await _addTransaction(
        tester,
        title: 'Big Income',
        amount: '5000.00',
        isExpense: false,
      );

      // Should show happy pig
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('happy_pig')), findsOneWidget);

      // Add large expense to make balance negative
      await _addTransaction(
        tester,
        title: 'Large Expense',
        amount: '6000.00',
        isExpense: true,
      );

      // Should show sad pig
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('sad_pig')), findsOneWidget);

      // Add income to make balance exactly zero
      await _addTransaction(
        tester,
        title: 'Recovery',
        amount: '1000.00',
        isExpense: false,
      );

      // Should show neutral pig
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('neutral_pig')), findsOneWidget);
    });

    testWidgets('Form validation prevents invalid transactions', (
      tester,
    ) async {
      await tester.pumpAndSettle();

      // Try to add transaction with empty title
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Leave title empty, enter amount
      await tester.enterText(find.byKey(const Key('amount_field')), '100.00');

      final addButton = find.text('Add Transaction');
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.text('Please enter a title'), findsOneWidget);

      // Try with empty amount
      await tester.enterText(
        find.byKey(const Key('title_field')),
        'Test Transaction',
      );
      await tester.enterText(find.byKey(const Key('amount_field')), '');

      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // Should show amount validation error
      expect(find.text('Please enter an amount'), findsOneWidget);

      // Try with invalid amount
      await tester.enterText(
        find.byKey(const Key('amount_field')),
        'not a number',
      );

      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // Should show format validation error
      expect(find.text('Please enter a valid amount'), findsOneWidget);
    });
  });
}

// Helper functions for integration tests
Future<double> _getDisplayedBalance(WidgetTester tester) async {
  final balanceWidget = find.byKey(const Key('balance_amount'));
  expect(balanceWidget, findsOneWidget);

  final Text balanceText = tester.widget(balanceWidget);
  final String balanceString = balanceText.data!.replaceAll(
    RegExp(r'[^\d.-]'),
    '',
  );
  return double.parse(balanceString);
}

Future<void> _addTransaction(
  WidgetTester tester, {
  required String title,
  required String amount,
  required bool isExpense,
}) async {
  // Open add transaction screen
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();

  // Fill form
  await tester.enterText(find.byKey(const Key('title_field')), title);
  await tester.enterText(find.byKey(const Key('amount_field')), amount);

  // Select transaction type
  if (isExpense) {
    await tester.tap(find.byKey(const Key('expense_radio')));
  } else {
    await tester.tap(find.byKey(const Key('income_radio')));
  }
  await tester.pumpAndSettle();

  // Submit form
  await tester.tap(find.text('Add Transaction'));
  await tester.pumpAndSettle();
}

Future<void> _editTransaction(
  WidgetTester tester, {
  required String originalTitle,
  required String newTitle,
  required String newAmount,
}) async {
  // Find and tap edit button for the transaction
  final transactionTile = find.ancestor(
    of: find.text(originalTitle),
    matching: find.byType(Card),
  );

  await tester.tap(
    find.descendant(of: transactionTile, matching: find.byIcon(Icons.edit)),
  );
  await tester.pumpAndSettle();

  // Update form fields
  await tester.enterText(find.byKey(const Key('title_field')), newTitle);
  await tester.enterText(find.byKey(const Key('amount_field')), newAmount);

  // Submit changes
  await tester.tap(find.text('Update Transaction'));
  await tester.pumpAndSettle();
}

Future<void> _deleteTransaction(
  WidgetTester tester, {
  required String title,
}) async {
  // Find and tap delete button for the transaction
  final transactionTile = find.ancestor(
    of: find.text(title),
    matching: find.byType(Card),
  );

  await tester.tap(
    find.descendant(of: transactionTile, matching: find.byIcon(Icons.delete)),
  );
  await tester.pumpAndSettle();

  // Confirm deletion if there's a dialog
  final confirmButton = find.text('Delete');
  if (confirmButton.evaluate().isNotEmpty) {
    await tester.tap(confirmButton);
    await tester.pumpAndSettle();
  }
}
