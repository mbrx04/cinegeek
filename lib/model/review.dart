class Review {
  final String id;
  final String userId;
  final String username;
  final String userPropic;
  final String movieId;
  final String movieTitle;
  final String moviePosterUrl;
  final String text;
  final double rating;
  final DateTime createdAt;

  Review({
    this.id = '',
    required this.userId,
    required this.username,
    this.userPropic = '',
    required this.movieId,
    required this.movieTitle,
    required this.moviePosterUrl,
    required this.text,
    required this.rating,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {  //conversione per firebase da oggetto a mappa
    return {
      'userId': userId,
      'username': username,
      'userPropic': userPropic,
      'movieId': movieId,
      'movieTitle': movieTitle,
      'moviePosterUrl': moviePosterUrl,
      'text': text,
      'rating': rating,
      'createdAt': createdAt.toIso8601String(),
    };
  }


  factory Review.fromMap(Map<String, dynamic> map, String documentId) { //conversine da mappa ad oggetto
    return Review(
      id: documentId,
      userId: map['userId'] ?? '',
      username: map['username'] ?? 'Anonimo',
      userPropic: map['userPropic'] ?? '',
      movieId: map['movieId'] ?? '',
      movieTitle: map['movieTitle'] ?? '',
      moviePosterUrl: map['moviePosterUrl'] ?? '',
      text: map['text'] ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}