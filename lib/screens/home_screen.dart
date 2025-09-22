import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finanapp/services/transaction_service.dart';
import 'package:finanapp/widgets/transaction/new_transaction_form.dart';
import 'package:finanapp/widgets/transaction/transaction_list.dart';
import 'package:finanapp/widgets/transaction/empty_transactions_widget.dart';
import 'package:finanapp/widgets/balance/balance_display.dart';
import 'package:finanapp/widgets/common/loading_widget.dart';
import 'package:finanapp/widgets/error/error_display_widget.dart';
import 'package:finanapp/blocs/transaction/transaction_barrel.dart';
import 'package:finanapp/services/error_handler.dart';
import 'package:finanapp/utils/constants.dart';
import 'package:finanapp/screens/edit_transaction_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _deleteTransaction(int key) {
    context.read<TransactionBloc>().add(DeleteTransaction(key: key));
  }

  void _editTransaction(int key) {
    print('Edit transaction with key: $key');

    final state = context.read<TransactionBloc>().state;
    if (state is TransactionLoaded) {
      try {
        final transactionToEdit = state.displayTransactions.firstWhere(
          (tx) => tx.key == key,
        );

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => BlocProvider.value(
              value: context.read<TransactionBloc>(),
              child: EditTransactionScreen(transaction: transactionToEdit),
            ),
          ),
        );
      } catch (e) {
        if (mounted) {
          ErrorHandler.showErrorSnackBar(
            context,
            const AppError(
              message: 'Transaction not found. It may have been deleted.',
              type: ErrorType.unknown,
            ),
          );
        }
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
        return BlocProvider.value(
          value: context.read<TransactionBloc>(),
          child: const NewTransactionForm(),
        );
      },
    );
  }

  void _onRefresh() {
    context.read<TransactionBloc>().add(const RefreshTransactions());
  }

  void _onRetryLoad() {
    context.read<TransactionBloc>().add(const LoadTransactions());
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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _onRefresh,
            tooltip: AppConstants.refreshTooltip,
          ),
        ],
      ),
      body: BlocListener<TransactionBloc, TransactionState>(
        listener: (context, state) {
          if (state is TransactionOperationSuccess) {
            ErrorHandler.showSuccessSnackBar(context, state.message);
          } else if (state is TransactionError) {
            ErrorHandler.showErrorSnackBar(context, state.error);
          }
        },
        child: BlocBuilder<TransactionBloc, TransactionState>(
          builder: (context, state) {
            return _buildBody(state);
          },
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildBody(TransactionState state) {
    if (state is TransactionLoading) {
      return const LoadingWidget();
    }

    if (state is TransactionError) {
      return ErrorDisplayWidget(error: state.error, onRetry: _onRetryLoad);
    }

    if (state is TransactionLoaded || state is TransactionOperationSuccess) {
      final transactions = state is TransactionLoaded
          ? state.displayTransactions
          : (state as TransactionOperationSuccess).transactions;

      final currentBalance = state is TransactionLoaded
          ? state.currentBalance
          : transactions.fold<double>(
              0.0,
              (sum, tx) => tx.isExpense ? sum - tx.value : sum + tx.value,
            );

      final balanceImagePath = TransactionService().getBalanceImagePath(
        currentBalance,
      );

      return RefreshIndicator(
        onRefresh: () async => _onRefresh(),
        child: Padding(
          padding: EdgeInsets.all(AppConstants.getResponsivePadding(context)),
          child: Column(
            children: [
              BalanceDisplay(
                currentBalance: currentBalance,
                getBalanceImagePath: () => balanceImagePath,
              ),
              SizedBox(height: AppConstants.getResponsivePadding(context)),
              Expanded(
                child: transactions.isNotEmpty
                    ? TransactionList(
                        transactions: transactions,
                        deleteTx: _deleteTransaction,
                        editTx: _editTransaction,
                      )
                    : EmptyTransactionsWidget(
                        onAddTransaction: _showTransactionForm,
                      ),
              ),
            ],
          ),
        ),
      );
    }

    // Initial state
    return const LoadingWidget();
  }

  Widget _buildFloatingActionButton() {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        final isAddingTransaction =
            state is TransactionLoaded && state.isAddingTransaction;

        return FloatingActionButton(
          onPressed: isAddingTransaction ? null : _showTransactionForm,
          tooltip: AppConstants.addTransactionTooltip,
          child: isAddingTransaction
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
    );
  }
}
