import 'package:flutter/material.dart';
import '../pages/movie_detail.dart';

class MovieCarousel extends StatelessWidget {
  final String title;
  final List<Map<String, String>> movies;
  final String heroTagPrefix;

  const MovieCarousel({
    super.key,
    required this.title,
    required this.movies,
    required this.heroTagPrefix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //titolo di ogni carosello
        Padding(
          padding: const EdgeInsets.only(left: 20, top: 20, bottom: 10),
          child: Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium, 
          ),
        ),

        //carosello orizzontale
        SizedBox(
          height: 300,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              //tag unico per l'animazione Hero
              final String heroTag = '${heroTagPrefix}_$index';

              return GestureDetector(
                onTap: () {
                  //navigazione a detail page con animaizone hero
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MovieDetailPage(
                        title: movie['title']!,
                        imageUrl: movie['imageUrl']!,
                        description: "Descrizione non disponibile per ora...",
                        voteAverage: 7.5, //voto fake perchè non ci sono le API
                        heroTag: heroTag,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 150, //larghezza locandina
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //locandina
                      Expanded(
                        child: Hero(
                          tag: heroTag,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              movie['imageUrl']!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              // Gestione errore immagine
                              errorBuilder: (ctx, error, stack) {
                                return Container(
                                  color: Colors.grey[800],
                                  child: const Center(
                                    child: Icon(Icons.broken_image, color: Colors.white54),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      //titolo sotto la locandina nel carosello
                      Text(
                        movie['title']!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}