import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/movie.dart';

enum MovieCollectionType {
  watchlist,
  liked,
}

class MovieGridPage extends StatefulWidget {
  final String userId;  //id dell'utente per avere i suoi dati
  final String title;
  final MovieCollectionType type;

  const MovieGridPage({
    super.key,
    required this.userId,
    required this.title,
    required this.type,
  });

  @override
  State<MovieGridPage> createState() => _MovieGridPageState();
}

class _MovieGridPageState extends State<MovieGridPage> {
  
  //collega i dati in live
  Stream<QuerySnapshot> _getMoviesStream() {
    //decide se guardare la watchlist o la liked
    String collectionName = widget.type == MovieCollectionType.watchlist 
        ? 'watchlist' 
        : 'liked';

    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection(collectionName)
        .orderBy('timestamp', descending: true) 
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: _getMoviesStream(),
        builder: (context, snapshot) {
          
          //caricamento
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 204, 255, 0),
              ),
            );
          }

          //errore
          if (snapshot.hasError) {
            return Center(child: Text("Errore: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
          }

          //lista vuota
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.type == MovieCollectionType.watchlist 
                      ? Icons.bookmark_border 
                      : Icons.favorite_border,
                    size: 80,
                    color: Theme.of(context).iconTheme.color?.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Nessun film in ${widget.title}",
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5), 
                      fontSize: 18
                    ),
                  ),
                ],
              ),
            );
          }

          //film presenti e mostra allora la griglia
          final docs = snapshot.data!.docs;
          
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, //3 colonne
              mainAxisSpacing: 12, //spazio verticale
              crossAxisSpacing: 12, //spazio orizzontale
              childAspectRatio: 0.66, //formato locandina
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              
              //creazione oggetto movie
              final movie = Movie(
                id: data['id'] ?? 0, 
                title: data['title'] ?? 'Sconosciuto',
                posterPath: data['posterPath'] ?? '', 
                overview: data['overview'] ?? '',
                voteAverage: (data['voteAverage'] ?? 0).toDouble(),
                releaseDate: data['releaseDate'] ?? '',
              );

              return GestureDetector(
                onTap: () {
                   print("Hai cliccato su: ${movie.title}");
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: movie.fullPosterUrl.isNotEmpty
                      ? Image.network(
                          movie.fullPosterUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => 
                              Container(
                                color: Colors.grey[800], 
                                child: const Icon(Icons.broken_image, color: Colors.white54)
                              ),
                        )
                      : Container(
                          color: Colors.grey[800], 
                          child: const Icon(Icons.movie, color: Colors.white54)
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}