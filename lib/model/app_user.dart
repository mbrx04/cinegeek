class AppUser
{
  final String uid;
  final String email;
  final String username;
  String propicURL;

  AppUser
  ({
    required this.uid,
    required this.email,
    required this.username,
    this.propicURL=""
  });


  factory AppUser.fromFirestore(Map<String, dynamic> data) {
    return AppUser(
      uid: data['uid'] ,
      email: data['email'] ,
      username: data['username'] ,
      propicURL: data['propicURL'] = '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'propicURL': propicURL,
    };
  }
}
