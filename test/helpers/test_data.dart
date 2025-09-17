import 'package:finanapp/models/transaction.dart';

class FinanAppTestData {
  // Consistent test data for all tests
  static const String testUserId = 'test_user_001';

  // Sample transactions with various scenarios
  static List<Transaction> get basicTransactions => [
    Transaction(
      title: 'Grocery Shopping',
      value: 125.50,
      date: DateTime(2024, 3, 15, 10, 30),
      isExpense: true,
    ),
    Transaction(
      title: 'Monthly Salary',
      value: 4500.00,
      date: DateTime(2024, 3, 1, 9, 0),
      isExpense: false,
    ),
    Transaction(
      title: 'Electric Bill',
      value: 89.75,
      date: DateTime(2024, 3, 10, 14, 15),
      isExpense: true,
    ),
  ];

  static List<Transaction> get largeAmountTransactions => [
    Transaction(
      title: 'Car Purchase',
      value: 25000.00,
      date: DateTime(2024, 3, 20),
      isExpense: true,
    ),
    Transaction(
      title: 'Investment Return',
      value: 15000.00,
      date: DateTime(2024, 3, 25),
      isExpense: false,
    ),
  ];

  static List<Transaction> get emptyTransactionList => [];

  // Edge case data
  static List<Transaction> get edgeCaseTransactions => [
    Transaction(
      title:
          'Very Long Transaction Title That Might Cause UI Issues When Displayed',
      value: 0.01, // Minimum value
      date: DateTime(2024, 12, 31, 23, 59),
      isExpense: true,
    ),
    Transaction(
      title: 'Max Value Test',
      value: 999999.99,
      date: DateTime(2024, 1, 1, 0, 0),
      isExpense: false,
    ),
  ];

  // Calculate balances for test assertions
  static double calculateBalance(List<Transaction> transactions) {
    return transactions.fold<double>(
      0.0,
      (balance, tx) => tx.isExpense ? balance - tx.value : balance + tx.value,
    );
  }
}
