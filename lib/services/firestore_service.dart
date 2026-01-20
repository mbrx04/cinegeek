//serve per gestire tutte le comunicazioni con firestore
import 'package:cinegeek/model/review.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  //metodo privati usati internamente
  Map<String, dynamic> _formatMovieData({
    required int id,
    required String title,
    required String imageUrl,
    required String description,
    required double voteAverage,
  }) {
    return {
      'id': id, //id del film
      'title': title, //titolo
      'fullPosterUrl': imageUrl,  //salva l'url completo della copertina del film
      'posterPath': imageUrl.replaceFirst('https://image.tmdb.org/t/p/w500', ''), //estrae il path dell'immagine
      'voteAverage': voteAverage, //voto medio
      'overview': description, //descrizione
      'timestamp': FieldValue.serverTimestamp(), //data del salvataggio
    };
  }

  //metodi pubblici usati all'esterno
  //controlla se un film esiste già in una lista specifica e restituisce un booleano
  Future<bool> checkMovieInList(String uid, String collection, int movieId) async {
    try {
      final doc = await _db
          .collection('users') //utenti
          .doc(uid) //uid dell'utente loggato
          .collection(collection) //sottocartella che può essere liked o watchlist
          .doc(movieId.toString()) //cerco l'id del film
          .get();
      return doc.exists; //controllo se esiste
    } catch (e) {
      print("Errore controllo lista: $e");
      return false;
    }
  }

  //aggiunge o rimuove un film dalla lista in questione
  Future<bool> toggleMovieInList({
    required String uid,
    required String collection, //watchlist, watched, liked
    required int movieId,
    required String title,
    required String imageUrl,
    required String description,
    required double voteAverage,
  }) async {
    //riferimento al documento specifico del film
    final ref = _db.collection('users').doc(uid).collection(collection).doc(movieId.toString());
    //controllo se ci sia gia
    final doc = await ref.get();

    if (doc.exists) { //se c'è gia lo cancello
      await ref.delete();
      return false; //return false per dire che non c'è più
    } else {  //se non c'è lo aggiungiamo
      await ref.set(_formatMovieData(
        id: movieId,
        title: title,
        imageUrl: imageUrl,
        description: description,
        voteAverage: voteAverage,
      ));
      return true; //return true per dire che c'è ora
    }
  }

  //rimuove un film dalla lista forzatamente
  Future<void> removeMovieFromList(String uid, String collection, int movieId) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection(collection)
        .doc(movieId.toString())
        .delete();
  }

  // ... (Tutto il codice delle liste checkMovieInList/toggleMovieInList rimane uguale)

  // --- GESTIONE RECENSIONI (MODIFICATA PER FEED E CAROSELLO) ---

  // Aggiunge una recensione alla collezione GLOBALE
  Future<void> addReview(Review review) async {
    // Salviamo in 'reviews' (globale) così possiamo fare query tipo:
    // "Dammi tutte le recensioni di Marco" o "Dammi tutte le recensioni di questo film"
    await _db.collection('reviews').add(review.toMap());
  }

  // Ottiene le recensioni di uno specifico film (per la pagina dettaglio)
  Stream<List<Review>> getReviewsForMovie(String movieId) {
    return _db
        .collection('reviews')
        .where('movieId', isEqualTo: movieId) // Filtra per film
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Review.fromMap(doc.data(), doc.id))
            .toList());
  }

  // (OPZIONALE FUTURO) Ottiene le recensioni di un utente specifico (per il profilo amico)
  Stream<List<Review>> getReviewsByUser(String userId) {
    return _db
        .collection('reviews')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Review.fromMap(doc.data(), doc.id))
            .toList());
  }
}