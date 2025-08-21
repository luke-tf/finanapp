import 'package:flutter/material.dart';

class BalanceImage extends StatelessWidget {
  final String imagePath;

  const BalanceImage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150, // Define uma altura fixa para a imagem
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
