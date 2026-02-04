import 'package:cinegeek/main.dart';
import 'package:cinegeek/services/auth_service.dart';
import 'package:flutter/material.dart';
import '../../widgets/circle_button.dart';
import '../../widgets/top_bar.dart';
import '../../widgets/cineGlassButton.dart';
import '../../widgets/cineGlassTextField.dart';
import 'log_in_page.dart';

class SignUpPage extends StatefulWidget
{
  const SignUpPage({super.key});
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage>
{
  final AuthService authService=AuthService();

  final TextEditingController emailController= TextEditingController();
  final TextEditingController passwordController=TextEditingController();
  final TextEditingController confirmPasswordController=TextEditingController();
  final TextEditingController usernameController=TextEditingController();

  @override
  void dispose ()
  {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }


  Future<void> _signUp(BuildContext context) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    final username = usernameController.text.trim();

    if (username.isEmpty || email.isEmpty || password.isEmpty)
    {
      messenger.showSnackBar(const SnackBar(content: Text("Tutti i campi sono obbligatori")));
      return;
    }

    if (password != confirmPassword)
    {
      messenger.showSnackBar(const SnackBar(content: Text("Le password non coincidono")));
      return;
    }

    try
    {
      // Controllo username unico
      bool isUnique = await authService.isUsernameUnique(username);
      if (!isUnique)
      {
        messenger.showSnackBar(const SnackBar(content: Text("Username già occupato, scegline un altro")));
        return;
      }

      // Prova a registrare
      final result = await authService.signUp(email: email, password: password, username: username);

      // SE result è null, vuol dire che c'è stato un errore nel Service (es. permessi DB)
      if (result == null)
      {
        messenger.showSnackBar(const SnackBar(content: Text("Errore salvataggio dati. Controlla connessione o regole Firebase.")));
        return;
      }

      navigator.pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const MainNavigation()), (route) => false,);

    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text("Eccezione: $e")));
    }
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
                    Text("Registrazione", style: theme.textTheme.headlineMedium),
                    const SizedBox(height: 50),

                    Container
                      (
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration( border: Border.all(color: theme.colorScheme.outline.withAlpha(77)), borderRadius: BorderRadius.circular(12),),
                      child:
                      Column
                      (
                        children:
                        [
                          CineGlassTextField(hint: "Username", controller: usernameController),
                          const SizedBox(height: 16),

                          CineGlassTextField(hint: "Email", controller: emailController),
                          const SizedBox(height: 16),

                          CineGlassTextField(hint: "Password", obscure: true, controller: passwordController),
                          const SizedBox(height: 16),

                          CineGlassTextField(hint: "Conferma password", obscure: true, controller: confirmPasswordController),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                    CineGlassButton(label: "Crea account", onTap: () => _signUp(context)),

                    const SizedBox(height: 24),

                    // Reinderizzamento Login
                    GestureDetector
                    (
                      onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage())),
                      child: Row
                      (
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:
                        [
                          Text("Hai un Account? ", style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(178), fontSize: 14,),),
                          Text("fai il Login", style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 14,),),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
