import 'package:flutter/material.dart';
import '../widgets/rating.dart';
import '../widgets/circle_button.dart';

class MovieDetailPage extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String description;
  final double voteAverage;
  final String heroTag;
  final bool isPopup;

  const MovieDetailPage({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.voteAverage, 
    required this.heroTag,
    this.isPopup = false,
  });

  @override
  Widget build(BuildContext context) {
    double imageWidth = isPopup ? 200 : 250;
    double imageHeight = isPopup ? 300 : 350;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface, //sfondo material da mettere in tutte le pagine
      body: Stack(
        children: [
          //contenuto vero e proprio
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 80), //abbassa tutto il resto della pagina ma non la X per non farli sovrapporre
                //copertina centrata
                Hero(
                  tag: heroTag, //tag identico alla MovieCard
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      imageUrl,
                      width: imageWidth,
                      height: imageHeight,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                //titolo centrato come la copertina
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                //indicatore del punteggio
                RatingCircle(
                  voteAverage: voteAverage,
                  size: 70,
                ),
                const SizedBox(height: 20),
                //descrizione sempre centrata
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.4,
                      color: Colors.white70,
                    ),
                  ),
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),

          //tasto X per chiudere la schermata
          Positioned(
          top: 36,
          left: 20,
          child: CircleButton(
            icon: Icons.close,
            onTap: () => Navigator.pop(context),
          ),
        ),
        if (!isPopup)
          //tasto per scrivere la recensione
          Positioned(
          bottom: 16,
          right: 16,
          child: CircleButton(
            icon: Icons.edit,
            onTap: () => print("Scrivi recensione"),
          ),
        ),
        ],
      ),
    );
  }
}
