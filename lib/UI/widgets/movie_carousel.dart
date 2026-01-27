import 'package:flutter/material.dart';
import '../../model/movie.dart';
import '../pages/movie_detail.dart';
import '../widgets/movie_preview_popup.dart';

class MovieCarousel extends StatelessWidget {
  final String title;
  final List<Movie> movies;
  final String heroTagPrefix;

  const MovieCarousel({
    super.key,
    required this.title,
    required this.movies,
    required this.heroTagPrefix,
  });

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty){
      return const SizedBox.shrink(); //se non ci sono film non mostra nulla
    }
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
              final String heroTag = '${heroTagPrefix}_${movie.id}';

              return GestureDetector(
                onTap: () { //tap normale
                  //navigazione a detail page con animaizone hero
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MovieDetailPage(
                        movieId: movie.id,
                        title: movie.title,
                        imageUrl: movie.fullPosterUrl,
                        description: movie.overview,
                        voteAverage: movie.voteAverage,
                        heroTag: heroTag,
                      ),
                    ),
                  );
                },

                //apertura popup
                onLongPress: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      opaque: false,
                      barrierDismissible: true,
                      barrierColor: Colors.black54,
                      pageBuilder: (BuildContext context, _, __) {
                        return MoviePreviewPopup(
                          imageUrl: movie.fullPosterUrl,
                          title: movie.title,
                          description: movie.overview,
                          heroTag: heroTag,
                        );
                      },
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
                              movie.fullPosterUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey[800],
                                child: const Icon(Icons.broken_image, color:Colors.white54),
                              )
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      //titolo sotto la locandina nel carosello
                      
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