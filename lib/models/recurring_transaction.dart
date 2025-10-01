import 'package:hive/hive.dart';

part 'recurring_transaction.g.dart';

@HiveType(typeId: 1)
class RecurringTransaction extends HiveObject {
  @HiveField(0)
  late String title;

  @HiveField(1)
  late double value;

  @HiveField(2)
  late bool isExpense;

  @HiveField(3)
  late int totalInstallments;

  @HiveField(4)
  late int currentInstallment;

  @HiveField(5)
  late DateTime startDate;

  @HiveField(6)
  late int paymentDay;

  @HiveField(7)
  late DateTime nextOccurrenceDate;

  @HiveField(8)
  late bool isActive;

  RecurringTransaction({
    this.title = '',
    this.value = 0.0,
    this.isExpense = true,
    this.totalInstallments = 1,
    this.currentInstallment = 1,
    DateTime? startDate,
    int? paymentDay,
    DateTime? nextOccurrenceDate,
    this.isActive = true,
  }) : startDate = startDate ?? DateTime.now(),
       paymentDay = paymentDay ?? DateTime.now().day,
       nextOccurrenceDate = nextOccurrenceDate ?? DateTime.now();

  /// Returns true if all installments have been processed
  bool get isCompleted => currentInstallment > totalInstallments;

  /// Returns the total amount across all installments
  double get totalAmount => value * totalInstallments;

  /// Returns remaining installments
  int get remainingInstallments => totalInstallments - currentInstallment + 1;

  /// Returns remaining amount to pay
  double get remainingAmount => value * remainingInstallments;

  @override
  String toString() {
    return 'RecurringTransaction(title: $title, value: $value, '
        'installment: $currentInstallment/$totalInstallments, '
        'nextDate: $nextOccurrenceDate, isActive: $isActive)';
  }
}
