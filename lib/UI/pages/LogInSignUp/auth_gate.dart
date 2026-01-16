import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../home.dart';
import '../../widgets/navbar.dart';
import '../../../main.dart';
import 'auth_landing_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        //se sta caricando
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        //se l'utente è loggato va alla Home
        if (snapshot.hasData) {
          return const MainNavigation(); 
        }

        //se non è loggato va al Login
        return const AuthLandingPage();
      },
    );
  }
}