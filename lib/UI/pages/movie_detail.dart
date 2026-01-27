import 'package:cinegeek/UI/pages/write_review.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart';
import '../../model/movie.dart';
import '../widgets/circle_button.dart';
import '../widgets/rating.dart';
import '../widgets/movie_detail_action.dart';
import '../widgets/movie_description.dart';

class MovieDetailPage extends StatefulWidget {
  final int movieId; //id univoco del film per il DB
  final String title;
  final String imageUrl;
  final String description;
  final double voteAverage;
  final String heroTag;

  const MovieDetailPage({
    super.key,
    required this.movieId,
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.voteAverage,
    required this.heroTag,
  });

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {

  //instanzazione del db
  final FirestoreService _firestoreService = FirestoreService();
  
  //3 stati dei bottoni
  bool _isInWatchlist = false; 
  bool _isWatched = false;     
  bool _isLiked = false;       
  
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;  //uid dell'utente loggato per prendere i dati

  @override
  void initState() {  //appena si apre la pagina controlla se l'utente ha a che fare con il film in question
    super.initState();
    _initData();
  }

  //carica stato iniziale del db cioè se ho gia messo like, watched ec...
  void _initData() async {
    if (_uid == null) return;

    //3 chiamate in parallelo per essere più veloce
    final results = await Future.wait([
      _firestoreService.checkMovieInList(_uid!, 'watchlist', widget.movieId),
      _firestoreService.checkMovieInList(_uid!, 'watched', widget.movieId),
      _firestoreService.checkMovieInList(_uid!, 'liked', widget.movieId),
    ]);

    //aggiorna la grafica dei bottoni cioè se sono attivi o no
    if (mounted) {
      setState(() {
        _isInWatchlist = results[0];
        _isWatched = results[1];
        _isLiked = results[2];
      });
    }
  }

  //gestione watchlist
  void _handleWatchlist() async {
    if (_uid == null) return;
    
    //il service aggiunge e rimuove dal db il film dalla watchlist
    final newState = await _firestoreService.toggleMovieInList(
      uid: _uid!,
      collection: 'watchlist',
      movieId: widget.movieId,
      title: widget.title,
      imageUrl: widget.imageUrl,
      description: widget.description,
      voteAverage: widget.voteAverage,
    );
    
    if (mounted) setState(() => _isInWatchlist = newState); //aggiorna l'icona
  }

  //gestione watched
  void _handleWatched() async {
    if (_uid == null) return;

    //il service aggiunhe e rimuove dal db il film watched
    final newState = await _firestoreService.toggleMovieInList(
      uid: _uid!,
      collection: 'watched',
      movieId: widget.movieId,
      title: widget.title,
      imageUrl: widget.imageUrl,
      description: widget.description,
      voteAverage: widget.voteAverage,
    );

    //se il film è watched viene tolto dalla watchlist
    if (newState == true && _isInWatchlist) {
      await _firestoreService.removeMovieFromList(_uid!, 'watchlist', widget.movieId);
      if (mounted) setState(() => _isInWatchlist = false);
    }

    //se tolgo watched tolge anche like e recensione
    if (newState == false) {
       if (_isLiked) {
        await _firestoreService.removeMovieFromList(_uid!, 'liked', widget.movieId);
        if (mounted) setState(() => _isLiked = false);
      }
      
      await _firestoreService.deleteReview(_uid!, widget.movieId.toString()); //cancella la reecnsione dal db

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Film rimosso dai visti")),
        );
      }
    }

    if (mounted) setState(() => _isWatched = newState);
  }

  //gestione del like
  void _handleLiked() async {
    if (_uid == null) return;

    final newState = await _firestoreService.toggleMovieInList(
      uid: _uid!,
      collection: 'liked',
      movieId: widget.movieId,
      title: widget.title,
      imageUrl: widget.imageUrl,
      description: widget.description,
      voteAverage: widget.voteAverage,
    );
    
    if (mounted) setState(() => _isLiked = newState);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      
      body: Stack(
        children: [
          CustomScrollView( //serve per o scroll con la copertina che si "riduce"
            slivers: [
              SliverAppBar( //appbar che si estende con l'immagine della copertina
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                expandedHeight: 550, //altezza immagine espansa
                pinned: true, //la "barra" rimane fissa in altro e nel mentre si riduce
                leading: const SizedBox(),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero( //copertina del film con hero
                        tag: widget.heroTag,
                        child: Image.network(
                          widget.imageUrl,
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                        ),
                      ),
                      Container(  //sfumatura in basso all'immagine
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Theme.of(context).scaffoldBackgroundColor.withOpacity(0.0),
                              Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
                              Theme.of(context).scaffoldBackgroundColor,
                            ],
                            stops: const [0.0, 0.6, 0.85, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              //contenuto scrollable
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Text(widget.title,  //titolo del film
                            textAlign: TextAlign.center,
                            style: textTheme.headlineLarge),
                      const SizedBox(height: 10),

                      Column( //voto medio del film circolare
                        children: [
                          Text("Punteggio", style: Theme.of(context).textTheme.bodySmall),
                          const SizedBox(height: 8),
                          RatingCircle(
                            voteAverage: widget.voteAverage,
                            size: 50,
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      //pulsanti "azione"
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //tasto watchlist
                            MovieDetailAction(
                              icon: _isInWatchlist ? Icons.bookmark : Icons.bookmark_border,
                              label: "Watchlist",
                              isActive: _isInWatchlist,
                              activeColor: primaryColor,
                              onTap: _handleWatchlist,
                            ),

                            //tasto watched
                            MovieDetailAction(
                              icon: _isWatched ? Icons.visibility : Icons.visibility_off_outlined,
                              label: "Watched",
                              isActive: _isWatched,
                              activeColor: Colors.green,
                              onTap: _handleWatched,
                            ),

                            //tasto like visibile solo se il film è watched
                            if (_isWatched)
                              MovieDetailAction(
                                icon: _isLiked ? Icons.favorite : Icons.favorite_border,
                                label: "Like",
                                isActive: _isLiked,
                                activeColor: Colors.red,
                                onTap: _handleLiked,
                              ),

                            //tasto recensione solo se il film è watched
                            if (_isWatched)
                              MovieDetailAction(
                                icon: Icons.edit,
                                label: "Recensisci",
                                isActive: false,
                                onTap: () {
                                  //oggetto movie da passare alla write review page
                                  final movieToSend = Movie(
                                    id: widget.movieId,
                                    title: widget.title,
                                    posterPath: widget.imageUrl,
                                    overview: widget.description,
                                    voteAverage: widget.voteAverage,
                                    releaseDate: '',
                                  );
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => WriteReviewPage(initialMovie: movieToSend),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      //descrizione
                      Align(alignment: Alignment.centerLeft, child: Text("Descrizione", style: textTheme.headlineSmall)),
                      const SizedBox(height: 12),
                      
                      //widget per espandere la recensione con la freccetta
                      MovieDescription(description: widget.description),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),

          //tasto back in alto a sx
          Positioned(
            top: 50,
            left: 20,
            child: CircleButton(
              size: 45,
              icon: Icons.arrow_back,
              backgroundColor: Colors.black.withOpacity(0.5),
              iconColor: Colors.white,
              borderColor: Colors.transparent,
              onTap: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}