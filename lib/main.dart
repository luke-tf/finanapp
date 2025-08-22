// main.dart

import 'package:flutter/material.dart';
import 'package:finanapp/new_transaction_form.dart';
import 'package:finanapp/transaction_list.dart';
import 'package:finanapp/balance_display.dart';
import 'package:finanapp/database_service.dart';
import 'package:finanapp/transaction.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    print('Iniciando inicialização do banco...');
    await DatabaseService().initialize();
    print('Banco inicializado com sucesso!');
    runApp(const FinanappApplication());
  } catch (e, stackTrace) {
    print('ERRO na inicialização: $e');
    print('StackTrace: $stackTrace');
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text('Erro ao inicializar aplicação'),
                SizedBox(height: 8),
                Text('$e', textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FinanappApplication extends StatelessWidget {
  const FinanappApplication({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finanapp',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final DatabaseService _databaseService = DatabaseService();

  void _addNewTransaction(
    String txTitle,
    double txValue,
    bool isExpense,
  ) async {
    try {
      final newTransaction = Transaction(
        title: txTitle,
        value: txValue,
        date: DateTime.now(),
        isExpense: isExpense,
      );

      await _databaseService.addTransaction(newTransaction);
      setState(() {}); // Força a reconstrução do widget
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao adicionar transação: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _deleteTransaction(int key) async {
    try {
      await _databaseService.deleteTransaction(key);
      setState(() {}); // Força a reconstrução do widget
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao deletar transação: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finanapp'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Transaction>>(
        future: _databaseService.getAllTransactions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Erro ao carregar dados',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 8),
                  Text('${snapshot.error}'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          } else {
            final transactions = snapshot.data ?? [];
            final calculatedBalance = _calculateBalance(transactions);

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  BalanceDisplay(
                    currentBalance: calculatedBalance,
                    getBalanceImagePath: () =>
                        _getBalanceImagePath(calculatedBalance),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: transactions.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.receipt_long,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Nenhuma transação ainda',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineSmall,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Adicione uma transação tocando no botão +',
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : TransactionList(
                            transactions: transactions,
                            deleteTx: _deleteTransaction,
                          ),
                  ),
                ],
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (BuildContext modalContext) {
              return NewTransactionForm(_addNewTransaction);
            },
          );
        },
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
