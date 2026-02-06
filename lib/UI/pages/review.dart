import 'package:cinegeek/services/auth_service.dart';
import 'package:cinegeek/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/top_bar.dart';
import '../widgets/review_card.dart';
import '../widgets/circle_button.dart';
import '../../model/review.dart' as model;
import 'write_review.dart';
import 'review_detail_page.dart';

class ReviewsPage extends StatefulWidget {
  const ReviewsPage({super.key});

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  late Future<List<String>> _friendIdsFuture;
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState()
  {
    super.initState();
    _loadData();
  }

  // Caricamento dati iniziale e per refresh
  void _loadData()
  {
    setState(()
    {
      _friendIdsFuture = _loadFriendIds();
    });
  }

  Future<List<String>> _loadFriendIds() async {
    final friendsMap = await _authService.getFriends();
    return friendsMap.map((f) => f['uid'] as String).toList();
  }

  Future<void> _handleRefresh() async
  {
    _loadData();
    // Aspetto che il future degli amici completi per chiudere l'animazione del refresh
    await _friendIdsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: Theme.of(context).colorScheme.primary,
        edgeOffset: 0, // Offset per non apparire sotto il logo
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(), // Necessario per RefreshIndicator anche con poco contenuto
          padding: const EdgeInsets.only(top: 0, bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TopBarLogo(),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      "Feed",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 10),
                    _buildFriendsSection(),

                    const SizedBox(height: 30),
                    const Divider(color: Colors.grey, thickness: 0.5),
                    const SizedBox(height: 20),

                    Text(
                      "Le tue Recensioni",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 10),
                    _buildMySection(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFriendsSection() { //lista amici
    return FutureBuilder<List<String>>(
      future: _friendIdsFuture,
      builder: (context, friendSnapshot) {
        if (friendSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final friendIds = friendSnapshot.data ?? [];

        if (friendIds.isEmpty) {
          return _buildEmptyState("Non hai ancora amici. Aggiungili dal profilo!");
        }

        return StreamBuilder<List<model.Review>>(
          stream: _firestoreService.getFriendsReviews(friendIds),
          builder: (context, reviewSnapshot) {
            if (reviewSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (reviewSnapshot.hasError) {
              return Text("Errore: ${reviewSnapshot.error}");
            }

            final reviews = reviewSnapshot.data ?? [];

            if (reviews.isEmpty) {
              return _buildEmptyState("I tuoi amici non hanno scritto nulla di recente.");
            }

            return ListView.builder(  //lista recensioni amici
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),  //scrolla la pagina, forse non mi piace!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
              itemCount: reviews.length,
              itemBuilder: (context, index) => _buildReviewItem(reviews[index], index, "friend"),
            );
          },
        );
      },
    );
  }

  //lista recensioni personali
  Widget _buildMySection() {
    if (_currentUserId == null) return const Text("Devi essere loggato.");

    return StreamBuilder<List<model.Review>>(
      stream: _firestoreService.getReviewsByUser(_currentUserId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text("Errore: ${snapshot.error}");
        }

        final reviews = snapshot.data ?? [];

        if (reviews.isEmpty) {
          return _buildEmptyState("Non hai ancora scritto recensioni. Inizia ora!");
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reviews.length,
          itemBuilder: (context, index) => _buildReviewItem(reviews[index], index, "me"),
        );
      },
    );
  }

  //creazione singola review card
  Widget _buildReviewItem(model.Review review, int index, String prefix) {
    final String tag = "${prefix}_review_${review.id}_$index";

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
            builder: (_) => ReviewDetailPage(
              title: review.movieTitle,
              imageUrl: review.moviePosterUrl,
              reviewText: review.text,
              voteAverage: review.rating,
              author: review.username,
              heroTag: tag,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(20),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(77),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey.withAlpha(204), fontSize: 14),
      ),
    );
  }
}