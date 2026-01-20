import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

  Future<void> setUsername(String newOne) async
  {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;
    if (await isUsernameUnique(newOne))
    {
      final othersWithMe = await _db.collection('users').doc(user.uid).collection('friends').get();

      for(var friendDoc in othersWithMe.docs)
      {
        var friendUID =friendDoc.id;

        final selfInFriendList = _db.collection('users').doc(friendUID).collection('friends').doc(user.uid);

        final docSnapshot = await selfInFriendList.get();
        if (docSnapshot.exists)
        {
          await selfInFriendList.update({'username': newOne});
        }
      }
      await _db.collection('users').doc(user.uid).update({'username': newOne});
    }
    else
    {
      throw 'Errore, Operazione Non Completata';
    }
  }

  Future<AppUser?> fetchUserData(String uid) async
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

          return await fetchUserData(credential.user!.uid);
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
          final credential = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
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

  Future<AppUser?> getCurrentUser() async
  {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;

    return await fetchUserData(user.uid);
  }

  Future<String> lastWatched(String username) async
  {
    final user=await searchUser(username);
    if(user!=null)
    {
      QuerySnapshot query =await _db.collection('users').doc(user.uid).collection('watched').orderBy('timestamp',descending: true).get();

      if(query.docs.isNotEmpty)
      {
        final data= query.docs.first.data() as Map<String,dynamic>;
        return data['title'];
      }
    }
    return '';
  }

  Future<AppUser?> searchUser(String usernameTarget) async
  {
    QuerySnapshot query= await _db.collection('users').where('username',isEqualTo: usernameTarget).get();

    if(query.docs.isNotEmpty)
    {
        return AppUser.fromFirestore(query.docs.first.data() as Map<String,dynamic>);
    }
    return null;
  }

  Future<List<Map<String,dynamic>>> getFriends() async
  {
    final currentUser=_firebaseAuth.currentUser;
    if (currentUser!=null)
    {
      QuerySnapshot query= await _db.collection('users').doc(currentUser.uid).collection('friends').orderBy('addedAt',descending: true).get();

      return query.docs.map((doc)
      {
        final data = doc.data() as Map<String, dynamic>;
        return
        {
          'uid': doc.id,
          'username': data['username'],
          'propicURL': data['propicURL'],
        };
      }).toList();
    }
    return [];
  }

  Future<void> addFriend(String usernameTarget) async
  {
    try {
      AppUser? currentUser = await getCurrentUser();
      AppUser? friend = await searchUser(usernameTarget);
      if (currentUser == null || friend == null) {
        throw 'Utente Non Trovato';
      }

      var alreadyFriend = await _db
          .collection('users')
          .doc(currentUser.uid)
          .collection('friends')
          .doc(friend.uid)
          .get();

      if (alreadyFriend.exists) {
        throw 'Siete Già Amici';
      }
      else {
        await _db
            .collection('users')
            .doc(currentUser.uid)
            .collection('friends')
            .doc(friend.uid)
            .set({
          'uid': friend.uid,
          'username': friend.username,
          'propicURL': friend.propicURL,
          'addedAt': Timestamp.now(),
        });
        await _db.collection('users').doc(friend.uid).collection('friends').doc(
            currentUser.uid).set({
          'uid': currentUser.uid,
          'username': currentUser.username,
          'propicURL': currentUser.propicURL,
          'addedAt': Timestamp.now()
        });
      }
    }
    catch (e) {
      rethrow;
    }
  }

  Future<void> removeFriend(String uidTarget) async
  {
    try
    {
      final currentUserUID = _firebaseAuth.currentUser!.uid;

      await _db.collection('users').doc(currentUserUID).collection('friends').doc(uidTarget).delete();
      await _db.collection('users').doc(uidTarget).collection('friends').doc(currentUserUID).delete();
    }
    catch(e) {throw 'Errore in Rimozione';}
  }

}
