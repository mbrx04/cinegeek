import 'package:flutter/material.dart';
import '../../widgets/circle_button.dart';
import '../../widgets/top_bar.dart';
import '../../widgets/cineGlassButton.dart';
import '../../widgets/cineGlassTextField.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

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
                  Text("Registrazione", style: textTheme.headlineMedium),
                  const SizedBox(height: 32),

                  const CineGlassTextField(hint: "Email"),
                  const SizedBox(height: 16),
                  const CineGlassTextField(hint: "Password", obscure: true),
                  const SizedBox(height: 16),
                  const CineGlassTextField(hint: "Conferma password", obscure: true),
                  const SizedBox(height: 32),

                  const CineGlassButton(label: "Crea account"),
                ],
              ),
            ),
          ),

          // Pulsante indietro in basso a sinistra
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
