import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Keep if you use it, though not directly for editing in this snippet
import 'package:finanapp/models/transaction.dart';
import 'package:finanapp/providers/transaction_provider.dart';
import 'package:finanapp/utils/constants.dart';
import 'package:finanapp/services/error_handler.dart'; // Import ErrorHandler

class EditTransactionScreen extends StatefulWidget {
  final Transaction transaction;
  const EditTransactionScreen({super.key, required this.transaction});

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _valueController;
  late bool _isExpense;
  late DateTime
  _selectedDate; // You're not using this yet, but it's good to keep if you plan to add date editing

  bool _isSaving = false; // Add a state variable for saving

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.transaction.title);
    _valueController = TextEditingController(
      text: widget.transaction.value.toStringAsFixed(2),
    );
    _isExpense = widget.transaction.isExpense;
    _selectedDate = widget.transaction.date; // Initialize with existing date
  }

  @override
  void dispose() {
    _titleController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  void _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true; // Set saving state to true
    });

    final enteredTitle = _titleController.text.trim();
    final enteredValue = double.tryParse(
      _valueController.text.replaceAll(',', '.'),
    );

    if (enteredTitle.isEmpty || enteredValue == null || enteredValue <= 0) {
      _showErrorDialog(AppConstants.fillAllFieldsError);
      setState(() {
        _isSaving = false; // Reset saving state
      });
      return;
    }

    // CORRECTED: Update the properties of the *existing* widget.transaction object
    // directly. Hive will then use its key to find and update it in the box.
    widget.transaction.title = enteredTitle;
    widget.transaction.value = enteredValue;
    widget.transaction.isExpense = _isExpense;
    widget.transaction.date =
        _selectedDate; // Update the date as well, even if not editing it yet

    final provider = context.read<TransactionProvider>();
    final success = await provider.updateTransaction(
      widget.transaction,
    ); // Pass the modified existing object

    if (mounted) {
      setState(() {
        _isSaving = false; // Reset saving state
      });

      if (success) {
        ErrorHandler.showSuccessSnackBar(
          context,
          'Transação atualizada com sucesso!', // You might want to add this to AppConstants
        );
        Navigator.of(context).pop();
      } else {
        if (provider.error != null) {
          ErrorHandler.showErrorSnackBar(context, provider.error!);
          provider.clearError();
        } else {
          _showErrorDialog('Falha ao atualizar a transação.');
        }
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.orange),
            const SizedBox(width: 8),
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

  // You might want to add a date picker functionality here later
  // void _presentDatePicker() {
  //   showDatePicker(
  //     context: context,
  //     initialDate: _selectedDate,
  //     firstDate: DateTime(2020),
  //     lastDate: DateTime.now(),
  //   ).then((pickedDate) {
  //     if (pickedDate == null) {
  //       return;
  //     }
  //     setState(() {
  //       _selectedDate = pickedDate;
  //     });
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Editar Transação'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        // Wrap with SingleChildScrollView to prevent overflow
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.all(AppConstants.getResponsivePadding(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadius,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(AppConstants.defaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informações da Transação',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                              ),
                        ),
                        SizedBox(height: AppConstants.defaultPadding),
                        TextFormField(
                          controller: _titleController,
                          enabled: !_isSaving, // Disable when saving
                          decoration: InputDecoration(
                            labelText: AppConstants.titleFieldLabel,
                            hintText: AppConstants.titleFieldHint,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppConstants.borderRadius,
                              ),
                            ),
                            prefixIcon: Icon(
                              _isExpense
                                  ? Icons.shopping_cart
                                  : Icons.account_balance_wallet,
                            ),
                          ),
                          maxLength: AppConstants.maxTitleLength,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return AppConstants.titleRequiredError;
                            }
                            if (value.trim().length >
                                AppConstants.maxTitleLength) {
                              return AppConstants.titleTooLongError;
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: AppConstants.defaultPadding),
                        TextFormField(
                          controller: _valueController,
                          enabled: !_isSaving, // Disable when saving
                          decoration: InputDecoration(
                            labelText: AppConstants.valueFieldLabel,
                            hintText: AppConstants.valueFieldHint,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppConstants.borderRadius,
                              ),
                            ),
                            prefixIcon: const Icon(Icons.monetization_on),
                            prefixText: AppConstants.currencyPrefix,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
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
                            if (doubleValue >
                                AppConstants.maxTransactionValue) {
                              return AppConstants.valueTooHighError;
                            }
                            return null;
                          },
                        ),
                        // If you add date picking, add it here
                        // SizedBox(height: AppConstants.defaultPadding),
                        // Row(
                        //   children: [
                        //     Expanded(
                        //       child: Text(
                        //         'Data Selecionada: ${DateFormat(AppConstants.dateFormat).format(_selectedDate)}',
                        //       ),
                        //     ),
                        //     TextButton(
                        //       onPressed: _isSaving ? null : _presentDatePicker,
                        //       child: const Text('Selecionar Data'),
                        //     ),
                        //   ],
                        // ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: AppConstants.defaultPadding),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadius,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(AppConstants.defaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppConstants.transactionTypeLabel,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: AppConstants.smallPadding),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: _isSaving
                                    ? null
                                    : () => setState(() => _isExpense = true),
                                child: Container(
                                  padding: EdgeInsets.all(
                                    AppConstants.defaultPadding,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _isExpense
                                        ? Colors.red.shade100
                                        : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(
                                      AppConstants.borderRadius,
                                    ),
                                    border: Border.all(
                                      color: _isExpense
                                          ? Colors.red
                                          : Colors.grey.shade300,
                                      width: 2,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.trending_down,
                                        color: _isExpense
                                            ? Colors.red
                                            : Colors.grey,
                                        size: 32,
                                      ),
                                      SizedBox(
                                        height: AppConstants.smallPadding,
                                      ),
                                      Text(
                                        AppConstants.expenseLabel,
                                        style: TextStyle(
                                          color: _isExpense
                                              ? Colors.red
                                              : Colors.grey,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        AppConstants.expenseSubtitle,
                                        style: TextStyle(
                                          color: _isExpense
                                              ? Colors.red.shade700
                                              : Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: AppConstants.defaultPadding),
                            Expanded(
                              child: GestureDetector(
                                onTap: _isSaving
                                    ? null
                                    : () => setState(() => _isExpense = false),
                                child: Container(
                                  padding: EdgeInsets.all(
                                    AppConstants.defaultPadding,
                                  ),
                                  decoration: BoxDecoration(
                                    color: !_isExpense
                                        ? Colors.green.shade100
                                        : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(
                                      AppConstants.borderRadius,
                                    ),
                                    border: Border.all(
                                      color: !_isExpense
                                          ? Colors.green
                                          : Colors.grey.shade300,
                                      width: 2,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.trending_up,
                                        color: !_isExpense
                                            ? Colors.green
                                            : Colors.grey,
                                        size: 32,
                                      ),
                                      SizedBox(
                                        height: AppConstants.smallPadding,
                                      ),
                                      Text(
                                        AppConstants.incomeLabel,
                                        style: TextStyle(
                                          color: !_isExpense
                                              ? Colors.green
                                              : Colors.grey,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        AppConstants.incomeSubtitle,
                                        style: TextStyle(
                                          color: !_isExpense
                                              ? Colors.green.shade700
                                              : Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: AppConstants.defaultPadding), // Add some space
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSaving
                            ? null
                            : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: AppConstants.defaultPadding,
                          ),
                        ),
                        child: Text(AppConstants.cancelButton),
                      ),
                    ),
                    SizedBox(width: AppConstants.defaultPadding),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _saveChanges,
                        icon: _isSaving
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
                          _isSaving
                              ? AppConstants.savingButton
                              : AppConstants.saveButton,
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: AppConstants.defaultPadding,
                          ),
                          backgroundColor: _isExpense
                              ? Colors.red
                              : Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppConstants.defaultPadding),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
