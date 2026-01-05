import 'package:flutter/material.dart';
import '../../services/tmdb_service.dart';
import '../../model/movie.dart';
import 'movie_detail.dart';

class SearchResultsPage extends StatefulWidget {
  final String query;

  const SearchResultsPage({super.key, required this.query});

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  final TmdbService _service = TmdbService();
  
  //quello che contiene i risultati della ricerca
  late Future<List<Movie>> _searchFuture;

  @override
  void initState() {
    super.initState();
    _searchFuture = _service.searchMovies(widget.query);
  }

  @override
  void didUpdateWidget(SearchResultsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    //se la query cambia, quindi viene cliccato u nuovo tasto sulla tastiera il timer riparte
    if (oldWidget.query != widget.query) {
      setState(() {
        _searchFuture = _service.searchMovies(widget.query);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //schermata iniziale vuota se non c'è testo
    if (widget.query.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.movie_filter_outlined, size: 80, color: Colors.white24),
            const SizedBox(height: 16),
            Text(
              "Scrivi il film che stai cercando...",
              style: TextStyle(color: Colors.white.withAlpha(128), fontSize: 18),
            ),
          ],
        ),
      );
    }

    return Container(
      color: Theme.of(context).colorScheme.surface,
      //padding per non finire sotto la nav bar
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 0), 
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //mostra quello che ha trovato
          Text(
            "Risultati per \"${widget.query}\"",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          
          //lista dei risultati
          Expanded(
            child: FutureBuilder<List<Movie>>(
              future: _searchFuture,
              builder: (context, snapshot) {
                
                //caricamento
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color.fromARGB(255, 204, 255, 0)),
                  );
                }
                
                //errore
                if (snapshot.hasError) {
                  return Center(child: Text("Errore: ${snapshot.error}"));
                }

                //nessun risultato
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text("Non ho trovatu nulla", style: TextStyle(color: Colors.white54)),
                  );
                }

                final movies = snapshot.data!;

                //griglia dei risultati
                return GridView.builder(
                  //altro padding per non finire sotto la nav bar
                  padding: const EdgeInsets.only(bottom: 120),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,  //3 film per riga
                    childAspectRatio: 0.65, //dimensioni della locandina
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: movies.length,
                  itemBuilder: (context, index) {
                    final movie = movies[index];
                    final heroTag = 'search_${movie.id}';

                    return GestureDetector(
                      onTap: () {
                        //navigazione a movie_detail con il passaggio dei dati
                         Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MovieDetailPage(
                              title: movie.title,
                              imageUrl: movie.fullPosterUrl,
                              description: movie.overview,
                              voteAverage: movie.voteAverage,
                              heroTag: heroTag,
                            ),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Expanded(
                            child: Hero(
                              tag: heroTag,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  movie.fullPosterUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (_,__,___) => Container(
                                    color: Colors.grey[800],
                                    child: const Icon(Icons.broken_image, size: 30, color: Colors.white24),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            movie.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, color: Colors.white70),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}