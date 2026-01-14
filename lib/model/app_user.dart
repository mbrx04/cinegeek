class AppUser {
  final String uid;
  final String email;

  AppUser({
    required this.uid,
    required this.email,
  });

  factory AppUser.fromFirebase(String uid, String email) {
    return AppUser(
      uid: uid,
      email: email,
    );
  }
}
