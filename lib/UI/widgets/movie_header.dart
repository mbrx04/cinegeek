import 'package:flutter/material.dart';
import '../../model/movie.dart';
import '../pages/movie_detail.dart';

class MovieHeader extends StatelessWidget {
  final Movie movie;

  const MovieHeader({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MovieDetailPage(
              movieId: movie.id,
              title: movie.title,
              imageUrl: movie.fullPosterUrl,
              description: movie.overview,
              voteAverage: movie.voteAverage,
              heroTag: 'hero_featured_${movie.id}',
            ),
          ),
        );
      },
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          //copertina nello sfondo gigante
          Hero(
            tag: 'hero_featured_${movie.id}',
            child: Container(
              height: 600, //dimensione della copertina
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(movie.fullPosterUrl),
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
          ),

          //sfumatura nera o bianca inn base al tema
          Container(
            height: 600,  //altezza sfumatura
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.0),
                  Colors.black.withOpacity(0.8),
                  Theme.of(context).scaffoldBackgroundColor,
                ],
                stops: const [0.0, 0.5, 0.85, 1.0],
              ),
            ),
          ),

          //info sul film
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Film in evidenza",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  movie.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontSize: 36, 
                    height: 1.0,
                    shadows: [
                      const Shadow(blurRadius: 10, color: Colors.black, offset: Offset(0, 2))
                    ]
                  ),
                ),
                const SizedBox(height: 16),
                //tasto dettagli
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.info_outline, color: Colors.white),
                      SizedBox(width: 8),
                      Text("Dettagli", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}