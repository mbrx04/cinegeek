import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_keys.dart'; // Importa la tua chiave locale

class TmdbService {
  final String _baseUrl = 'https://api.themoviedb.org/3';

  Future<List<dynamic>> fetchPopularMovies() async {
    final url = Uri.parse('$_baseUrl/movie/popular?api_key=${ApiKeys.tmdb}&language=it-IT');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['results'];
    } else {
      throw Exception('Errore nel caricamento dei film: ${response.statusCode}');
    }
  }
}
