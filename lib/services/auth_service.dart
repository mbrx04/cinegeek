import 'package:firebase_auth/firebase_auth.dart';
import '../model/app_user.dart';

class AuthService
{
  final FirebaseAuth _firebaseAuth=FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<AppUser?> logIn
    (
      {
        required String email,
        required String password,
      }
    ) async
      {
        final credential= await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);

        final user=credential.user;

        if (user==null)
          return null;

        return AppUser.fromFirebase(user.uid, user.email!);
      }

  Future<AppUser?> signUp
    (
      {
        required String email,
        required String password,
      }
    ) async
      {
        try
        {
          final credential = await _firebaseAuth.createUserWithEmailAndPassword(
              email: email, password: password);
          final user = credential.user;

          if (user == null)
            return null;

          return AppUser.fromFirebase(user.uid, user.email!);
        } catch(e)
          {
            print("Login error: $e");
            return null;
          }
      }

  Future<void> logOut() async
    {
      await _firebaseAuth.signOut();
    }

  Future<AppUser?> getCurrentUser() async
  {
    final user=_firebaseAuth.currentUser;
    if (user==null)
      return null;
    return AppUser.fromFirebase(user.uid, user.email!);
  }

}
