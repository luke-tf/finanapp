// error_handler.dart

import 'package:flutter/material.dart';

enum ErrorType { validation, database, network, unknown }

class AppError {
  final String message;
  final String? details;
  final ErrorType type;
  final String? code;

  const AppError({
    required this.message,
    this.details,
    required this.type,
    this.code,
  });

  @override
  String toString() => message;
}

class ErrorHandler {
  // Convert generic exceptions to user-friendly AppErrors
  static AppError handleException(dynamic exception) {
    if (exception is AppError) {
      return exception;
    }

    final String errorMessage = exception.toString().toLowerCase();

    // Database errors
    if (errorMessage.contains('database') ||
        errorMessage.contains('hive') ||
        errorMessage.contains('box')) {
      return AppError(
        message: 'Erro no banco de dados. Tente novamente.',
        details: exception.toString(),
        type: ErrorType.database,
      );
    }

    // Validation errors
    if (errorMessage.contains('título') ||
        errorMessage.contains('valor') ||
        errorMessage.contains('vazio') ||
        errorMessage.contains('válido')) {
      return AppError(
        message: exception.toString(),
        type: ErrorType.validation,
      );
    }

    // Network errors
    if (errorMessage.contains('network') ||
        errorMessage.contains('internet') ||
        errorMessage.contains('connection')) {
      return AppError(
        message: 'Erro de conexão. Verifique sua internet.',
        details: exception.toString(),
        type: ErrorType.network,
      );
    }

    // Unknown errors
    return AppError(
      message: 'Algo deu errado. Tente novamente.',
      details: exception.toString(),
      type: ErrorType.unknown,
    );
  }

  // Show error snackbar with appropriate styling
  static void showErrorSnackBar(
    BuildContext context,
    AppError error, {
    Duration duration = const Duration(seconds: 4),
  }) {
    if (!context.mounted) return;

    final color = _getErrorColor(error.type);
    final icon = _getErrorIcon(error.type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                error.message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        action: error.type == ErrorType.validation
            ? null
            : SnackBarAction(
                label: 'Detalhes',
                textColor: Colors.white,
                onPressed: () => _showErrorDetails(context, error),
              ),
      ),
    );
  }

  // Show success snackbar
  static void showSuccessSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // Show error dialog for critical errors
  static Future<void> showErrorDialog(
    BuildContext context,
    AppError error, {
    VoidCallback? onRetry,
  }) async {
    if (!context.mounted) return;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(
                _getErrorIcon(error.type),
                color: _getErrorColor(error.type),
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text('Erro'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(error.message),
              if (error.details != null) ...[
                const SizedBox(height: 16),
                ExpansionTile(
                  title: const Text('Detalhes técnicos'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        error.details!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          actions: [
            if (onRetry != null)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onRetry();
                },
                child: const Text('Tentar Novamente'),
              ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Private helper methods
  static Color _getErrorColor(ErrorType type) {
    switch (type) {
      case ErrorType.validation:
        return Colors.orange;
      case ErrorType.database:
        return Colors.red;
      case ErrorType.network:
        return Colors.blue;
      case ErrorType.unknown:
        return Colors.grey;
    }
  }

  static IconData _getErrorIcon(ErrorType type) {
    switch (type) {
      case ErrorType.validation:
        return Icons.warning;
      case ErrorType.database:
        return Icons.storage;
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.unknown:
        return Icons.error;
    }
  }

  static void _showErrorDetails(BuildContext context, AppError error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detalhes do Erro'),
        content: SingleChildScrollView(
          child: Text(
            error.details ?? 'Nenhum detalhe disponível',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}
