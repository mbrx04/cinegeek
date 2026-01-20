import 'package:cinegeek/services/auth_service.dart';
import 'package:cinegeek/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../widgets/top_bar.dart';
import '../widgets/review_card.dart';
import '../widgets/circle_button.dart';
import 'movie_detail.dart';
import 'write_review.dart';
import 'review_detail_page.dart';

class ReviewsPage extends StatefulWidget {
  const ReviewsPage({super.key});

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  //lista uid amici
  List<String> _friendIds = [];
  bool _isLoadingFriends = true;

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  //carica lista amici
  Future<void> _loadFriends() async {
    try {
      final friendsList = await _authService.getFriends();
      
      //estrae solo uid amici
      final ids = friendsList.map((friend) => friend['uid'].toString()).toList();
      
      if (mounted) {
        setState(() {
          _friendIds = ids;
          _isLoadingFriends = false;
        });
      }
    } catch (e) {
      print("Errore caricamento amici: $e");
      if (mounted) {
        setState(() => _isLoadingFriends = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      //scrivi recensioni tasto
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Recensioni Amici", 
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),
          
          Expanded(
            child: _isLoadingFriends 
              ? const Center(child: CircularProgressIndicator()) // Aspettiamo di sapere chi sono gli amici
              : StreamBuilder<QuerySnapshot>(
                  stream: _firestoreService.getGlobalReviewsStream(),
                  builder: (context, snapshot) {
                    
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Color(0xFFCCFF00))
                      );
                    }

                    if (snapshot.hasError) {
                      return const Center(child: Text("Errore nel caricamento recensioni"));
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text("Nessuna recensione trovata.", style: TextStyle(color: Colors.grey)),
                      );
                    }

                    //solo recensioni amici
                    final allDocs = snapshot.data!.docs;
                    
                    final friendReviews = allDocs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final String authorId = data['userId'] ?? '';
                      
                      //lascio la recensione solo se è nella lista di amici
                      return _friendIds.contains(authorId);
                    }).toList();

                    //per amici senza recensioni la pagina rimane vuota
                    if (friendReviews.isEmpty) {
                      return const Center(
                        child: Text(
                          "Nessun amico ha ancora scritto recensioni.\nAggiungi amici o aspetta che scrivano qualcosa!",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                      itemCount: friendReviews.length,
                      itemBuilder: (context, index) {
                        final data = friendReviews[index].data() as Map<String, dynamic>;
                        
                        final String title = data['movieTitle'] ?? 'Sconosciuto';
                        final String poster = data['moviePosterUrl'] ?? '';
                        // Fix per il nome utente vuoto:
                        final String username = (data['username'] != null && data['username'].toString().isNotEmpty) 
                            ? data['username'] 
                            : 'Utente Sconosciuto';
                            
                        final String text = data['text'] ?? '';
                        final double rating = (data['rating'] ?? 0).toDouble();
                        final int movieId = int.tryParse(data['movieId'].toString()) ?? 0;

                        final String tag = "review_${friendReviews[index].id}"; 

                        return ReviewCard(
                          movieTitle: title,
                          posterUrl: poster,
                          username: username,
                          reviewText: text,
                          rating: rating,
                          heroTag: tag, 
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ReviewDetailPage(
                                  movieTitle: title,
                                  posterUrl: poster,
                                  username: username,
                                  reviewText: text, //testo della recensione
                                  rating: rating, //voto della recensione
                                  heroTag: tag,
                                ),
                              ),
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
}