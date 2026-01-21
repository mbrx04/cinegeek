class AppUser
{
  final String uid;
  final String email;
  String username;

  AppUser
  ({
    required this.uid,
    required this.email,
    required this.username,
  });


  factory AppUser.fromFirestore(Map<String, dynamic> data) {
    return AppUser(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      username: data['username']  ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
    };
  }
}
