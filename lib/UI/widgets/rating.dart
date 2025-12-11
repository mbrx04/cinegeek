import 'package:flutter/material.dart';
//contiene il widget che mostra il punteggio medio dei film nelle varie schermate
class RatingCircle extends StatelessWidget {
  final double voteAverage;
  final double size;

  const RatingCircle({
    super.key,
    required this.voteAverage,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (voteAverage / 10).clamp(0.0, 1.0);

    Color color;
    if (voteAverage >= 7) {
      color = Colors.greenAccent;
    } else if (voteAverage >= 5) {
      color = Colors.orangeAccent;
    } else {
      color = Colors.redAccent;
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: percent,
            strokeWidth: 6,
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          Center(
            child: Text(
              voteAverage.toStringAsFixed(1),
              style: TextStyle(
                fontSize: size * 0.28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }
}
