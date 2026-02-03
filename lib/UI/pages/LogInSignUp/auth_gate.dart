import 'package:cinegeek/UI/pages/LogInSignUp/log_in_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../main.dart';

class AuthGate extends StatelessWidget
{
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context)
  {
    return StreamBuilder<User?>
    (
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot)
      {
        //se sta caricando
        if (snapshot.connectionState == ConnectionState.waiting)
        {
          return const Scaffold(body: Center(child: CircularProgressIndicator()),);
        }

        //se l'utente è loggato va alla Home
        if (snapshot.hasData)
        {
          return const MainNavigation(); 
        }

        //se non è loggato va al Login
        return const LoginPage();
      },
    );
  }
}