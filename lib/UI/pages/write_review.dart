import 'package:flutter/material.dart';
import '../widgets/star_rating.dart';
import '../widgets/circle_button.dart';

class WriteReviewPage extends StatefulWidget {
  const WriteReviewPage({super.key});

  @override
  State<WriteReviewPage> createState() => _WriteReviewPageState();
}

class _WriteReviewPageState extends State<WriteReviewPage> {
  String? _selectedMovieTitle;
  String? _selectedMovieImage;
  double _currentRating = 3.0;
  final TextEditingController _reviewController = TextEditingController();
  final TextEditingController _movieSearchController = TextEditingController();

  List<Map<String, String>> _searchResults = [];
  bool _isSearchingMovie = false;

  //lista hardcoded per avere un elenco finto al momento
  final List<Map<String, String>> _allMovies = [
    {"title": "Fast X", "image": "https://www.themoviedb.org/t/p/w200/hC6mLdlgpFU63FOduX80xaGevGj.jpg"},
    {"title": "F1", "image": "https://www.themoviedb.org/t/p/w1280/tGMs4Ji6CH33GIx5aHAXc0uhu3F.jpg"},
    {"title": "Overdrive", "image": "https://www.themoviedb.org/t/p/w1280/a0hTRjis1cxwmjOuBaS7WdDG3dj.jpg"},
  ];

  //ricerca locale
  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearchingMovie = false;
      });
      return;
    }
    setState(() {
      _isSearchingMovie = true;
      _searchResults = _allMovies
          .where((m) => m['title']!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  //cliccando su un film dalla lista che si espande
  void _selectMovie(String title, String image) {
    setState(() {
      _selectedMovieTitle = title;
      _selectedMovieImage = image;
      _isSearchingMovie = false;
      _movieSearchController.text = title;  //si riempe il campo di ricerca automaticamente
      _searchResults = [];  //chiude la tendina dei risultati
    });
    FocusScope.of(context).unfocus(); //chiude la tastiera
  }

  BoxDecoration _getInputBoxDecoration() {
    return BoxDecoration(
      color: Colors.black.withAlpha(153),
      borderRadius: BorderRadius.circular(35),
      border: Border.all(color: Colors.white.withAlpha(26), width: 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 130, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Scrivi Recensione", //titolo della pagina
                style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(height: 30),

                //ricerca film
                const Text("Quale film vuoi recensire?", style: TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 10),
                Container(
                  decoration: _getInputBoxDecoration(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _movieSearchController,
                    onChanged: _onSearchChanged,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "Cerca il titolo...",
                      hintStyle: TextStyle(color: Colors.white70),
                      icon: Icon(Icons.search, color: Colors.white),
                      border: InputBorder.none,
                    ),
                  ),
                ),

                //risultati di ricerca
                if (_isSearchingMovie && _searchResults.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(204),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      children: _searchResults.map((movie) => ListTile(
                        leading: Image.network(movie['image']!, width: 30),
                        title: Text(movie['title']!, style: const TextStyle(color: Colors.white)),
                        onTap: () => _selectMovie(movie['title']!, movie['image']!),
                      )).toList(),
                    ),
                  ),

                const SizedBox(height: 20),

                //film selezionato
                if (_selectedMovieTitle != null) ...[
                  Center(
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(_selectedMovieImage!, height: 140),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _selectedMovieTitle!,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                const Text("La tua opinione (max 100 car.)", style: TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 10),
                Container(
                  decoration: _getInputBoxDecoration().copyWith(
                    borderRadius: BorderRadius.circular(20)
                  ),
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _reviewController,
                    maxLength: 100,
                    maxLines: 4,
                    style: const TextStyle(color: Colors.white),
                    onChanged: (_) => setState(() {}), 
                    decoration: const InputDecoration(
                      hintText: "Scrivi qui...",
                      hintStyle: TextStyle(color: Colors.white70),
                      border: InputBorder.none,
                      counterStyle: TextStyle(color: Colors.white54),
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
                      ? () {
                          print("Pubblicata: $_selectedMovieTitle");
                          Navigator.pop(context);
                        } 
                      : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
                      elevation: 5,
                    ),
                    child: const Text("Pubblica Recensione", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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