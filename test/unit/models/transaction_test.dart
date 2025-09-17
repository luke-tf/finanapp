import 'package:flutter_test/flutter_test.dart';
import 'package:finanapp/models/transaction.dart';

void main() {
  group('Transaction Model Tests', () {
    test('should create transaction with correct properties', () {
      // Arrange
      const title = 'Test Transaction';
      const value = 100.50;
      final date = DateTime(2024, 3, 15);
      const isExpense = true;

      // Act
      final transaction = Transaction(
        title: title,
        value: value,
        date: date,
        isExpense: isExpense,
      );

      // Assert
      expect(transaction.title, equals(title));
      expect(transaction.value, equals(value));
      expect(transaction.date, equals(date));
      expect(transaction.isExpense, equals(isExpense));
    });

    test('should handle zero value transactions', () {
      final transaction = Transaction(
        title: 'Zero Transaction',
        value: 0.0,
        date: DateTime.now(),
        isExpense: true,
      );

      expect(transaction.value, equals(0.0));
    });

    test('should handle maximum value transactions', () {
      final transaction = Transaction(
        title: 'Max Transaction',
        value: double.maxFinite,
        date: DateTime.now(),
        isExpense: false,
      );

      expect(transaction.value, equals(double.maxFinite));
    });
  });
}
