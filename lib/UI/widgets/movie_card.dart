import "package:flutter/material.dart";

class MovieCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final double width;
  final double height;
  final VoidCallback? onTap; 
  final VoidCallback? onLongPress;
  final String? heroTag;

  const MovieCard({ 
    super.key,
    required this.imageUrl,
    required this.title,
    this.width = 130,
    this.height = 200,
    this.onTap,
    this.onLongPress,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, 
      onLongPress: onLongPress, 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //animazione hero
          Hero(
            //se il padre passa un tag hero lo usa altrimenti usa l'url ddella foto
            tag: heroTag ?? imageUrl, 
            child: ClipRRect(
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
          // Titolo
          SizedBox(
            width: width,
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
        ],
      ),
    );
  }
}