import 'package:flutter/material.dart';
import '../widgets/top_bar.dart';
import '../widgets/review_card.dart';
import '../widgets/circle_button.dart';
import 'movie_detail.dart';
import 'write_review.dart';

class ReviewsPage extends StatelessWidget {
  const ReviewsPage({super.key});

  final List<Map<String, dynamic>> _mockReviews = const [
    {
      "title": "Fast X",
      "poster": "https://www.themoviedb.org/t/p/w200/hC6mLdlgpFU63FOduX80xaGevGj.jpg",
      "user": "Fragola86",
      "text": "Ottime premesse ma film brutto",
      "rating": 3.0
    },
    {
      "title": "Ferrari",
      "poster": "https://www.themoviedb.org/t/p/w1280/xnquC6Cn5BRBMz68231gIjXlbhj.jpg",
      "user": "Banana33",
      "text": "Ottimo per me, Banana33",
      "rating": 5.0
    },
    {
      "title": "Le Mans '66 - La grande sfida",
      "poster": "https://www.themoviedb.org/t/p/w1280/nKVOiiCukJsXNYPETbIWqZaBYd.jpg",
      "user": "Boom3r61",
      "text": "Non so che scrivere, vedi se si vede tutto il titolo dato che è lungvo",
      "rating": 1.0
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      //tasto per scrivere recensioni
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 120, right: 10),
        child: CircleButton(
          size: 60,
          icon: Icons.edit,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WriteReviewPage()),
            );
          },
        ),
      ),
      
      body: Column(
        children: [
          const TopBarLogo(),          
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Recensioni", 
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),
          
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
              itemCount: _mockReviews.length,
              itemBuilder: (context, index) {
                final review = _mockReviews[index];
                
                // CREAZIONE TAG HERO UNIVOCO
                final String tag = "review_${review['poster']}_$index"; 

                return ReviewCard(
                  movieTitle: review['title'],
                  posterUrl: review['poster'],
                  username: review['user'],
                  reviewText: review['text'],
                  rating: review['rating'],
                  heroTag: tag, 

                  onTap: () {
                    //CALLBACK DI NAVIGAZIONE
                    //review_card è un widget senza logica, detto puro. qui definiamo noi cosa succede al
                    //click. gli passiamo i dati della recensione alla pagina di dettaglio del film.
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MovieDetailPage(
                          title: review['title'],
                          imageUrl: review['poster'],
                          description: review['text'], 
                          voteAverage: (review['rating'] as num).toDouble(),
                          heroTag: tag, 
                          showStars: true,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}