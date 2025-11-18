import 'package:flutter/material.dart';

class SoloTesto extends StatelessWidget {
  final double width;
  final double height;

  const SoloTesto({
    super.key,
    this.width = 160,
    this.height = 160,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/solo_testo.png',
      width: width,
      height: height,
      fit: BoxFit.contain,
    );
  }
}
