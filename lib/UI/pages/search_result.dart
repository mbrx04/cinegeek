import 'package:flutter/material.dart';

class SearchResultsPage extends StatelessWidget {
  final String query;

  const SearchResultsPage({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    //se non c'è testo dice di cercare un film
    if (query.isEmpty) {
      return Center(
        child: Text(
          "Cerca un film...",
          style: TextStyle(color: Colors.white.withAlpha(128), fontSize: 18),
        ),
      );
    }

    //API QUANDO CI SARANNO!!!!!!!!!!!!!
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 120),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Risultati per \"$query\"",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 50),
          
          Center(
            child: Column(
              children: [
                const Text(
                  "ancora non ci sono le API non so dove cercare...",
                  style: TextStyle(color: Colors.white54),
                ),
                Text(
                  "query attuale: $query",
                  style: const TextStyle(color: Colors.white24, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}