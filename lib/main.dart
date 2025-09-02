// main.dart - Updated with Provider

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:finanapp/widgets/transaction/new_transaction_form.dart';
import 'package:finanapp/widgets/transaction/transaction_list.dart';
import 'package:finanapp/widgets/balance/balance_display.dart';
import 'package:finanapp/services/database_service.dart';
import 'package:finanapp/providers/transaction_provider.dart';
import 'package:finanapp/services/error_handler.dart';
import 'package:finanapp/utils/constants.dart';
import 'package:finanapp/screens/edit_transaction_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    print(AppConstants.bankInitializingMessage);
    await DatabaseService().initialize();
    print(AppConstants.bankSuccessMessage);
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
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(AppConstants.initErrorMessage),
                const SizedBox(height: 8),
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        // You can add more providers here in the future
        // ProxyProvider for providers that depend on others
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          // Add consistent theming
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
          ),
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    // Load transactions when the widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().loadTransactions();
    });
  }

  void _addNewTransaction(
    String txTitle,
    double txValue,
    bool isExpense,
  ) async {
    final provider = context.read<TransactionProvider>();

    final success = await provider.addTransaction(
      title: txTitle,
      value: txValue,
      isExpense: isExpense,
    );

    if (mounted) {
      if (success) {
        Navigator.of(context).pop(); // Close the modal
        ErrorHandler.showSuccessSnackBar(
          context,
          isExpense
              ? AppConstants.expenseAddedSuccess
              : AppConstants.incomeAddedSuccess,
        );
      } else {
        // Error handling is managed by the provider
        if (provider.error != null) {
          ErrorHandler.showErrorSnackBar(context, provider.error!);
          provider.clearError();
        }
      }
    }
  }

  void _deleteTransaction(int key) async {
    final provider = context.read<TransactionProvider>();

    final success = await provider.deleteTransaction(key);

    if (mounted) {
      if (success) {
        ErrorHandler.showSuccessSnackBar(
          context,
          AppConstants.transactionRemovedSuccess,
        );
      } else {
        // Error handling is managed by the provider
        if (provider.error != null) {
          ErrorHandler.showErrorSnackBar(context, provider.error!);
          provider.clearError();
        }
      }
    }
  }

  void _editTransaction(int key) {
    print('Edit transaction with key: $key');
    final provider = context.read<TransactionProvider>();
    try {
      final transactionToEdit = provider.transactions.firstWhere(
        (tx) => tx.key == key,
      );

      // CORRECTED: Use Navigator.of(context).push with MaterialPageRoute
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) =>
              EditTransactionScreen(transaction: transactionToEdit),
        ),
      );
    } catch (e) {
      // This can happen if the transaction is deleted just before editing.
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context,
          AppError(
            message: 'Transaction not found. It may have been deleted.',
            type: ErrorType.unknown,
          ),
        );
      }
    }
  }

  void _showTransactionForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext modalContext) {
        // Important: Pass the add function, not the context
        return NewTransactionForm(_addNewTransaction);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppConstants.appName),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Optional: Add refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<TransactionProvider>().refreshTransactions();
            },
            tooltip: AppConstants.refreshTooltip,
          ),
        ],
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, transactionProvider, child) {
          // Handle loading state
          if (transactionProvider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(AppConstants.loadingTransactions),
                ],
              ),
            );
          }

          // Handle error state
          if (transactionProvider.hasError &&
              transactionProvider.error != null) {
            return _buildErrorWidget(
              transactionProvider.error!,
              () => transactionProvider.loadTransactions(),
            );
          }

          // Handle success state
          return RefreshIndicator(
            onRefresh: () => transactionProvider.refreshTransactions(),
            child: Padding(
              padding: EdgeInsets.all(
                AppConstants.getResponsivePadding(context),
              ),
              child: Column(
                children: [
                  BalanceDisplay(
                    currentBalance: transactionProvider.currentBalance,
                    getBalanceImagePath: () =>
                        transactionProvider.balanceImagePath,
                  ),
                  SizedBox(height: AppConstants.getResponsivePadding(context)),
                  Expanded(
                    child: transactionProvider.hasTransactions
                        ? TransactionList(
                            transactions: transactionProvider.transactions,
                            deleteTx: _deleteTransaction,
                            editTx: _editTransaction,
                          )
                        : _buildEmptyTransactionsWidget(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: Consumer<TransactionProvider>(
        builder: (context, transactionProvider, child) {
          return FloatingActionButton(
            onPressed: transactionProvider.isAddingTransaction
                ? null
                : _showTransactionForm,
            tooltip: AppConstants.addTransactionTooltip,
            child: transactionProvider.isAddingTransaction
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.add),
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget(AppError error, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getErrorIconForDisplay(error.type),
              size: 64,
              color: _getErrorColorForDisplay(error.type),
            ),
            const SizedBox(height: 16),
            Text(
              AppConstants.errorTitle,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error.message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: Text(AppConstants.retryButton),
                ),
                if (error.details != null) ...[
                  const SizedBox(width: 16),
                  OutlinedButton(
                    onPressed: () => ErrorHandler.showErrorDialog(
                      context,
                      error,
                      onRetry: onRetry,
                    ),
                    child: Text(AppConstants.detailsButton),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyTransactionsWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: AppConstants.getResponsiveIconSize(context),
            color: Colors.grey.shade300,
          ),
          SizedBox(height: AppConstants.getResponsivePadding(context)),
          Text(
            AppConstants.noTransactionsTitle,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: AppConstants.smallPadding),
          Text(
            AppConstants.noTransactionsMessage,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade500),
          ),
          SizedBox(height: AppConstants.getResponsivePadding(context) * 1.5),
          ElevatedButton.icon(
            onPressed: _showTransactionForm,
            icon: const Icon(Icons.add),
            label: Text(AppConstants.firstTransactionButton),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for error display
  IconData _getErrorIconForDisplay(ErrorType type) {
    switch (type) {
      case ErrorType.database:
        return Icons.storage;
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.validation:
        return Icons.warning;
      case ErrorType.unknown:
      default:
        return Icons.error;
    }
  }

  Color _getErrorColorForDisplay(ErrorType type) {
    switch (type) {
      case ErrorType.database:
        return Colors.red;
      case ErrorType.network:
        return Colors.blue;
      case ErrorType.validation:
        return Colors.orange;
      case ErrorType.unknown:
      default:
        return Colors.grey;
    }
  }
}
