// new_transaction_form.dart

import 'package:flutter/material.dart';

class NewTransactionForm extends StatefulWidget {
  final Function addTx;

  const NewTransactionForm(this.addTx, {super.key});

  @override
  State<NewTransactionForm> createState() => _NewTransactionFormState();
}

class _NewTransactionFormState extends State<NewTransactionForm> {
  final _titleController = TextEditingController();
  final _valueController = TextEditingController();

  bool _isExpense = false;

  void _submitData() {
    final enteredTitle = _titleController.text;
    final enteredValue = double.tryParse(_valueController.text);

    // AQUI ESTÁ A CORREÇÃO para lidar com valores nulos
    if (enteredTitle.isEmpty || enteredValue == null || enteredValue <= 0) {
      return;
    }

    widget.addTx(enteredTitle, enteredValue, _isExpense);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: _valueController,
              decoration: const InputDecoration(labelText: 'Valor (R\$)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _isExpense,
                  onChanged: (bool? newValue) {
                    setState(() {
                      _isExpense = newValue ?? false;
                    });
                  },
                ),
                const Text('Despesa'),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
