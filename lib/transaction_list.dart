// transaction_list.dart

import 'package:flutter/material.dart';
import 'package:finanapp/transaction_item.dart';
import 'package:finanapp/transaction.dart';

class TransactionList extends StatelessWidget {
  final List<Transaction> transactions;
  final Function deleteTx;

  const TransactionList({
    super.key,
    required this.transactions,
    required this.deleteTx,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: transactions.map((transaction) {
        return TransactionItem(
          // O key do Hive é o ID do item
          id: transaction.key.toString(),
          title: transaction.title,
          value: transaction.value,
          date: transaction.date,
          isExpense: transaction.isExpense,
          // Agora passamos o key do Hive para a função de deleção
          deleteTx: () => deleteTx(transaction.key),
        );
      }).toList(),
    );
  }
}
