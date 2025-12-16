import 'package:flutter/material.dart';
import '../widgets/circle_button.dart';
import '../widgets/top_bar.dart';
import '../widgets/cineGlassButton.dart';
import '../widgets/cineGlassTextField.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar con logo
          const TopBarLogo(),

          const SizedBox(height: 50), // spazio tra logo e contenuto

          // Contenuto centrale
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Login", style: textTheme.headlineMedium),
                  const SizedBox(height: 32),

                  const CineGlassTextField(hint: "Email"),
                  const SizedBox(height: 16),

                  const CineGlassTextField(hint: "Password", obscure: true),
                  const SizedBox(height: 32),

                  const CineGlassButton(label: "Accedi"),
                ],
              ),
            ),
          ),

          // Pulsante indietro in basso a sinistra (opzionale)
          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 20),
            child: CircleButton(
              icon: Icons.arrow_back,
              onTap: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}