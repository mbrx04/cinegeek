import 'package:flutter/material.dart';
import '../../model/movie.dart';
import '../../services/tmdb_service.dart';
import '../../services/weekend_context_manager.dart';
import '../widgets/top_bar.dart';
import '../widgets/movie_carousel.dart';
import '../widgets/cineGlassButton.dart';
import 'LogInSignUp/auth_landing_page.dart';
import '../theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final WeekendContextManager _weekendManager = WeekendContextManager();

  final TmdbService _tmdbService = TmdbService();

  late Future<List<Movie>> _watchedMovies;
  late Future<List<Movie>> _popularMovies;
  late Future<List<Movie>> _topRatedMovies;
  late Future<List<Movie>> _upcomingMovies; //FORSE si puo usare per mandare notifiche prima dell'uscita dei fil

  //cominciano le richieste appena si entra nella home
  @override
  void initState(){
    super.initState();

    _weekendManager.init();

    //PER LA SIMULAZIONE DEI VISTI E NO VOTATI
    _watchedMovies = _tmdbService.getWatchedMoviesPlaceholder();

    _popularMovies = _tmdbService.getPopularMovies();
    _topRatedMovies = _tmdbService.getTopRatedMovies();
    _upcomingMovies = _tmdbService.getUpcomingMovies();
  }                  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TopBarLogo(),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                children: [
                  
                  //visti e non votati ma per ora c'è collegato 
                  _buildCarouselSection("Visti e non votati", _watchedMovies, "hero_watched"),

                  //popolari in generale
                  _buildCarouselSection("Popolari", _popularMovies, "hero_top"),

                  //più votati in generale
                  _buildCarouselSection("Più votati", _topRatedMovies, "hero_top"),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  //evita di ripetere il builder 3 volte
  Widget _buildCarouselSection(String title, Future<List<Movie>> future, String tagPrefix) {
    return FutureBuilder<List<Movie>>(
      future: future,
      builder: (context, snapshot) {
        //controlla se sta caricando
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: 300,
            child: Center( 
              child: CircularProgressIndicator(
                // Theme.of(context) non è costante, quindi il genitore non può essere const
                color: Theme.of(context).iconTheme.color, 
              ),
            ),          );
        } 
        //controlla se c'è errore
        else if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text("Errore: ${snapshot.error}", style: const TextStyle(color: Colors.red)),
          );
        } 
        //controlla se dati sono vuoti
        else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        //mostra il carosello
        return MovieCarousel(
          title: title,
          movies: snapshot.data!,
          heroTagPrefix: tagPrefix,
        );
      },
    );
  }
}