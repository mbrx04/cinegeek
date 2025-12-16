import 'package:cinegeek/model/Movie.dart';

/* DA CAMBIARE: generata con AI per test */

/// Servizio FAKE per sviluppo e testing
/// Simula le risposte di TMDB
class FakeTmdbService {
  /// Watchlist finta
  Future<List<Movie>> fetchWatchlist(String username) async {
    await Future.delayed(const Duration(seconds: 1));

    return [
      Movie(
        id: 1,
        title: 'Dune',
        posterPath: '/d5NXSklXo0qyIYkgV94XAgMIckC.jpg',
      ),
      Movie(
        id: 2,
        title: 'Oppenheimer',
        posterPath: '/ptpr0kGAckfQkJeJIt8st5dglvd.jpg',
      ),
      Movie(
        id: 3,
        title: 'Blade Runner 2049',
        posterPath: '/gajva2L0rPYkEWjzgFlBXCAVBE5.jpg',
      ),
    ];
  }

  /// Likes finti
  Future<List<Movie>> fetchLikedMovies(String username) async {
    await Future.delayed(const Duration(seconds: 1));

    return [
      Movie(
        id: 4,
        title: 'Fight Club',
        posterPath: '/a26cQPRhJPX6GbWfQbvZdrrp9j9.jpg',
      ),
      Movie(
        id: 5,
        title: 'Interstellar',
        posterPath: '/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg',
      ),
    ];
  }
}