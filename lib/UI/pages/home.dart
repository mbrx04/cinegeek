import 'package:flutter/material.dart';
import '../../model/movie.dart';
import '../../services/tmdb_service.dart';
import '../../services/weekend_context_manager.dart';
import '../widgets/top_bar.dart';
import '../widgets/movie_carousel.dart';
import '../widgets/movie_header.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final WeekendContextManager _weekendManager = WeekendContextManager();
  final TmdbService _tmdbService = TmdbService();
  final FirestoreService _firestoreService = FirestoreService();

  late Future<List<Movie>> _watchedNotReviewedMovies;
  late Future<List<Movie>> _popularMovies;
  late Future<List<Movie>> _topRatedMovies;

  @override
  void initState(){
    super.initState();
    _weekendManager.init();
    _loadData();
  }           

  void _loadData(){
    final user = FirebaseAuth.instance.currentUser;

    //visti e non votati
    if (user != null) {
      _watchedNotReviewedMovies = _firestoreService.getWatchedNotReviewedMovies(user.uid);
    } else {
      _watchedNotReviewedMovies = Future.value([]); 
    }

    //carica dati da tmdb
    _popularMovies = _tmdbService.getPopularMovies();
    _topRatedMovies = _tmdbService.getTopRatedMovies();
  }

  Future<void> _refresh() async {
    setState(() {
      _loadData();
    });
  }       

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: Theme.of(context).colorScheme.primary,
        edgeOffset: 0,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 0, bottom: 100), 
          child: Column(
            children: [

              //sezione popolari con copertina enorme che contiene anche il logo della topbar
              _buildPopularSectionWithHeaderAndLogo(),

              const SizedBox(height: 25),

              //visti e non votati
              _buildStandardCarousel(
                "Visti e non votati", 
                _watchedNotReviewedMovies, 
                "hero_watched_real"
              ),

              //più votati
              _buildStandardCarousel(
                "Più votati", 
                _topRatedMovies, 
                "hero_top"
              ),

              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }

  //costruttore standard
  Widget _buildStandardCarousel(String title, Future<List<Movie>> future, String tagPrefix) {
    return FutureBuilder<List<Movie>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(height: 0); 
        } 
        else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        return MovieCarousel(
          title: title,
          movies: snapshot.data!,
          heroTagPrefix: tagPrefix,
        );
      },
    );
  }

  //costruttore con il logo
  Widget _buildPopularSectionWithHeaderAndLogo() {
    return FutureBuilder<List<Movie>>(
      future: _popularMovies,
      builder: (context, snapshot) {
        
        //caricamento stato
        if (snapshot.connectionState == ConnectionState.waiting) {
           return Stack(
             children: [
               Container(
                 height: 600,
                 width: double.infinity,
                 color: const Color(0xFF1F1F1F), 
               ),
               const SafeArea(child: TopBarLogo(height: 30)),
             ],
           );
        } 
        
        //errore e pagina vuota
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SafeArea(child: TopBarLogo(height: 30));
        }

        final movies = snapshot.data!;
        final featured = movies.first; 
        final others = movies.sublist(1); 

        //success
        return Stack(
          children: [
            //header gigante e carosello
            Column(
              children: [
                SizedBox(
                  height: 600, 
                  child: MovieHeader(movie: featured), 
                ),
                
                const SizedBox(height: 10),

                MovieCarousel(
                  title: "Popolari",
                  movies: others,
                  heroTagPrefix: "hero_pop", 
                ),
              ],
            ),

            //sfumatura in alto per leggere il logo
            Positioned(
              top: 0, left: 0, right: 0,
              height: 150,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            //logo che scorre
            const Positioned(
              top: 0, left: 0, right: 0,
                child: TopBarLogo(height: 25),
            ),
            //abbiamo praticamente la topbar sopra le altre cose e quindi la prima cosa della schermata parte da 0 px
          ],
        );
      },
    );
  }
}