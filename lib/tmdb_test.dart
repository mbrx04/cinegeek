//questo file serve per verificare il corretto funzionamentjo delle API di TMDB.
//runnandolo mostra una lista di film o altro con il relativo punteggio
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
    const apiKey = 'b608d01980ef71a9f29b68e21c6f6575'; //QUI C'è LA KEY DELL'API
    const url =
        'https://api.themoviedb.org/3/movie/popular?api_key=$apiKey&language=it-IT&page=1';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        movies = data['results'];
        isLoading = false;
      });
    } else {
      throw Exception('Errore nel caricamento dei film');
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
