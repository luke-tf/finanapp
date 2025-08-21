// transaction.dart

import 'package:hive/hive.dart';

part 'transaction.g.dart'; // AQUI: o gerador vai criar esse arquivo

// AQUI: Usamos a anotação do Hive para gerar um adaptador
@HiveType(typeId: 0)
class Transaction extends HiveObject {
  @HiveField(0)
  String title = '';
  @HiveField(1)
  double value = 0.0;
  @HiveField(2)
  DateTime date = DateTime.now();
  @HiveField(3)
  bool isExpense = true;

  @override
  String toString() {
    return 'Transaction(title: $title, value: $value, date: $date, isExpense: $isExpense)';
  }
}
