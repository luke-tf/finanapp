import 'package:flutter/material.dart';
import 'package:finanapp/utils/constants.dart';

class BalanceCard extends StatelessWidget {
  final double balance;

  const BalanceCard({super.key, required this.balance});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blueAccent,
      child: Padding(
        padding: EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppConstants.currentBalanceLabel,
              style: TextStyle(
                color: Colors.white,
                fontSize: AppConstants.balanceLabelFontSize,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'R\$ ${balance.toStringAsFixed(2)}',
              style: TextStyle(
                color: Colors.white,
                fontSize: AppConstants.balanceValueFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
