import 'package:cinegeek/UI/pages/LogInSignUp/sign_up_page.dart';
import 'package:flutter/material.dart';
import '../../../main.dart';
import '../../../services/auth_service.dart';
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
    final theme = Theme.of(context);

    return Scaffold
    (
      body:
      Column
      (
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
        [
          const TopBarLogo(),
          const SizedBox(height: 40),

          Expanded
          (
            child:
            SingleChildScrollView
            (
              child:
              Padding
              (
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child:
                Column
                (
                  children:
                  [
                    Text("Log In", style: theme.textTheme.headlineMedium),
                    const SizedBox(height: 60),

                    Container
                      (
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(border: Border.all(color: theme.colorScheme.outline.withAlpha(77)), borderRadius: BorderRadius.circular(12),),
                      child:
                      Column
                      (
                        children:
                        [
                          const SizedBox(height: 16),
                          CineGlassTextField(hint: "Email", controller: emailController),

                          const SizedBox(height: 16),
                          CineGlassTextField(hint: "Password", obscure: true, controller: passwordController),

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    CineGlassButton
                    (
                        label: "Accedi",
                        onTap: () async
                        {
                          final navigator = Navigator.of(context);
                          final messenger = ScaffoldMessenger.of(context);
                          final email = emailController.text.trim();
                          final password = passwordController.text.trim();

                          if (email.isEmpty || password.isEmpty)
                          {
                            messenger.showSnackBar(const SnackBar(content: Text("Inserisci email e password")));
                            return;
                          }

                          try
                          {
                            final user = await authService.logIn(email: email, password: password);

                            if (user != null)
                            {
                              navigator.pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const MainNavigation()), (route) => false,);
                            }
                            else
                            {
                              messenger.showSnackBar(const SnackBar(content: Text("Credenziali non valide")));
                            }
                          }
                          catch (e)
                          {
                            messenger.showSnackBar(const SnackBar(content: Text("Login fallito")));
                          }
                        }
                    ),

                    const SizedBox(height: 24),

                    GestureDetector
                    (
                      onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpPage()),);},
                      child: Row
                      (
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:
                        [
                          Text("Non Hai un Account? ", style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(178), fontSize: 14),),
                          Text("Registrati", style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 14,),),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ]
      ),
    );
  }
}

