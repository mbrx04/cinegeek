import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_keys.dart'; 
import '../model/movie.dart'; 

class TmdbService {
  final String _baseUrl = 'https://api.themoviedb.org/3';

  //metodo privato che fa la chiamata vera e propria e restituisce la lista
  Future<List<Movie>> _getMovies(String endpoint) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    
    //aggiunge la chiave della key e specifica che la lingua deve essere italiano
    final finalUrl = url.replace(queryParameters: {
      'api_key': ApiKeys.tmdb,
      'language': 'it-IT',
      ...url.queryParameters,
    });

    try {
      final response = await http.get(finalUrl);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> results = data['results'];
        //si trasforma la lista in un oggetti movie
        return results.map((json) => Movie.fromJson(json)).toList();
      } else {
        print('Errore Server: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print("Errore Connessione: $e");
      return [];
    }
  }

  //"chiamate" per ogni tipo di lista che vogliamo
  Future<List<Movie>> getPopularMovies() async {
    return _getMovies('/movie/popular');
  }

  Future<List<Movie>> getTopRatedMovies() async {
    return _getMovies('/movie/top_rated');
  }
  
  Future<List<Movie>> getUpcomingMovies() async { //FORSE posso usarlo per mandare una notifica quando c'è una nuova uscita
    return _getMovies('/movie/upcoming');
  }

  //serve per una simulazione momentanea dei film visti e non votati in quanto non esiste ancora un db
  Future<List<Movie>> getWatchedMoviesPlaceholder() async {
    return _getMovies('/movie/now_playing');
  }

  //per la ricerca
  Future<List<Movie>> searchMovies(String query) async {
    if (query.isEmpty) return [];
    return _getMovies('/search/movie?query=$query');
  }

  //per i film da guardare
  Future<List<Movie>> getWatchlist(String username) async {
    return getWatchedMoviesPlaceholder();
  }

  //per i film piaciuti
  Future<List<Movie>> getLikedMovies(String username) async {
    return getPopularMovies();
  }
}