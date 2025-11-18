import "package:flutter/material.dart";

//widget riutilizzabile che mostra una card di un film.

class MovieCard extends StatelessWidget {
  final String imageUrl;  //url della copertina del film
  final String title; //titolo del film
  final double width; //larghezza della card
  final double height;  //altezza della card
  final VoidCallback? onTap;  //azione da fare con singolo tap
  final VoidCallback? onLongPress;  //azione da fare con long press (popup)

  const MovieCard({
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
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //---------------------------COPERTINA DEL FILM
          ClipRRect(
            borderRadius: BorderRadius.circular(10), //angoli arrotondati
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

          const SizedBox(height: 6),

          // TITOLO DEL FILM
          SizedBox(
            width: width,
            child: Text(
            title,
            maxLines: 1,         // <-- permette di andare a capo
            overflow: TextOverflow.ellipsis, // <-- aggiunge "…" se troppo lungo
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
