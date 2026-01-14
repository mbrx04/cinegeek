import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/auth_service.dart';
import 'auth_landing_page.dart';
import '../../../main.dart';

class AuthGate extends StatelessWidget
{
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return FutureBuilder
      (
        future: authService.getCurrentUser(),
        builder: (context, snapshot)
        {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Scaffold(body: Center(child: CircularProgressIndicator()),);

          if (snapshot.hasData)
            return const MainNavigation();

          return const AuthLandingPage();
        }
      );
  }
}
