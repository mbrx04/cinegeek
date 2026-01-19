
class Review {
  final String userId;
  final String username;
  final String text;
  final double rating;
  final DateTime createdAt;

  Review({
    required this.userId,
    required this.username,
    required this.text,
    required this.rating,
    required this.createdAt,
  });

  Map<String, dynamic> toMap(){
    return{
      'userId': userId,
      'username': username,
      'text': text,
      'rating': rating,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      userId: map['userId'],
      username: map['username'],
      text: map['text'],
      rating: (map['rating'] as num).toDouble(),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}