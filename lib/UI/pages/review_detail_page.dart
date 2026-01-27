import 'package:flutter/material.dart';
import '../widgets/circle_button.dart';
import '../widgets/star_rating.dart';

class ReviewDetailPage extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String reviewText;
  final String author;
  final double voteAverage;
  final String heroTag;

  const ReviewDetailPage({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.reviewText,
    required this.author,
    required this.voteAverage,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              //copertina grande
              SliverAppBar(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                expandedHeight: 550,
                pinned: true,
                leading: const SizedBox(),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: heroTag,
                        child: Image.network(imageUrl, fit: BoxFit.cover, alignment: Alignment.topCenter),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Theme.of(context).scaffoldBackgroundColor.withOpacity(0.0),
                              Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
                              Theme.of(context).scaffoldBackgroundColor,
                            ],
                            stops: const [0.0, 0.6, 0.85, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter( //contenuto della recensione
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      //titolo film
                      Text(title, textAlign: TextAlign.center, style: textTheme.headlineLarge),
                      const SizedBox(height: 10),

                      //voto in stelline seleizonate dall'utente che ha recensito
                      StarRating(rating: voteAverage, itemSize: 35),
                      
                      const SizedBox(height: 10),
                      
                      Row(  //autore della recensione
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.person, size: 16, color: Colors.grey),
                          const SizedBox(width: 5),
                          Text("Recensione di $author", style: const TextStyle(color: Colors.grey)),
                        ],
                      ),

                      const SizedBox(height: 30),

                      Align(  //tasto recensione
                        alignment: Alignment.centerLeft, 
                        child: Text("Recensione", style: textTheme.headlineSmall)
                      ),
                      const SizedBox(height: 12),
                      
                      //testo della recensione
                      Text(
                        reviewText,
                        style: textTheme.bodyMedium,
                        textAlign: TextAlign.left,
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),

          //tasto back in alto a sx
          Positioned(
            top: 50,
            left: 20,
            child: CircleButton(
              size: 45,
              icon: Icons.arrow_back,
              backgroundColor: Colors.black.withOpacity(0.5),
              iconColor: Colors.white,
              borderColor: Colors.transparent,
              onTap: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}