import 'dart:ui';
import 'package:flutter/material.dart';

class MoviePreviewPopup extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String description;
  final String? heroTag;

  const MoviePreviewPopup({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.description,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),  //se clicchiamo fuori del popup lo chiude
      child: Scaffold(
        backgroundColor: Colors.transparent, 
        body: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), 
          child: Container(
            color: Colors.black.withOpacity(0.3), 
            child: Center(
              child: GestureDetector(
                onTap: () {}, 
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  width: 260,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          imageUrl,
                          width: 200,
                          height: 300,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => 
                              const Icon(Icons.error, size: 50, color: Colors.red),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      //descrizione di massimo 4 righe
                      Text(
                        description,
                        textAlign: TextAlign.center,
                        maxLines: 4,  
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}