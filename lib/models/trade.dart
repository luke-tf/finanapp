import 'package:hive/hive.dart';

part 'trade.g.dart';

@HiveType(typeId: 0)
class Trade extends HiveObject {
  @HiveField(0)
  late String title;

  @HiveField(1)
  late double value;

  @HiveField(2)
  late DateTime date;

  @HiveField(3)
  late bool isExpense;

  Trade({
    this.title = '',
    this.value = 0.0,
    DateTime? date,
    this.isExpense = true,
  }) : date = date ?? DateTime.now();

  @override
  String toString() {
    return 'Trade(title: $title, value: $value, date: $date, isExpense: $isExpense)';
  }
}