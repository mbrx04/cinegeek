import 'package:flutter/material.dart';

class SelectedMovieCard extends StatelessWidget {
  final String title;
  final String imageUrl;

  const SelectedMovieCard({
    super.key,
    required this.title,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    //controllo tema chiaro e scuro
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        children: [
          //container che contiene l'immagine
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black.withAlpha(100) : Colors.black.withAlpha(40),
                  blurRadius: 15,
                  spreadRadius: 2,
                )
              ],
            ),
            child: ClipRRect( //arrotondamento angoli immagine
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                imageUrl,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.movie, size: 50),  //se non si carica la copertina viene postrata un icona
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text( //titolo del film sotto la copertina
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}