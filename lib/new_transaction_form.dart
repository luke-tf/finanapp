// Updated new_transaction_form.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:finanapp/providers/transaction_provider.dart';

class NewTransactionForm extends StatefulWidget {
  final Function(String, double, bool) addTx;

  const NewTransactionForm(this.addTx, {super.key});

  @override
  State<NewTransactionForm> createState() => _NewTransactionFormState();
}

class _NewTransactionFormState extends State<NewTransactionForm> {
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

  void _submitData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final enteredTitle = _titleController.text.trim();
    final enteredValue = double.tryParse(
      _valueController.text.replaceAll(',', '.'),
    );

    if (enteredTitle.isEmpty || enteredValue == null || enteredValue <= 0) {
      _showErrorDialog('Por favor, preencha todos os campos corretamente');
      return;
    }

    // Call the callback function passed from parent
    widget.addTx(enteredTitle, enteredValue, _isExpense);
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
            Text('Atenção'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
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
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, child) {
        final isLoading = transactionProvider.isAddingTransaction;

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
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
                      'Nova Transação',
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
                const SizedBox(height: 20),

                // Title Field
                TextFormField(
                  controller: _titleController,
                  focusNode: _titleFocusNode,
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    labelText: 'Título *',
                    hintText: 'Ex: Compra no supermercado',
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
                  maxLength: 100,
                  onChanged: (_) => setState(() {}), // Update counter
                  onFieldSubmitted: (_) => _valueFocusNode.requestFocus(),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, insira um título';
                    }
                    if (value.trim().length > 100) {
                      return 'Título muito longo (máximo 100 caracteres)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Value Field
                TextFormField(
                  controller: _valueController,
                  focusNode: _valueFocusNode,
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    labelText: 'Valor (R\$) *',
                    hintText: '0,00',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.monetization_on),
                    prefixText: 'R\$ ',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submitData(),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, insira um valor';
                    }
                    final doubleValue = double.tryParse(
                      value.replaceAll(',', '.'),
                    );
                    if (doubleValue == null) {
                      return 'Por favor, insira um valor numérico válido';
                    }
                    if (doubleValue <= 0) {
                      return 'O valor deve ser maior que zero';
                    }
                    if (doubleValue > 999999999.99) {
                      return 'Valor muito alto';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Transaction Type Selection
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
                        'Tipo de transação:',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 12),
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
                                title: const Text('Despesa'),
                                subtitle: const Text('Saída de dinheiro'),
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
                          const SizedBox(width: 8),
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
                                title: const Text('Receita'),
                                subtitle: const Text('Entrada de dinheiro'),
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
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: isLoading ? null : _clearForm,
                        icon: const Icon(Icons.clear),
                        label: const Text('Limpar'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isLoading
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: const Text('Cancelar'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
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
                        label: Text(isLoading ? 'Salvando...' : 'Salvar'),
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
                const SizedBox(height: 10),

                // Helper text
                if (transactionProvider.hasTransactions)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Saldo atual: R\$ ${transactionProvider.currentBalance.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: transactionProvider.currentBalance >= 0
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
