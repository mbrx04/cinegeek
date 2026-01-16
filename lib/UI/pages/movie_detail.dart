import 'package:cinegeek/UI/pages/write_review.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart'; 
import '../widgets/circle_button.dart';
import '../widgets/star_rating.dart';
import '../widgets/rating.dart';

class MovieDetailPage extends StatefulWidget {
  final int movieId; //id univoco per db
  final String title;
  final String imageUrl;
  final String description;
  final double voteAverage;
  final String heroTag;
  final bool isPopup;
  final bool showStars;

  const MovieDetailPage({
    super.key,
    required this.movieId,
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.voteAverage,
    required this.heroTag,
    this.isPopup = false,
    this.showStars = false,
  });

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  final FirestoreService _firestoreService = FirestoreService();  //service instanziato per usare i suoi metodi
    bool _isDescriptionExpanded = false;  //espansione della descrizione
  
  //3 stati del container per aggiungere alla watclist, like e watched
  bool _isInWatchlist = false; 
  bool _isWatched = false;     
  bool _isLiked = false;       
  
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;  //prendo l'id del'utente loggato per tutte le informazioni

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() async {  //carica lo stato iniziale cioè se ho già messo like ecc...
    if (_uid == null) return;

    final results = await Future.wait([
      //con future.wait si fanno tutte e 3 le richieste contemporaneamente
      _firestoreService.checkMovieInList(_uid!, 'watchlist', widget.movieId),
      _firestoreService.checkMovieInList(_uid!, 'watched', widget.movieId),
      _firestoreService.checkMovieInList(_uid!, 'liked', widget.movieId),
    ]);

    if (mounted) {  //la grafica si aggiorna solo se il widget è visiibile
      setState(() {
        _isInWatchlist = results[0];
        _isWatched = results[1];
        _isLiked = results[2];
      });
    }
  }

  //gestione del tasto watchlist
  void _handleWatchlist() async {
    if (_uid == null) return;
    
    //il service aggiunge o rimuove il film
    final newState = await _firestoreService.toggleMovieInList(
      uid: _uid!,
      collection: 'watchlist',
      movieId: widget.movieId,
      title: widget.title,
      imageUrl: widget.imageUrl,
      description: widget.description,
      voteAverage: widget.voteAverage,
    );
    //aggiornamento icona
    if (mounted) setState(() => _isInWatchlist = newState);
  }

  //gestione watched
  void _handleWatched() async {
    if (_uid == null) return;

    final newState = await _firestoreService.toggleMovieInList(
      uid: _uid!,
      collection: 'watched',
      movieId: widget.movieId,
      title: widget.title,
      imageUrl: widget.imageUrl,
      description: widget.description,
      voteAverage: widget.voteAverage,
    );

    if (newState == true && _isInWatchlist) {
      //se il film è segnato come visto viene tolto automaticamente dalla watchlist
      await _firestoreService.removeMovieFromList(_uid!, 'watchlist', widget.movieId);
      if (mounted) setState(() => _isInWatchlist = false);
    }
    //aggiornamento icona watched
    if (mounted) setState(() => _isWatched = newState);
  }

  //gestione click like
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
    //aggiornamento icona like
    if (mounted) setState(() => _isLiked = newState);
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      
      body: Stack(
        children: [
          CustomScrollView( //con custom scroll view si usano gli sliver per lo scorrimento
            slivers: [
              SliverAppBar(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                expandedHeight: 550, //altezza massima dell'immagine
                pinned: true, //la barra rimane fissa quando si scorre
                leading: const SizedBox(),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero( //animaizone hero
                        tag: widget.heroTag,
                        child: Image.network(
                          widget.imageUrl,
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                        ),
                      ),
                      //sfumatura in basso per rendere leggibile il titolo
                      Container(
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

              //body della pagina
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(widget.title, textAlign: TextAlign.center, style: textTheme.headlineLarge),  //titolo
                      const SizedBox(height: 10),


                      //votazioni a scelta tra rating circolre o stelle in base a dove si vede
                      if (widget.showStars)
                        StarRating(
                          rating: widget.voteAverage,
                          itemSize: 35,
                        )
                      else
                        Column(
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

                      //container con i tasti "azione"
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
                            //tast watchlist per aggiungere o rimuovere ai film da vedere
                            _buildActionItem(
                              context: context,
                              icon: _isInWatchlist ? Icons.bookmark : Icons.bookmark_border,
                              label: "Watchlist",
                              isActive: _isInWatchlist,
                              activeColor: primaryColor,
                              onTap: _handleWatchlist,
                            ),

                            //tasto  watched per aggiungerlo o rimuoverlo dai film visti
                            _buildActionItem(
                              context: context,
                              icon: _isWatched ? Icons.visibility : Icons.visibility_off_outlined,
                              label: "Watched",
                              isActive: _isWatched,
                              activeColor: Colors.green,
                              onTap: _handleWatched,
                            ),

                            //tasto like per aggiungere o rimuovere dai film piaciuti/preferiti
                            if (_isWatched)
                              _buildActionItem(
                                context: context,
                                icon: _isLiked ? Icons.favorite : Icons.favorite_border,
                                label: "Like",
                                isActive: _isLiked,
                                activeColor: Colors.red,
                                onTap: _handleLiked,
                              ),

                            //tasto recensisci che porta alla pagina per scrivere la recensione
                            if (_isWatched && !widget.isPopup)
                              _buildActionItem(
                                context: context,
                                icon: Icons.edit,
                                label: "Recensisci",
                                isActive: false,
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const WriteReviewPage()));
                                },
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      //descrizione
                      Align(alignment: Alignment.centerLeft, child: Text("Trama", style: textTheme.headlineSmall)),
                      const SizedBox(height: 12),
                      
                      Column(
                        children: [
                          AnimatedSize( //espandi e ritrai la descrizione
                            duration: const Duration(milliseconds: 300),
                            alignment: Alignment.topCenter,
                            child: Text(
                              widget.description,
                              textAlign: TextAlign.left,
                              maxLines: _isDescriptionExpanded ? null : 4,
                              overflow: _isDescriptionExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                              style: textTheme.bodyMedium,
                            ),
                          ),
                          if (widget.description.length > 150)  //mostra la freccia per espandere solo se i caratteri sono >150
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isDescriptionExpanded = !_isDescriptionExpanded;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                width: double.infinity,
                                child: Center(
                                  child: Icon(
                                    _isDescriptionExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
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

  //costruisce la combo circle button + testo per i tasti nel container
  Widget _buildActionItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
    Color? activeColor,
  }) {
    //se il bottone è attivo usa i colori scelti altrimenti rimane di default
    final Color? iconColor = isActive ? (activeColor ?? Colors.white) : null;
    final Color? borderColor = isActive ? (activeColor ?? Colors.white) : null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleButton(
          size: 50,
          icon: icon,
          onTap: onTap,
          iconColor: iconColor,
          borderColor: borderColor,
          backgroundColor: isActive 
              ? (activeColor?.withOpacity(0.2) ?? Colors.white.withOpacity(0.2)) 
              : null,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontSize: 11,
            color: isActive ? activeColor : null,
          ),
        ),
      ],
    );
  }
}