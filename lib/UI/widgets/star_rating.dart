import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final bool isInteractive;
  final Function(double)? onRatingUpdate;
  final double itemSize;

  const StarRating({
    super.key,
    required this.rating,
    this.isInteractive = false, //se è false è solo visualizzazione
    this.onRatingUpdate,
    this.itemSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    if (isInteractive) {
      //modalità scrittura
      return RatingBar.builder(
        initialRating: rating,
        minRating: 1,
        direction: Axis.horizontal,
        allowHalfRating: false,
        itemCount: 5,
        itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
        itemBuilder: (context, _) => const Icon(
          Icons.star,
          color: Colors.amber,
        ),
        onRatingUpdate: onRatingUpdate!,
      );
    } else {
      //modalità lettura
      return RatingBarIndicator(
        rating: rating,
        itemBuilder: (context, index) => const Icon(
          Icons.star,
          color: Colors.amber,
        ),
        itemCount: 5,
        itemSize: itemSize,
        direction: Axis.horizontal,
      );
    }
  }
}