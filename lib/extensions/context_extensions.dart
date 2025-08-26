// context_extensions.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:finanapp/providers/transaction_provider.dart';

extension ContextExtensions on BuildContext {
  // Easy access to TransactionProvider
  TransactionProvider get transactions => read<TransactionProvider>();

  // Easy access to TransactionProvider for watching
  TransactionProvider get watchTransactions => watch<TransactionProvider>();

  // Helper methods for common theme access
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  // Helper method for showing snackbars
  void showSnackBar(String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
