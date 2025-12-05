import "package:flutter/material.dart";
import '../pages/movie_detail.dart';
import 'movie_preview_popup.dart';
//widget riutilizzabile che mostra una card di un film.

class MovieCard extends StatelessWidget {
  final String imageUrl;  //url della copertina del film
  final String title; //titolo del film
  final double width; //larghezza della card
  final double height;  //altezza della card
  final VoidCallback? onTap;  //azione da fare con singolo tap
  final VoidCallback? onLongPress;  //azione da fare con long press (popup)
  final GlobalKey _key = GlobalKey(); //chiave per la copertina

  MovieCard({
    super.key,
    required this.imageUrl,
    required this.title,
    this.width = 130,
    this.height = 200,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () { //mi porta alla pagina dei dettagli del film
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailPage(
              title: title, //usa il title del widget
              imageUrl: imageUrl, //usa imageUrl del widget
              description: "Nessuna descrizione, ci sarà quando funzioneranno le API", 
              voteAverage: 7.5, //anche questo è fisso e verrà poi sostituito con le vere API
              heroTag: imageUrl, //passa lo stesso valore usato nel Hero widget
            ),
          ),
        );
      },

      onLongPress: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (_, __, ___) => MoviePreviewPopup(
              imageUrl: imageUrl,
              title: title,
              description: "Nessuna descrizione",
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return ScaleTransition(
                scale: Tween(begin: 0.6, end: 1.0).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                ),
                child: child,
              );
            },
          ),
        );
      },

      
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //copertina del film
          Hero(
            tag: imageUrl,
            child: ClipRRect(
              key: _key,
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                imageUrl,
                width: width,
                height: height,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: width,
                  height: height,
                  color: Colors.grey[800],
                  child: const Icon(Icons.broken_image, size: 40),
                ),
              ),
            ),
          ),

          const SizedBox(height: 6),

          //titolo del film
          SizedBox(
            width: width,
            child: Text(
            title,
            maxLines: 1,  //permette di andare a capo senza superare 1 riga in questo caso
            overflow: TextOverflow.ellipsis, //aggiunge ... se troppo lungo se il nome è più lungo della copertina o ha finito le righe a disposizione
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          ),
        ],
      ),
    );
  }
}
