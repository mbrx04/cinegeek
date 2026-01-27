import 'package:flutter/material.dart';
import '../../model/movie.dart';

class MovieSearchResults extends StatelessWidget {
  final List<Movie> results;
  final Function(Movie) onSelect;

  const MovieSearchResults({
    super.key,
    required this.results,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    final Color dropdownColor = isDark 
        ? Colors.black.withAlpha(230) 
        : Colors.white.withAlpha(240);
        
    final Color borderColor = isDark 
        ? Colors.white.withAlpha(26) 
        : Colors.black.withAlpha(26);
    
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color hintColor = isDark ? Colors.white70 : Colors.black54;

    return Container( //lista a tendina
      margin: const EdgeInsets.only(top: 8),
      constraints: const BoxConstraints(maxHeight: 250), 
      decoration: BoxDecoration(
        color: dropdownColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: ListView.separated(  //liste lunghe quindi divido gli elementi
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          itemCount: results.length,
          separatorBuilder: (ctx, i) => Divider(color: borderColor, height: 1),
          itemBuilder: (context, index) {
            final movie = results[index];
            return ListTile(
              leading: ClipRRect( //piccola copertina del film affianco il titolo
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  movie.fullPosterUrl,
                  width: 40,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_,__,___) => Icon(Icons.movie, color: textColor),
                ),
              ),
              title: Text(  //titolo del film
                movie.title,
                style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
              ),
              subtitle: Text( //anno di uscita del film sotto il titolo
                movie.releaseDate.isNotEmpty ? movie.releaseDate.split('-').first : 'N/A',
                style: TextStyle(color: hintColor, fontSize: 12),
              ),
              onTap: () => onSelect(movie),
            );
          },
        ),
      ),
    );
  }
}