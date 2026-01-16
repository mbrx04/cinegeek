import 'package:flutter/material.dart';
import '../../../main.dart';
import '../../../services/auth_service.dart';
import '../../widgets/circle_button.dart';
import '../../widgets/top_bar.dart';
import '../../widgets/cineGlassButton.dart';
import '../../widgets/cineGlassTextField.dart';

class LoginPage extends StatefulWidget
{
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
{
  final AuthService authService = AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose()
  {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context)
  {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold
      (
      body:
      Column
      (
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
        [
          const TopBarLogo(),

          const SizedBox(height: 50),

          Expanded
          (
            child: Center
            (
              child: Column
              (
                mainAxisSize: MainAxisSize.min,
                children:
                [
                  Text("Login", style: textTheme.headlineMedium),
                  const SizedBox(height: 32),

                  CineGlassTextField
                  (
                    hint: "Email",
                    controller: emailController,
                  ),

                  const SizedBox(height: 16),

                  CineGlassTextField
                  (
                    hint: "Password",
                    obscure: true,
                    controller: passwordController,
                  ),

                  const SizedBox(height: 32),

                  CineGlassButton
                  (
                    label: "Accedi",
                    onTap: () async
                    {
                      final navigator = Navigator.of(context);
                      final messenger = ScaffoldMessenger.of(context);
                      final email=emailController.text.trim();
                      final password= passwordController.text.trim();

                      if (email.isEmpty || password.isEmpty)
                      {
                        messenger.showSnackBar
                        (
                          const SnackBar(content: Text("Inserisci email e password")),
                        );
                        return;
                      }
                      try {
                        final user = await authService.logIn(email: email, password: password,);

                        if (user != null)
                        {
                          navigator.pushAndRemoveUntil
                            (
                            MaterialPageRoute
                              (
                              builder: (context) => const MainNavigation(),
                            ),
                                (Route<dynamic> route) => false,
                          );
                        }
                        else
                        {
                          messenger.showSnackBar(const SnackBar(content: Text("Credenziali non valide")),);
                        }
                      }
                      catch (e)
                      {
                        messenger.showSnackBar
                        (
                          const SnackBar
                          (
                            content: Text("Login fallito"),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

          //Padding(
          //  padding: const EdgeInsets.only(left: 20, bottom: 20),
          //  child: CircleButton(
          //    icon: Icons.arrow_back,
          //    onTap: ()
          //      {
          //        Navigator.pop(context);
          //      }
          //  ),
          //),
        ],
      ),
    );
  }
}

