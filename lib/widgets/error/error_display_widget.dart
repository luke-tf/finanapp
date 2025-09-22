import 'package:flutter/material.dart';
import 'package:finanapp/services/error_handler.dart';
import 'package:finanapp/utils/constants.dart';

class ErrorDisplayWidget extends StatelessWidget {
  final AppError error;
  final VoidCallback onRetry;

  const ErrorDisplayWidget({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
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
