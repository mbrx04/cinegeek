import 'package:flutter/material.dart';
import 'movie_card.dart';

//in questo file viene implementato il carosello con le copertine da scorrere
//orizzontalmente in stile app di streaming
//movie_carousel accetta una lista di film in formato: [{'title': '...', 'imageUrl': '...'}, ...]
//parametri:
//title: testo sopra il carosello
//movies: lista di film
class MovieCarousel extends StatelessWidget {
  final String title;
  final List<Map<String, String>> movies; //formato: [{'title': '...', 'imageUrl': '...'}, ...]

  const MovieCarousel({
    super.key,
    required this.title,
    required this.movies,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //titolo della sezione
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 12),

        //vera lista orizzontale dei film
        SizedBox(
          height: 260, //altezza fissa per la card e titolo
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: MovieCard(
                  imageUrl: movie['imageUrl']!,
                  title: movie['title']!,
                  onTap: () {
                    print("Hai cliccato: ${movie['title']}");
                  },
                  onLongPress: () {
                    print("Long press su: ${movie['title']}");
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
