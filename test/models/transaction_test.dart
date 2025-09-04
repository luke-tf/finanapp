import 'package:flutter_test/flutter_test.dart';
import 'package:finanapp/models/transaction.dart'; // Import your Transaction model

void main() {
  group('Transaction Model', () {
    test('Transaction can be instantiated with all required fields', () {
      // Arrange
      final now = DateTime.now();
      final transaction = Transaction(
        title: 'Groceries',
        value: 50.0,
        date: now,
        isExpense: true,
      );

      // Assert
      expect(transaction.title, 'Groceries');
      expect(transaction.value, 50.0);
      expect(transaction.date, now);
      expect(transaction.isExpense, true);
    });

    test(
      'Transaction initializes with default values when optional fields are omitted',
      () {
        // Arrange
        final transaction = Transaction(); // Using default constructor

        // Assert
        expect(transaction.title, '');
        expect(transaction.value, 0.0);
        expect(transaction.isExpense, true);
        // For date, we expect it to be very close to DateTime.now()
        expect(transaction.date, isA<DateTime>());
        expect(
          transaction.date.difference(DateTime.now()).inSeconds,
          lessThan(2),
        );
      },
    );

    test('Transaction toString() returns a well-formatted string', () {
      // Arrange
      final date = DateTime(2023, 1, 15, 10, 30);
      final transaction = Transaction(
        title: 'Coffee',
        value: 5.50,
        date: date,
        isExpense: true,
      );

      // Act
      final result = transaction.toString();

      // Assert
      expect(
        result,
        'Transaction(title: Coffee, value: 5.5, date: 2023-01-15 10:30:00.000, isExpense: true)',
      );
    });
  });
}
