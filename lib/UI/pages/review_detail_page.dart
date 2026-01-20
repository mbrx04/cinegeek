import 'package:flutter/material.dart';
import '../widgets/circle_button.dart';
import '../widgets/star_rating.dart';

class ReviewDetailPage extends StatelessWidget {
  final String movieTitle;
  final String posterUrl;
  final String username;
  final String reviewText;
  final double rating;
  final String heroTag;

  const ReviewDetailPage({
    super.key,
    required this.movieTitle,
    required this.posterUrl,
    required this.username,
    required this.reviewText,
    required this.rating,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    //colori del tema automatico
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color subTextColor = isDark ? Colors.grey : Colors.black54;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 100, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //locandina
                Hero(
                  tag: heroTag,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        posterUrl,
                        height: 300,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 300, 
                          width: 200, 
                          color: Colors.grey,
                          child: const Icon(Icons.movie, size: 50),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                //titolo del film
                Text(
                  movieTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                //autore della recensione
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.grey.withOpacity(0.3),
                      child: Icon(Icons.person, size: 16, color: textColor),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Recensione di ",
                      style: TextStyle(color: subTextColor, fontSize: 16),
                    ),
                    Text(
                      username,
                      style: TextStyle(
                        color: textColor, 
                        fontSize: 16, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                //voot con le stelline
                StarRating(
                  rating: rating,
                  itemSize: 30,
                  isInteractive: false, //solo leggere
                ),

                const SizedBox(height: 30),

                //vero testo della recensione
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.format_quote, size: 40, color: Colors.grey),
                      const SizedBox(height: 10),
                      Text(
                        reviewText,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.5,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          //tasto Back in alto a sinistra
          Positioned(
            top: 50,
            left: 20,
            child: CircleButton(
              size: 45,
              icon: Icons.arrow_back,
              backgroundColor: Colors.black.withOpacity(0.5),
              iconColor: Colors.white,
              onTap: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}