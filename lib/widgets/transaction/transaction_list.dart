import 'package:flutter/material.dart';
import 'package:finanapp/models/transaction.dart';
import 'package:finanapp/widgets/transaction/transaction_item.dart';

class TransactionList extends StatelessWidget {
  final List<Transaction> transactions;
  final Function(int) deleteTx;
  final Function(int) editTx;

  const TransactionList({
    super.key,
    required this.transactions,
    required this.deleteTx,
    required this.editTx,
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
          editTx: editTx,
        );
      },
    );
  }
}
