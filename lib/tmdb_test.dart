// Questa pagina serve solo per verificare il funzionamento delle API TMDB
// Mostra una lista di film popolari con immagini e punteggi

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../api_keys.dart';  // <-- Usa la key sicura

class TmdbTestPage extends StatefulWidget {
  const TmdbTestPage({super.key});

  @override
  State<TmdbTestPage> createState() => _TmdbTestPageState();
}

class _TmdbTestPageState extends State<TmdbTestPage> {
  List movies = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPopularMovies();
  }

  Future<void> fetchPopularMovies() async {
    final url = Uri.parse(
      'https://api.themoviedb.org/3/movie/popular?api_key=${ApiKeys.tmdb}&language=it-IT&page=1',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        movies = data['results'];
        isLoading = false;
      });
    } else {
      throw Exception('Errore nel caricamento dei film: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test TMDB'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final movie = movies[index];
                return ListTile(
                  leading: Image.network(
                    'https://image.tmdb.org/t/p/w200${movie['poster_path']}',
                    width: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(movie['title']),
                  subtitle: Text('Voto: ${movie['vote_average']}'),
                );
              },
            ),
    );
  }
}
