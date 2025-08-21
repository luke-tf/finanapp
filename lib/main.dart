// main.dart

import 'package:flutter/material.dart';
import 'package:finanapp/new_transaction_form.dart';
import 'package:finanapp/transaction_list.dart';
import 'package:finanapp/balance_display.dart';
import 'package:finanapp/database_service.dart';
import 'package:finanapp/transaction.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService().initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  void _addNewTransaction(
    String txTitle,
    double txValue,
    bool isExpense,
  ) async {
    final newTransaction = Transaction()
      ..title = txTitle
      ..value = txValue
      ..date = DateTime.now()
      ..isExpense = isExpense;

    await DatabaseService().addTransaction(newTransaction);
    setState(() {}); // Força a reconstrução do widget
  }

  void _deleteTransaction(int id) async {
    await DatabaseService().deleteTransaction(id);
    setState(() {}); // Força a reconstrução do widget
  }

  // AQUI ESTÁ A MUDANÇA: A FUNÇÃO NÃO CHAMA setState E RETORNA UM VALOR
  double _calculateBalance(List<Transaction> transactions) {
    double totalBalance = 0;
    for (var transaction in transactions) {
      if (transaction.isExpense) {
        totalBalance -= transaction.value;
      } else {
        totalBalance += transaction.value;
      }
    }
    return totalBalance;
  }

  String _getBalanceImagePath(double currentBalance) {
    if (currentBalance < 0) {
      return 'assets/images/porquinho_triste.png';
    } else if (currentBalance == 0) {
      return 'assets/images/porquinho_neutro.png';
    } else {
      return 'assets/images/porquinho_feliz.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Finanapp'),
          backgroundColor: Colors.blueAccent,
        ),
        body: FutureBuilder<List<Transaction>>(
          future: DatabaseService().getAllTransactions(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Erro: ${snapshot.error}'));
            } else {
              final transactions = snapshot.data ?? [];
              final calculatedBalance = _calculateBalance(
                transactions,
              ); // AQUI: CALCULAMOS O SALDO
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    BalanceDisplay(
                      currentBalance:
                          calculatedBalance, // AQUI: USAMOS O VALOR CALCULADO
                      getBalanceImagePath: () =>
                          _getBalanceImagePath(calculatedBalance),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: TransactionList(
                        transactions: transactions,
                        deleteTx: (id) => _deleteTransaction(id),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
        floatingActionButton: Builder(
          builder: (BuildContext builderContext) {
            return FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  context: builderContext,
                  isScrollControlled: true,
                  builder: (BuildContext context) {
                    return NewTransactionForm(_addNewTransaction);
                  },
                );
              },
              child: const Icon(Icons.add),
            );
          },
        ),
      ),
    );
  }
}
