import 'package:flutter/material.dart';
import 'star_rating.dart';

class ReviewCard extends StatelessWidget {
  final String movieTitle;
  final String posterUrl;
  final String username;
  final String reviewText;
  final double rating;
  final VoidCallback? onTap;
  final String? heroTag;

  const ReviewCard({
    super.key,
    required this.movieTitle,
    required this.posterUrl,
    required this.username,
    required this.reviewText,
    required this.rating,
    this.onTap,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;  //rileva il tema

    //tema chiaro e scuro
    final Color cardBackground = isDark 
        ? Colors.white.withAlpha(13) 
        : Colors.black.withAlpha(10); 

    final Color cardBorder = isDark 
        ? Colors.white.withAlpha(26) 
        : Colors.black.withAlpha(30);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cardBorder),//bordo per tema chiaro e scuro
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //copertina piccola con hero
            Hero(
              tag: heroTag ?? posterUrl, 
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  posterUrl,
                  width: 60,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (_,__,___) => Container(width: 60, height: 90, color: Colors.grey),
                ),
              ),
            ),
            
            const SizedBox(width: 12),

            //vero contenuto della recensione
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movieTitle,
                    style: Theme.of(context).textTheme.headlineMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      //icona dell'utente
                      Icon(Icons.person, size: 14, color: isDark ? Colors.grey : Colors.black54),
                      const SizedBox(width: 4),
                      Text(
                        username,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  StarRating(rating: rating, itemSize: 16),
                  const SizedBox(height: 8),
                  Text(
                    reviewText,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}