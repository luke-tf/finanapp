import 'package:flutter/material.dart';
import 'package:finanapp/models/trade.dart';
import 'package:finanapp/widgets/trade/trade_item.dart';

class TradeList extends StatelessWidget {
  final List<Trade> trades;
  final Function(int) deleteTx;
  final Function(int) editTx;

  const TradeList({
    super.key,
    required this.trades,
    required this.deleteTx,
    required this.editTx,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: trades.length,
      itemBuilder: (context, index) {
        final trade = trades[index];
        return TradeItem(
          key: ValueKey(
            trade.key,
          ), // Usa ValueKey para melhor performance
          id: trade.key ?? -1, // Usa -1 como fallback se key for null
          title: trade.title,
          value: trade.value,
          date: trade.date,
          isExpense: trade.isExpense,
          deleteTx: deleteTx,
          editTx: editTx,
        );
      },
    );
  }
}