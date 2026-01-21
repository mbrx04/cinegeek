import 'dart:async';  //SEMPRE PER EVITARE DI FARE CHIAMATE INUTILI ALL'API
import 'package:cinegeek/model/app_user.dart';
import 'package:cinegeek/model/review.dart';
import 'package:cinegeek/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../model/movie.dart';
import '../../services/tmdb_service.dart';
import '../widgets/star_rating.dart';
import '../widgets/circle_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';

class WriteReviewPage extends StatefulWidget {
  final Movie? initialMovie;

  const WriteReviewPage({
    super.key,
    this.initialMovie,
    });

  @override
  State<WriteReviewPage> createState() => _WriteReviewPageState();
}

class _WriteReviewPageState extends State<WriteReviewPage> {
  final TmdbService _tmdbService = TmdbService();
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  Timer? _debounce;

  //variabili di stato
  Movie? _selectedMovie;
  String? _selectedMovieTitle;
  String? _selectedMovieImage;

  double _currentRating = 3.0;
  final TextEditingController _reviewController = TextEditingController();
  final TextEditingController _movieSearchController = TextEditingController();

  List<Movie> _searchResults = [];
  bool _isSearchingMovie = false;
  bool _isPublishing = false; //evita doppi invii di una singola recensione

  @override
  void initState() {
    super.initState();
    
    if (widget.initialMovie != null) {  //se inizialmente c'è un film viene caricato subito come campo di ricerca senza scrivere il titolo
      _selectedMovie = widget.initialMovie;
      _selectedMovieTitle = widget.initialMovie!.title;
      _selectedMovieImage = widget.initialMovie!.fullPosterUrl;
      _movieSearchController.text = widget.initialMovie!.title;
      _isSearchingMovie = false; 
    }
  }

  //ricerca del film
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 1500), () async {
      if (query.isEmpty) {
        setState(() {
          _searchResults = [];
          _isSearchingMovie = false;
        });
        return;
      }

      final results = await _tmdbService.searchMovies(query);

      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearchingMovie = true;
        });
      }
    });
  }

  //selezione film
  void _selectMovie(Movie movie) {
    setState(() {
      _selectedMovie = movie;
      _selectedMovieTitle = movie.title;
      _selectedMovieImage = movie.fullPosterUrl;
      _isSearchingMovie = false;
      _movieSearchController.text = movie.title;
      _searchResults = [];
    });
    FocusScope.of(context).unfocus();
  }


  @override
  void dispose() {
    _debounce?.cancel();
    _reviewController.dispose();
    _movieSearchController.dispose();
    super.dispose();
  }

  //salva recensione
  Future<void> _saveReview() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Devi essere loggato per scrivere una recensione")),
      );
      return;
    }

    if (_selectedMovie == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Seleziona un film")),
      );
      return;
    }

    if (_reviewController.text.trim().isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Scrivi una recensione")),
      );
      return;
    }

    try {

      setState(() {
        _isPublishing = true;
      });
    
      String authorName = 'utente sconosciuto';
      final appUser = await _authService.fetchUserData(user.uid);
      if (appUser != null && appUser.username.isNotEmpty) {
        authorName = appUser.username;
      }

      final review = Review(
        userId: user.uid,
        username: authorName,
        movieId: _selectedMovie!.id.toString(),
        movieTitle: _selectedMovieTitle!,
        moviePosterUrl: _selectedMovieImage!,
        text: _reviewController.text.trim(),
        rating: _currentRating,
        createdAt: DateTime.now(),
      );

    await _firestoreService.addReview(review);  //salva sul db

    if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Recensione pubblicata con successo!")),
        );
        Navigator.pop(context); //dopo il messaggio di successo torna indietro
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Errore: $e")));
        setState(() => _isPublishing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;  //rileva il tema

    //definisco i colori che saranno dinamici
    final Color inputFillColor = isDark 
        ? Colors.black.withAlpha(153) 
        : Colors.black.withAlpha(10);

    final Color inputBorderColor = isDark 
        ? Colors.white.withAlpha(26) 
        : Colors.black.withAlpha(26);

    //colori del testo sempre per chiaro e scuro
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color hintColor = isDark ? Colors.white70 : Colors.black54;

    //colori per elenco dei film che si espande
    final Color dropdownColor = isDark 
        ? Colors.black.withAlpha(230) 
        : Colors.white.withAlpha(240);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 130, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Scrivi Recensione",
                    style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(height: 30),

                //ricerca film
                const Text("Quale film vuoi recensire?", 
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 10),

                Container(
                  decoration: BoxDecoration(
                    color: inputFillColor,
                    borderRadius: BorderRadius.circular(35),
                    border: Border.all(color: inputBorderColor, width: 1),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _movieSearchController,
                    onChanged: _onSearchChanged,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      hintText: "Cerca il titolo...",
                      hintStyle: TextStyle(color: hintColor),
                      icon: Icon(Icons.search, color: textColor),
                      border: InputBorder.none,
                    ),
                  ),
                ),

                if (_isSearchingMovie && _searchResults.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    constraints: const BoxConstraints(maxHeight: 250),
                    decoration: BoxDecoration(
                      color: dropdownColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: inputBorderColor),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: ListView.separated(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: _searchResults.length,
                        separatorBuilder: (ctx, i) => Divider(color: inputBorderColor, height: 1),
                        itemBuilder: (context, index) {
                          final movie = _searchResults[index];
                          return ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(
                                movie.fullPosterUrl,
                                width: 40,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (_,__,___) => Icon(Icons.movie, color: textColor),
                              ),
                            ),
                            title: Text(
                              movie.title,
                              style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              movie.releaseDate.split('-').first,
                              style: TextStyle(color: hintColor, fontSize: 12),
                            ),
                            onTap: () => _selectMovie(movie),
                          );
                        },
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                //film selezionato
                if (_selectedMovieTitle != null) ...[
                  Center(
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(  //ombre
                                  color: isDark ? Colors.black.withAlpha(100) : Colors.black.withAlpha(40), 
                                  blurRadius: 15, 
                                  spreadRadius: 2)
                            ]
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              _selectedMovieImage!,
                              height: 180,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _selectedMovieTitle!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],

                //voto con le stelline
                const Center(child: Text("Il tuo voto", style: TextStyle(fontSize: 16, color: Colors.grey))),
                const SizedBox(height: 10),
                Center(
                  child: StarRating(
                    rating: _currentRating,
                    isInteractive: true,
                    itemSize: 45,
                    onRatingUpdate: (rating) {
                      setState(() {
                        _currentRating = rating;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 30),

                //input recensione dell'utente
                const Text("La tua opinione (max 100 car.)",
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 10),
                
                //box testo in cui si scrive la recensione
                Container(
                  decoration: BoxDecoration(
                    color: inputFillColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: inputBorderColor, width: 1),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _reviewController,
                    maxLength: 100,
                    maxLines: 4,
                    style: TextStyle(color: textColor),
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: "Scrivi qui...",
                      hintStyle: TextStyle(color: hintColor),
                      border: InputBorder.none,
                      counterStyle: TextStyle(color: hintColor),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                //bottone pubblica recensione
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: (_selectedMovieTitle != null && _reviewController.text.isNotEmpty)
                        ? () async {
                            await _saveReview();
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
                      elevation: 5,
                    ),
                    child: const Text("Pubblica Recensione",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),

          //tasto indietro in alto a sx
          Positioned(
            top: 50,
            left: 20,
            child: CircleButton(
              icon: Icons.arrow_back,
              onTap: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}