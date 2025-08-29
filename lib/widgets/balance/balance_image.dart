import 'package:flutter/material.dart';
import 'package:finanapp/utils/constants.dart';

class BalanceImage extends StatelessWidget {
  final String imagePath;

  const BalanceImage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppConstants.getBalanceImageHeight(context),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
