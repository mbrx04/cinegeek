import 'package:flutter/material.dart';
import 'movie_card.dart';
import '../pages/movie_detail.dart';
import 'movie_preview_popup.dart';

//in questo file viene implementato il carosello con le copertine da scorrere
//orizzontalmente in stile app di streaming

class MovieCarousel extends StatelessWidget {
  final String title; //titolo della sezione
  final List<Map<String, dynamic>> movies; //puo contenere più tipi di dati con dynamic

  const MovieCarousel({
    super.key,
    required this.title,  //titolo obbligatorio
    required this.movies, //lista obbligatoria
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, //allinea tutto a sx
      children: [
        //titolo della sezione
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),  //margine orizzontale
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 12), //spazio tra titolo e carosello

        //lista orizzontale dei film
        SizedBox(
          height: 260, //altezza fissa per la card e titolo
          child: ListView.builder(
            scrollDirection: Axis.horizontal, //scorrimento orizzontale
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0), //spazio tra le card
                child: MovieCard(
                  imageUrl: movie['imageUrl']!,
                  title: movie['title']!,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MovieDetailPage(
                          title: movie['title'],
                          imageUrl: movie['imageUrl'],
                          description: movie['description'] ?? "Nessuna descrizione disponibile ancora",
                          voteAverage: movie['voteAverage']?.toDouble() ?? 0.0,
                          heroTag: movie['imageUrl'],
                        ),
                      ),
                    );
                  },
                  onLongPress: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                      builder: (_) => MovieDetailPage(
                        title: movie['title']!,
                        imageUrl: movie['imageUrl']!,
                        description: movie['description'] ?? "Nessuna descrizione disponibile",
                        voteAverage: movie['voteAverage']?.toDouble() ?? 0.0,
                        heroTag: movie['imageUrl']!,
                      ),
                    ),
                    );
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