
/* Classe che rappresenta un singolo film */
class Movie{
  final int id;
  final String title;
  final String posterPath;


  Movie({
    required this.id,
    required this.title,
    required this.posterPath,
  });

  String get fullPosterUrl  =>
      'https://image.tmdb.org/t/p/w500$posterPath';
}