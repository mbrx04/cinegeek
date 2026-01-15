import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/app_user.dart';

class AuthService
{
  final FirebaseAuth _firebaseAuth=FirebaseAuth.instance;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Verifica se lo username esiste già (usato nel signup)
  Future<bool> isUsernameUnique(String username) async
  {
    final query = await _db.collection('users').where('username', isEqualTo: username).get();
    return query.docs.isEmpty;
  }

  Future<AppUser?> _fetchUserData(String uid) async
  {
    final doc = await _db.collection('users').doc(uid).get();

    if (doc.exists && doc.data() != null)
      return AppUser.fromFirestore(doc.data()!);

    return null;
  }

  Future<AppUser?> logIn
    (
      {
        required String email,
        required String password,
      }
    ) async
      {
        try
        {
          final credential = await _firebaseAuth.signInWithEmailAndPassword(
              email: email, password: password);

          final user = credential.user;

          if (user == null)
            return null;

          return await _fetchUserData(credential.user!.uid);
        }
        catch(e)
        {
          print("Login error: $e");
          return null;
        }
      }

  Future<AppUser?> signUp
    (
      {
        required String email,
        required String password,
        required String username,
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

          final newUser=AppUser(uid: user.uid, email: email, username: username);

          await _db.collection('users').doc(newUser.uid).set(newUser.toMap());

          return newUser;

        } catch(e)
          {
            print("SignUp error: $e");
            return null;
          }
      }

  Future<void> logOut() async
    {
      await _firebaseAuth.signOut();
    }

  Future<AppUser?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;

    return await _fetchUserData(user.uid);
  }

}
