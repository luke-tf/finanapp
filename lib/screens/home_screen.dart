import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finanapp/services/trade_service.dart';
import 'package:finanapp/widgets/trade/new_trade_form.dart';
import 'package:finanapp/widgets/trade/trade_list.dart';
import 'package:finanapp/widgets/trade/empty_trades_widget.dart';
import 'package:finanapp/widgets/balance/balance_display.dart';
import 'package:finanapp/widgets/common/loading_widget.dart';
import 'package:finanapp/widgets/error/error_display_widget.dart';
import 'package:finanapp/blocs/trade/trade_barrel.dart';
import 'package:finanapp/services/error_handler.dart';
import 'package:finanapp/utils/constants.dart';
import 'package:finanapp/screens/edit_trade_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Create service instance once to avoid repeated instantiation
  late final TradeService _tradeService;

  @override
  void initState() {
    super.initState();
    _tradeService = TradeService();
  }

  void _deleteTrade(int key) {
    context.read<TradeBloc>().add(DeleteTrade(key: key));
  }

  void _editTrade(int key) {
    print('Edit trade with key: $key');

    final state = context.read<TradeBloc>().state;
    if (state is TradeLoaded) {
      try {
        final tradeToEdit = state.displayTrades.firstWhere(
          (tx) => tx.key == key,
        );

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => BlocProvider.value(
              value: context.read<TradeBloc>(),
              child: EditTradeScreen(trade: tradeToEdit),
            ),
          ),
        );
      } catch (e) {
        if (mounted) {
          ErrorHandler.showErrorSnackBar(
            context,
            const AppError(
              message: 'Trade not found. It may have been deleted.',
              type: ErrorType.unknown,
            ),
          );
        }
      }
    }
  }

  void _showTradeForm() {
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
          value: context.read<TradeBloc>(),
          child: const NewTradeForm(),
        );
      },
    );
  }

  void _onRefresh() {
    context.read<TradeBloc>().add(const RefreshTrades());
  }

  void _onRetryLoad() {
    context.read<TradeBloc>().add(const LoadTrades());
  }

  // Extract balance calculation logic to avoid duplication
  double _calculateBalance(List<dynamic> trades) {
    return trades.fold<double>(
      0.0,
      (sum, tx) => tx.isExpense ? sum - tx.value : sum + tx.value,
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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _onRefresh,
            tooltip: AppConstants.refreshTooltip,
          ),
        ],
      ),
      body: BlocListener<TradeBloc, TradeState>(
        listener: (context, state) {
          if (state is TradeOperationSuccess) {
            ErrorHandler.showSuccessSnackBar(context, state.message);
          } else if (state is TradeError) {
            ErrorHandler.showErrorSnackBar(context, state.error);
          }
        },
        child: BlocBuilder<TradeBloc, TradeState>(
          builder: (context, state) {
            return _buildBody(state);
          },
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildBody(TradeState state) {
    if (state is TradeLoading) {
      return const LoadingWidget();
    }

    if (state is TradeError) {
      return ErrorDisplayWidget(error: state.error, onRetry: _onRetryLoad);
    }

    if (state is TradeLoaded || state is TradeOperationSuccess) {
      final trades = state is TradeLoaded
          ? state.displayTrades
          : (state as TradeOperationSuccess).trades;

      final currentBalance = state is TradeLoaded
          ? state.currentBalance
          : _calculateBalance(trades);

      // Get balance image path directly - cleaner approach
      final balanceImagePath = _tradeService.getBalanceImagePath(
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
                getBalanceImagePath: () =>
                    balanceImagePath, // Keep as callback for now
              ),
              SizedBox(height: AppConstants.getResponsivePadding(context)),
              Expanded(
                child: trades.isNotEmpty
                    ? TradeList(
                        trades: trades,
                        deleteTx: _deleteTrade,
                        editTx: _editTrade,
                      )
                    : EmptyTradesWidget(
                        onAddTrade: _showTradeForm,
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
    return BlocBuilder<TradeBloc, TradeState>(
      builder: (context, state) {
        final isAddingTrade =
            state is TradeLoaded && state.isAddingTrade;

        return FloatingActionButton(
          onPressed: isAddingTrade ? null : _showTradeForm,
          tooltip: AppConstants.addTradeTooltip,
          child: isAddingTrade
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