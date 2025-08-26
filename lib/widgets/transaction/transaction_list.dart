// transaction_list.dart

import 'package:flutter/material.dart';
import 'package:finanapp/widgets/transaction/transaction_item.dart';
import 'package:finanapp/models/transaction.dart';

class TransactionList extends StatelessWidget {
  final List<Transaction> transactions;
  final Function(int) deleteTx;

  const TransactionList({
    super.key,
    required this.transactions,
    required this.deleteTx,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return TransactionItem(
          key: ValueKey(
            transaction.key,
          ), // Usa ValueKey para melhor performance
          id: transaction.key ?? -1, // Usa -1 como fallback se key for null
          title: transaction.title,
          value: transaction.value,
          date: transaction.date,
          isExpense: transaction.isExpense,
          deleteTx: deleteTx,
        );
      },
    );
  }
}
