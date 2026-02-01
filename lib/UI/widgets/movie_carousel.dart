import 'package:flutter/material.dart';
import '../../model/movie.dart';
import '../pages/movie_detail.dart';
import '../theme.dart';
import '../widgets/movie_preview_popup.dart';

class MovieCarousel extends StatelessWidget {
  final String title;
  final List<Movie> movies;
  final String heroTagPrefix;

  // Modifiche per renderlo selezionabile
  final int? selectedMovieId;
  final Function(Movie movie, String heroTag)? onCustomTap;
  final VoidCallback? onCheckConfirmTap;
  //

  const MovieCarousel({
    super.key,
    required this.title,
    required this.movies,
    required this.heroTagPrefix,

    // sempre per fare il carosello selezionabile
    this.selectedMovieId,
    this.onCustomTap,
    this.onCheckConfirmTap,
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

              // Verifico se questo specifico film è quello selezionato
              final bool isSelected = selectedMovieId == movie.id;

               return Container
               (
                  width: 150,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child:
                  Column
                  (
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                    [
                      Expanded
                      (
                        child:
                        Stack
                        (
                          clipBehavior: Clip.none,
                          children:
                          [
                            // Card Principale
                            GestureDetector
                            (
                              onTap: ()
                              {
                                if (onCustomTap != null)
                                {
                                  onCustomTap!(movie, heroTag);
                                }
                                else
                                {
                                  // Navigazione Standard
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
                                }
                              },

                              onLongPress: (){
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

                              child: AnimatedContainer
                              (
                                duration: const Duration(milliseconds: 200),
                                decoration:
                                BoxDecoration
                                (
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: isSelected ? AppTheme.primaryLime : Colors.transparent, width: 3,),
                                ),
                                child: Hero(
                                  tag: heroTag,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      movie.fullPosterUrl,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: Colors.grey[800],
                                        child: const Icon(Icons.broken_image, color: Colors.white54),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Spunta Verde
                            if (isSelected)
                              Positioned
                              ( bottom: -5, right: -5, child:
                                GestureDetector
                                (
                                  onTap: onCheckConfirmTap,
                                  child: Container(padding: const EdgeInsets.all(6),
                                    decoration:
                                    const BoxDecoration(color: AppTheme.primaryLime, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],),
                                    child: const Icon(Icons.check, color: Colors.white, size: 24),),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      //titolo sotto la locandina nel carosello
                      
                    ],
                  ),

              );
            }
          ),
        ),
      ],
    );
  }
}