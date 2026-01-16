import 'package:cinegeek/model/movie.dart';
import 'package:cinegeek/services/tmdb_service.dart';
import 'package:flutter/material.dart';

enum MovieCollectionType {
  watchlist,
  liked,
}

class MovieGridPage extends StatefulWidget {
  final String username;
  final String title;
  final MovieCollectionType type;

  const MovieGridPage({
    super.key,
    required this.username,
    required this.title,
    required this.type,
  });

  @override
  State<MovieGridPage> createState() => _MovieGridPageState();
}

class _MovieGridPageState extends State<MovieGridPage> {
  late Future<List<Movie>> _moviesFuture;
  final TmdbService _tmdbService = TmdbService();

  @override
  void initState() {
    super.initState();
    _moviesFuture = _loadMovies();
  }

  Future<List<Movie>> _loadMovies() {
    switch (widget.type) {
      case MovieCollectionType.watchlist:
        return _tmdbService.getWatchlist(widget.username);
      case MovieCollectionType.liked:
        return _tmdbService.getLikedMovies(widget.username);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: SizedBox(
                height: 48,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Text(
                            widget.username,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Movie>>(
                future: _moviesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text("Errore caricamento dati"));
                  }
                  final movies = snapshot.data ?? [];
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.66,
                    ),
                    itemCount: movies.length,
                    itemBuilder: (context, index) {
                      final movie = movies[index];
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          movie.fullPosterUrl,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
