import 'package:flutter/material.dart';
import 'package:cinegeek/services/auth_service.dart';
import 'package:cinegeek/model/app_user.dart';
import '../../model/movie.dart';
import '../../services/firestore_service.dart';
import '../widgets/circle_button.dart';
import '../widgets/top_bar.dart';
import 'movie_detail.dart';

class UserViewPage extends StatefulWidget
{
  final String userId;
  final String userName;

  const UserViewPage({super.key, required this.userId,required this.userName});

  @override
  State<UserViewPage> createState() => _UserViewPageState();
}

class _UserViewPageState extends State<UserViewPage>
{
  final AuthService _authService=AuthService();
  final FirestoreService _firestoreService=FirestoreService();
  late Future<List<Movie>> _watchedFuture;
  late Future<AppUser?> _userFuture;
  
  @override
  void initState()
  {
    super.initState();
    _userFuture = _authService.searchUser(widget.userName);
    _watchedFuture = _firestoreService.getWatched(widget.userId);
  }


  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final navigator=Navigator.of(context);

    return Scaffold
    (
      body:
      Column
      (
        children:
        [
          Row
            (
              children:
              [
                SizedBox(width: 40, height: 40, child: CircleButton(icon: Icons.arrow_back, onTap: () => navigator.pop(),),),
                Expanded(child: Align(alignment: Alignment.center,child: const TopBarLogo())),
                const SizedBox(width: 40)
              ]
          ),

          Text("I Film Visti da ${widget.userName}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.2),),

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
        ],
      ),
    );
  }
}
