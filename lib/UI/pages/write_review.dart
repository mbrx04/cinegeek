import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../model/movie.dart';
import '../../model/review.dart';
import '../../services/firestore_service.dart';
import '../../services/tmdb_service.dart';
import '../../services/auth_service.dart';
import '../widgets/star_rating.dart';
import '../widgets/circle_button.dart';
import '../widgets/selected_movie_card.dart';
import '../widgets/movie_search_result.dart';

class WriteReviewPage extends StatefulWidget {
  final Movie? initialMovie;  //se arriviamo in write review da un movie detail il campo è pre compilato

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
  
  //stati del film selezionato
  Movie? _selectedMovie;
  String? _selectedMovieTitle;
  String? _selectedMovieImage;

  //stato iniziale dopo aver selezionato un film
  double _currentRating = 3.0;
  final TextEditingController _reviewController = TextEditingController();
  final TextEditingController _movieSearchController = TextEditingController();

  List<Movie> _searchResults = [];
  bool _isSearchingMovie = false;
  bool _isPublishing = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialMovie != null) {  //se la write review viene aperta da un movie detail questo lo precompila
      _selectedMovie = widget.initialMovie;
      _selectedMovieTitle = widget.initialMovie!.title;
      _selectedMovieImage = widget.initialMovie!.fullPosterUrl;
      _movieSearchController.text = widget.initialMovie!.title;
      _isSearchingMovie = false; 
      _searchResults = [];
    }
  }

  //gestione della ricerca, aspetta 1 secondo e mezzo prma di andare ad effettuare la chiamata così da non fare chiamate inutili
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

  //una volta cliccato un film dalla lista
  void _selectMovie(Movie movie) {
    setState(() {
      _selectedMovie = movie;
      _selectedMovieTitle = movie.title;
      _selectedMovieImage = movie.fullPosterUrl;
      //svuotamento ricerca per far chiudere la lista che a tendina
      _isSearchingMovie = false;
      _movieSearchController.text = movie.title;
      _searchResults = [];
    });
    FocusScope.of(context).unfocus(); //tastiera che si chiude
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _reviewController.dispose();
    _movieSearchController.dispose();
    super.dispose();
  }

  //gestione salvataggio delle recensioni
  Future<void> _saveReview() async {
    final user = FirebaseAuth.instance.currentUser;
    
    //anche se non è possibile che un utenet non sia loggato controlliamo per sicurezza
    if (user == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Devi essere loggato.")));
      return;
    }

    if (_selectedMovie == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Seleziona un film")));
      return;
    }

    if (_reviewController.text.trim().isEmpty) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Scrivi una recensione")));
      return;
    }

    //controllo che il film sia nei watched ell'utente loggato altirmenti non faccio scrivere la recensione per quel film
    final isWatched = await _firestoreService.checkMovieInList(user.uid, 'watched', _selectedMovie!.id);
    if (!isWatched) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(backgroundColor: Colors.red, content: Text("Devi aver visto il film per recensirlo!")),
        );
      }
      return;
    }

    try {
      setState(() => _isPublishing = true); //caricamento recensione mostrato
      
      //username dell'utente che ha messo la recensione
      String authorName = 'utente sconosciuto';
      final appUser = await _authService.fetchUserData(user.uid);
      if (appUser != null && appUser.username.isNotEmpty) {
        authorName = appUser.username;
      }

      //oggetto review
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

      //invio al db la recensione
      await _firestoreService.addReview(review);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Recensione pubblicata!")));
        Navigator.pop(context); 
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
    //tema chiaro e scuro
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color inputFillColor = isDark ? Colors.black.withAlpha(153) : Colors.black.withAlpha(10);
    final Color inputBorderColor = isDark ? Colors.white.withAlpha(26) : Colors.black.withAlpha(26);
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color hintColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 130, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Scrivi Recensione", style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(height: 30),

                //1)
                //ricerca film
                const Text("Quale film vuoi recensire?", style: TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 10),

                Container(
                  decoration: BoxDecoration(
                    color: inputFillColor,
                    borderRadius: BorderRadius.circular(35),
                    border: Border.all(color: inputBorderColor),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _movieSearchController,
                    onChanged: _onSearchChanged, //anche qui la ricerca con attesa
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      hintText: "Cerca il titolo...",
                      hintStyle: TextStyle(color: hintColor),
                      icon: Icon(Icons.search, color: textColor),
                      border: InputBorder.none,
                    ),
                  ),
                ),

                //mostro lista solo se sto cercando
                if (_isSearchingMovie && _searchResults.isNotEmpty)
                  MovieSearchResults(
                    results: _searchResults, 
                    onSelect: _selectMovie
                  ),

                const SizedBox(height: 20),

                //2)
                //film selezionato
                if (_selectedMovieTitle != null) ...[
                  SelectedMovieCard(
                    title: _selectedMovieTitle!, 
                    imageUrl: _selectedMovieImage!
                  ),
                  const SizedBox(height: 30),
                ],

                //3)
                //voto con le stelline
                const Center(child: Text("Il tuo voto", style: TextStyle(fontSize: 16, color: Colors.grey))),
                const SizedBox(height: 10),
                Center(
                  child: StarRating(
                    rating: _currentRating,
                    isInteractive: true,
                    itemSize: 45,
                    onRatingUpdate: (rating) => setState(() => _currentRating = rating),
                  ),
                ),

                const SizedBox(height: 30),

                //4)
                //recensione
                const Text("La tua opinione (max 100 car.)", style: TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 10),
                
                Container(
                  decoration: BoxDecoration(
                    color: inputFillColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: inputBorderColor),
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

                //5)
                //bottone pubblica recensione
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    //il bottone si attiva solo se c'è un film selezionato
                    onPressed: (_selectedMovieTitle != null && _reviewController.text.isNotEmpty && !_isPublishing)
                        ? _saveReview
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
                      elevation: 5,
                    ),
                    child: _isPublishing 
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text("Pubblica Recensione", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),

          //tasto back in alto a sx
          Positioned(
            top: 50, left: 20,
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