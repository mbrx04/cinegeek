import 'package:flutter/material.dart';
import '../../widgets/top_bar.dart';
import '../../widgets/cineGlassButton.dart';
import 'logInPage.dart';
import 'signUpPage.dart';

class AuthLandingPage extends StatelessWidget {
  const AuthLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TopBarLogo(),

          const SizedBox(height: 50), // spazio tra logo e contenuto

          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Benvenuto",
                    style: textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 40),
                  CineGlassButton(
                    label: "Login",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  CineGlassButton(
                    label: "Registrati",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignUpPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

  }
}
