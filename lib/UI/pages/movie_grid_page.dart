//import 'package:cinegeek/model/movie.dart';
//import 'package:cinegeek/services/fake_tmdb_service.dart';
//import 'package:flutter/cupertino.dart';
//import 'package:flutter/material.dart';
//
//
///* Enum per distinguere il tipo (watchlist oppure piaciuti */
//enum MovieCollectionType{
//  watchlist,
//  liked,
//}
//
///* Widget che mostra i film in base al tipo */
//class MovieGridPage extends StatefulWidget{
//  final String username;
//  final String title;
//  final MovieCollectionType type;
//
//  const MovieGridPage({
//    super.key,
//    required this.username,
//    required this.title,
//    required this.type,
//  });
//
//  State<MovieGridPage> createState() => _MovieGridPageState();
//}
//
//class _MovieGridPageState extends State<MovieGridPage> {
//  late Future<List<Movie>> _moviesFuture;
//
//  void initState(){
//    super.initState();
//    _moviesFuture = _loadMovies();
//  }
//
//  /* Metodo privato per caricare i film a seconda del tipo*/
//  Future<List<Movie>> _loadMovies(){
//    final service = FakeTmdbService();
//
//
//    switch (widget.type){
//      case MovieCollectionType.watchlist:
//        return service.fetchWatchlist(widget.username);
//
//      case MovieCollectionType.liked:
//        return service.fetchLikedMovies(widget.username);
//    }
//  }
//
//  Widget build(BuildContext context) {
//    return Scaffold(
//      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//      body: SafeArea(
//          child: Column(
//            children: [
//              Padding(
//                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                  child: SizedBox(
//                  height: 48,
//                  child: Stack(
//                  alignment: Alignment.center,
//                  children: [
//                    Align(
//                      alignment: Alignment.centerLeft,
//                      child: Row(
//                        mainAxisSize: MainAxisSize.min,
//                        children: [
//                          IconButton(
//                            icon: const Icon(Icons.arrow_back),
//                            onPressed: () => Navigator.pop(context),
//                          ),
//
//                          Text(
//                            widget.username,
//                            style: Theme.of(context).textTheme.bodyMedium ?.copyWith(color: Colors.grey),
//                          ),
//                        ],
//                      ),
//                    ),
//
//                    const SizedBox(width: 6),
//                    Text(
//                      widget.title,
//                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                          fontWeight: FontWeight.bold,
//                      ),
//                    ),
//                  ],
//                ),
//              ),
//              ),
//
//      /* Espande il contenuto per la griglia dei film */
//      Expanded(
//          child: FutureBuilder<List<Movie>>(
//              future: _moviesFuture,
//              builder: (context, snapshot){
//
//                /* Mostra il caricamento se la lista dei film non è ancora pronta */
//                if (snapshot.connectionState == ConnectionState.waiting){
//                  return const Center(child: CircularProgressIndicator());
//                }
//
//                /* Mostra errore se il caricamento non è andato a buon fine */
//                if (snapshot.hasError) {
//                  return const Center(
//                    child: Text("Errore caricamento dati"));
//                }
//
//                /* Viene presa la lista dei film, oppure la lista vuota se nulla è disponibile */
//                final movies = snapshot.data ?? [];
//
//                /* Viene costruita griglia con i film */
//                return GridView.builder(
//                  padding: const EdgeInsets.all(16),
//                  gridDelegate:
//                    const SliverGridDelegateWithFixedCrossAxisCount(
//                      crossAxisCount: 3,
//                      mainAxisSpacing: 12,
//                      crossAxisSpacing: 12,
//                      childAspectRatio: 0.66,
//                    ),
//                  itemCount: movies.length,
//                  itemBuilder: (context, index) {
//                  final movie = movies[index];
//                  return ClipRRect(
//                    borderRadius: BorderRadius.circular(8),
//                    child: Image.network(
//                      movie.fullPosterUrl,
//                      fit: BoxFit.cover,
//                      ),
//                  );
//                  },
//              );
//            },
//          ),
//      ),
//      ],
//    ),
//    ),
//  );
//}
//}