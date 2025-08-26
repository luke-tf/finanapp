import 'package:flutter/material.dart';
import 'package:finanapp/widgets/balance/balance_card.dart';
import 'package:finanapp/widgets/balance/balance_image.dart';

class BalanceDisplay extends StatelessWidget {
  final double currentBalance;
  final Function getBalanceImagePath;

  const BalanceDisplay({
    super.key,
    required this.currentBalance,
    required this.getBalanceImagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BalanceImage(imagePath: getBalanceImagePath()),
        const SizedBox(height: 16),
        BalanceCard(balance: currentBalance),
      ],
    );
  }
}
