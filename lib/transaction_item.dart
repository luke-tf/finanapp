// transaction_item.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionItem extends StatelessWidget {
  final String id;
  final String title;
  final double value;
  final DateTime date;
  final bool isExpense;

  // AQUI VAMOS ADICIONAR A NOVA PROPRIEDADE PARA A FUNÇÃO DE EXCLUSÃO
  final Function deleteTx;

  const TransactionItem({
    super.key,
    required this.id,
    required this.title,
    required this.value,
    required this.date,
    required this.isExpense,
    required this.deleteTx, // E AQUI A GENTE ADICIONA NO CONSTRUTOR
  });

  @override
  Widget build(BuildContext context) {
    final Color valueColor = isExpense ? Colors.redAccent : Colors.green;

    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      child: ListTile(
        leading: CircleAvatar(
          radius: 30,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: FittedBox(
              child: Text(
                'R\$${value.toStringAsFixed(2)}',
                style: TextStyle(color: valueColor),
              ),
            ),
          ),
        ),
        title: Text(title, style: Theme.of(context).textTheme.titleLarge),
        subtitle: Text(DateFormat('d MMM y').format(date)),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            // AQUI ESTÁ A MUDANÇA: chamar a função que vai ser passada
            deleteTx(id);
          },
          color: Theme.of(context).colorScheme.error,
        ),
      ),
    );
  }
}
