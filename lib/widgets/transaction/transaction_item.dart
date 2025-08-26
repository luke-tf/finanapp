// transaction_item.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionItem extends StatelessWidget {
  final int id;
  final String title;
  final double value;
  final DateTime date;
  final bool isExpense;
  final Function(int) deleteTx;

  const TransactionItem({
    super.key,
    required this.id,
    required this.title,
    required this.value,
    required this.date,
    required this.isExpense,
    required this.deleteTx,
  });

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar exclusão'),
          content: Text('Deseja excluir a transação "$title"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (id >= 0) {
                  // Verifica se não é o valor de fallback
                  deleteTx(id);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color valueColor = isExpense ? Colors.redAccent : Colors.green;
    final String prefix = isExpense ? '-' : '+';

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: valueColor.withOpacity(0.1),
          child: Icon(
            isExpense ? Icons.remove : Icons.add,
            color: valueColor,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          DateFormat('dd/MM/yyyy').format(date),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$prefix R\$ ${value.toStringAsFixed(2)}',
              style: TextStyle(
                color: valueColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _showDeleteDialog(context),
              color: Colors.grey[600],
              iconSize: 20,
            ),
          ],
        ),
      ),
    );
  }
}
