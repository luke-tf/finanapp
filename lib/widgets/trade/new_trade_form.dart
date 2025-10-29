import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finanapp/blocs/trade/trade_barrel.dart';
import 'package:finanapp/utils/constants.dart';

class NewTradeForm extends StatefulWidget {
  const NewTradeForm({super.key});

  @override
  State<NewTradeForm> createState() => _NewTradeFormState();
}

class _NewTradeFormState extends State<NewTradeForm> {
  final _titleController = TextEditingController();
  final _valueController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _titleFocusNode = FocusNode();
  final _valueFocusNode = FocusNode();

  bool _isExpense = true; // Inicia como despesa por padrão

  @override
  void initState() {
    super.initState();
    // Auto-focus on title field when form opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _titleFocusNode.requestFocus();
    });
  }

  void _submitData() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final enteredTitle = _titleController.text.trim();
    final enteredValue = double.tryParse(
      _valueController.text.replaceAll(',', '.'),
    );

    if (enteredTitle.isEmpty || enteredValue == null || enteredValue <= 0) {
      _showErrorDialog(AppConstants.fillAllFieldsError);
      return;
    }

    // Dispatch BLoC event instead of callback
    context.read<TradeBloc>().add(
      AddTrade(
        title: enteredTitle,
        value: enteredValue,
        isExpense: _isExpense,
      ),
    );

    // Close the modal - this will be handled by BlocListener in main.dart
    Navigator.of(context).pop();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text(AppConstants.attentionTitle),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(AppConstants.confirmButton),
          ),
        ],
      ),
    );
  }

  void _clearForm() {
    _titleController.clear();
    _valueController.clear();
    setState(() {
      _isExpense = true;
    });
    _titleFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _valueController.dispose();
    _titleFocusNode.dispose();
    _valueFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TradeBloc, TradeState>(
      listener: (context, state) {
        // Handle success - form will be automatically closed by main.dart
        if (state is TradeOperationSuccess &&
            state.operationType == TradeOperationType.add) {
          // Success is already handled by main.dart BlocListener
        }

        // Handle errors
        if (state is TradeError) {
          _showErrorDialog(state.error.message);
        }
      },
      builder: (context, state) {
        final isLoading =
            state is TradeLoaded && state.isAddingTrade;

        return Padding(
          padding: EdgeInsets.only(
            bottom:
                MediaQuery.of(context).viewInsets.bottom +
                AppConstants.largePadding,
            left: AppConstants.largePadding,
            right: AppConstants.largePadding,
            top: AppConstants.largePadding,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppConstants.newTradeTitle,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: isLoading
                          ? null
                          : () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      tooltip: 'Fechar',
                    ),
                  ],
                ),
                SizedBox(height: AppConstants.largePadding),

                // Title Field
                TextFormField(
                  controller: _titleController,
                  focusNode: _titleFocusNode,
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    labelText: AppConstants.titleFieldLabel,
                    hintText: AppConstants.titleFieldHint,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: Icon(
                      _isExpense
                          ? Icons.shopping_cart
                          : Icons.account_balance_wallet,
                    ),
                    counterText: '${_titleController.text.length}/100',
                  ),
                  textInputAction: TextInputAction.next,
                  maxLength: AppConstants.maxTitleLength,
                  onChanged: (_) => setState(() {}), // Update counter
                  onFieldSubmitted: (_) => _valueFocusNode.requestFocus(),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppConstants.titleRequiredError;
                    }
                    if (value.trim().length > 100) {
                      return AppConstants.titleTooLongError;
                    }
                    return null;
                  },
                ),
                SizedBox(height: AppConstants.defaultPadding),

                // Value Field
                TextFormField(
                  controller: _valueController,
                  focusNode: _valueFocusNode,
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    labelText: AppConstants.valueFieldLabel,
                    hintText: AppConstants.valueFieldHint,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.monetization_on),
                    prefixText: AppConstants.currencyPrefix,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submitData(),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppConstants.valueRequiredError;
                    }
                    final doubleValue = double.tryParse(
                      value.replaceAll(',', '.'),
                    );
                    if (doubleValue == null) {
                      return AppConstants.valueInvalidError;
                    }
                    if (doubleValue <= 0) {
                      return AppConstants.valueZeroError;
                    }
                    if (doubleValue > AppConstants.maxTradeValue) {
                      return AppConstants.valueTooHighError;
                    }
                    return null;
                  },
                ),
                SizedBox(height: AppConstants.largePadding),

                // Trade Type Selection
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppConstants.tradeTypeLabel,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: AppConstants.smallPadding * 1.5),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: _isExpense
                                    ? Colors.red.shade50
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _isExpense
                                      ? Colors.red
                                      : Colors.grey.shade300,
                                ),
                              ),
                              child: RadioListTile<bool>(
                                title: Text(AppConstants.expenseLabel),
                                subtitle: Text(AppConstants.expenseSubtitle),
                                secondary: Icon(
                                  Icons.trending_down,
                                  color: _isExpense ? Colors.red : Colors.grey,
                                ),
                                value: true,
                                groupValue: _isExpense,
                                activeColor: Colors.red,
                                onChanged: isLoading
                                    ? null
                                    : (bool? value) {
                                        setState(() {
                                          _isExpense = value ?? true;
                                        });
                                      },
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: AppConstants.smallPadding),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: !_isExpense
                                    ? Colors.green.shade50
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: !_isExpense
                                      ? Colors.green
                                      : Colors.grey.shade300,
                                ),
                              ),
                              child: RadioListTile<bool>(
                                title: Text(AppConstants.incomeLabel),
                                subtitle: Text(AppConstants.incomeSubtitle),
                                secondary: Icon(
                                  Icons.trending_up,
                                  color: !_isExpense
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                                value: false,
                                groupValue: _isExpense,
                                activeColor: Colors.green,
                                onChanged: isLoading
                                    ? null
                                    : (bool? value) {
                                        setState(() {
                                          _isExpense = value ?? true;
                                        });
                                      },
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppConstants.largePadding * 1.2),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: isLoading ? null : _clearForm,
                        icon: const Icon(Icons.clear),
                        label: Text(AppConstants.clearButton),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: AppConstants.defaultPadding,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: AppConstants.defaultPadding),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isLoading
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: Text(AppConstants.cancelButton),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: AppConstants.defaultPadding,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: AppConstants.defaultPadding),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: isLoading ? null : _submitData,
                        icon: isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(Icons.save),
                        label: Text(
                          isLoading
                              ? AppConstants.savingButton
                              : AppConstants.saveButton,
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: _isExpense
                              ? Colors.red
                              : Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppConstants.smallPadding + 2),

                // Helper text
                if (state is TradeLoaded && state.hasTrades)
                  Padding(
                    padding: EdgeInsets.only(top: AppConstants.smallPadding),
                    child: Text(
                      'Saldo atual: R\$ ${state.currentBalance.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: state.currentBalance >= 0
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}