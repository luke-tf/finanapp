import 'package:flutter/material.dart';
import 'package:finanapp/utils/constants.dart';

class EmptyTradesWidget extends StatelessWidget {
  final VoidCallback onAddTrade;

  const EmptyTradesWidget({super.key, required this.onAddTrade});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: AppConstants.getResponsiveIconSize(context),
            color: Colors.grey.shade300,
          ),
          SizedBox(height: AppConstants.getResponsivePadding(context)),
          Text(
            AppConstants.noTradesTitle,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: AppConstants.smallPadding),
          Text(
            AppConstants.noTradesMessage,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade500),
          ),
          SizedBox(height: AppConstants.getResponsivePadding(context) * 1.5),
          ElevatedButton.icon(
            onPressed: onAddTrade,
            icon: const Icon(Icons.add),
            label: Text(AppConstants.firstTradeButton),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}