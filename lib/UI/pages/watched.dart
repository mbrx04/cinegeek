import 'package:cinegeek/services/firestore_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../model/movie.dart';
import '../../services/auth_service.dart';
import '../widgets/circle_button.dart';
import '../widgets/top_bar.dart';
import 'movie_detail.dart';

class WatchedPage extends StatefulWidget
{
  const WatchedPage({super.key});

  @override
  State<WatchedPage> createState() => _WatchedPageState();
}
class _WatchedPageState extends State<WatchedPage>
{
  final AuthService _authService=AuthService();
  final FirestoreService _firestoreService=FirestoreService();
  late Future<List<Movie>> _watchedFuture;

  @override
  void initState()
  {
    super.initState();
    _watchedFuture = _loadWatchedMovies();
  }

  Future<List<Movie>> _loadWatchedMovies() async
  {
    final user = await _authService.getCurrentUser();
    return _firestoreService.getWatched(user!.uid);
  }

  @override
  Widget build(BuildContext context)
  {
    final navigator= Navigator.of(context);

    return Scaffold
      (
        body:
        Column
        (
          mainAxisAlignment: MainAxisAlignment.center,
          children:
          [
            Row
            (
              children:
              [
                SizedBox(width: 40, height: 40, child: CircleButton(icon: Icons.arrow_back, onTap: () => navigator.pop(),),),
                Expanded(child: Align(alignment: Alignment.center, child: const TopBarLogo())),
                const SizedBox(width: 40)
              ]
            ),
            const SizedBox(height: 10),

            const Text("I TUOI VISTI", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.2),),

            const SizedBox(height: 20),

            Expanded
            (
              child: FutureBuilder<List<Movie>>
              (
                future: _watchedFuture,
                builder: (context, snapshot)
                {
                  if (snapshot.connectionState == ConnectionState.waiting)
                  {
                    return const Center(child: CircularProgressIndicator(color: Color.fromARGB(255, 204, 255, 0)));
                  }

                  if (snapshot.hasError)
                  {
                    return Center(child: Text("Errore: ${snapshot.error}"));
                  }

                  final movies = snapshot.data ?? [];

                  if (movies.isEmpty)
                  {
                    return const Center(child: Text("La tua lista è vuota", style: TextStyle(color: Colors.white54)),);
                  }

                  return GridView.builder
                  (
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12,childAspectRatio: 0.66),
                    itemCount: movies.length,
                    itemBuilder: (context, index)
                    {
                      final movie = movies[index];
                      final String heroTag = 'watched_${movie.id}';
                      return GestureDetector
                      (
                        onTap: ()
                        {
                          navigator.push(MaterialPageRoute(builder: (_) => MovieDetailPage(movieId: movie.id,title: movie.title, imageUrl: movie.fullPosterUrl, description: movie.overview, voteAverage: movie.voteAverage, heroTag: heroTag,)));
                        },
                        child:
                        Hero
                        (
                          tag: heroTag,
                          child:
                          ClipRRect
                          (
                            borderRadius: BorderRadius.circular(12),
                            child:
                            movie.fullPosterUrl.isNotEmpty
                            ? Image.network(movie.fullPosterUrl, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[800], child: const Icon(Icons.broken_image, color: Colors.white54)),)
                            : Container(color: Colors.grey[800], child: const Icon(Icons.movie, color: Colors.white54)),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ]
        )
    );
  }
}