// new_transaction_form.dart

import 'package:flutter/material.dart';

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

  bool _isExpense = true; // Inicia como despesa por padrão

  void _submitData() {
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

    widget.addTx(enteredTitle, enteredValue, _isExpense);
    Navigator.of(context).pop();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Erro'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            Text(
              'Nova Transação',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Título *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor, insira um título';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _valueController,
              decoration: InputDecoration(
                labelText: 'Valor (R\$) *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.monetization_on),
                hintText: '0,00',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submitData(),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor, insira um valor';
                }
                final doubleValue = double.tryParse(value.replaceAll(',', '.'));
                if (doubleValue == null || doubleValue <= 0) {
                  return 'Por favor, insira um valor válido maior que zero';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tipo de transação:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<bool>(
                          title: Text('Despesa'),
                          subtitle: Text('Saída de dinheiro'),
                          value: true,
                          groupValue: _isExpense,
                          onChanged: (bool? value) {
                            setState(() {
                              _isExpense = value ?? true;
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<bool>(
                          title: Text('Receita'),
                          subtitle: Text('Entrada de dinheiro'),
                          value: false,
                          groupValue: _isExpense,
                          onChanged: (bool? value) {
                            setState(() {
                              _isExpense = value ?? true;
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Cancelar'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submitData,
                    child: Text('Salvar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
