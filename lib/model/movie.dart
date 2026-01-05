//con questo file movie definiamo il modello dei dati per ogni singolo film e fa capire all'app come
//è fatto un film
class Movie {
  final int id;
  final String title;
  final String posterPath;
  final String overview;
  final double voteAverage;
  final String releaseDate;

  Movie({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.overview,
    required this.voteAverage,
    required this.releaseDate,
  });

  //converte il json che arriva da internet in un oggetto movie
  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Titolo sconosciuto',
      posterPath: json['poster_path'] ?? '',
      overview: json['overview'] ?? 'Nessuna descrizione disponibile.',
      //per i decimali
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      releaseDate: json['release_date'] ?? '',
    );
  }

  //serve per ottenere url competo della foto
  String get fullPosterUrl {
    if (posterPath.isEmpty) {
      return 'https://via.placeholder.com/500x750?text=No+Image';
    }
    return 'https://image.tmdb.org/t/p/w500$posterPath';
  }
}