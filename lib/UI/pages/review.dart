import 'package:cinegeek/services/auth_service.dart';
import 'package:cinegeek/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/top_bar.dart';
import '../widgets/review_card.dart';
import '../widgets/circle_button.dart';
import '../../model/review.dart' as model;
import 'movie_detail.dart';
import 'write_review.dart';

class ReviewsPage extends StatefulWidget {
  const ReviewsPage({super.key});

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  late Future<List<String>> _friendIdsFuture; //uid degli amici

  @override
  void initState() {
    super.initState();
    _friendIdsFuture = _loadFriendIds();
  }

  Future<List<String>> _loadFriendIds() async { //estrae solo uid degli amici
    final friendsMap = await _authService.getFriends();
    List<String> ids = friendsMap.map((f) => f['uid'] as String).toList();
    return ids;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Padding(  //tasto scrivi recensioni
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Recensioni", 
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),
          
          Expanded(
            //carica la lista degli amici
            child: FutureBuilder<List<String>>(
              future: _friendIdsFuture,
              builder: (context, friendSnapshot) {
                
                //carica gli amici
                if (friendSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final friendIds = friendSnapshot.data ?? [];

                if (friendIds.isEmpty) {
                  return _buildEmptyState(context, "Non hai ancora amici (o tu)!\nAggiungili dal profilo per vedere qui le loro recensioni.");
                }

                //prendo le recensioni degli amici
                return StreamBuilder<List<model.Review>>(
                  stream: _firestoreService.getFriendsReviews(friendIds),
                  builder: (context, reviewSnapshot) {
                    
                    if (reviewSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (reviewSnapshot.hasError) {
                      return Center(child: Text("Errore caricamento: ${reviewSnapshot.error}"));
                    }

                    final reviews = reviewSnapshot.data ?? [];

                    if (reviews.isEmpty) {
                      return _buildEmptyState(context, "I tuoi amici non hanno ancora scritto recensioni.\nSii il primo!");
                    }

                    //vera lista degli amici
                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                      itemCount: reviews.length,
                      itemBuilder: (context, index) {
                        final review = reviews[index];
                        final String tag = "review_${review.id}_$index"; 

                        return ReviewCard(
                          movieTitle: review.movieTitle,
                          posterUrl: review.moviePosterUrl,
                          username: review.username,
                          reviewText: review.text,
                          rating: review.rating,
                          heroTag: tag, 

                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MovieDetailPage(
                                  movieId: int.tryParse(review.movieId) ?? 0,
                                  title: review.movieTitle,
                                  imageUrl: review.moviePosterUrl,
                                  description: review.text,
                                  voteAverage: review.rating, 
                                  heroTag: tag, 
                                  showStars: true,
                                  isPopup: true,
                                ),
                              ),
                            );
                          },
                        );
                      },
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

  Widget _buildEmptyState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 60, color: Colors.grey.withOpacity(0.5)),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.withOpacity(0.8), fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}