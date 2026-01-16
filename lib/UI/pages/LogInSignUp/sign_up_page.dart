import 'package:cinegeek/main.dart';
import 'package:cinegeek/services/auth_service.dart';
import 'package:flutter/material.dart';
import '../../widgets/circle_button.dart';
import '../../widgets/top_bar.dart';
import '../../widgets/cineGlassButton.dart';
import '../../widgets/cineGlassTextField.dart';

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

  // DENTRO sign_up_page.dart

  Future<void> _signUp(BuildContext context) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    final username = usernameController.text.trim();

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      messenger.showSnackBar(const SnackBar(content: Text("Tutti i campi sono obbligatori")));
      return;
    }
    if (password != confirmPassword) {
      messenger.showSnackBar(const SnackBar(content: Text("Le password non coincidono")));
      return;
    }

    try {
      // 1. Controllo username unico
      bool isUnique = await authService.isUsernameUnique(username);
      if (!isUnique) {
        messenger.showSnackBar(const SnackBar(content: Text("Username già occupato, scegline un altro")));
        return;
      }

      // 2. Prova a registrare
      // IMPORTANTE: Salviamo il risultato in una variabile 'result'
      final result = await authService.signUp(
          email: email, 
          password: password, 
          username: username
      );

      // 3. SE result è null, vuol dire che c'è stato un errore nel Service (es. permessi DB)
      if (result == null) {
        messenger.showSnackBar(const SnackBar(content: Text("Errore salvataggio dati. Controlla connessione o regole Firebase.")));
        return; // FERMATI QUI! Non navigare.
      }

      // 4. Se siamo qui, è andato tutto bene.
      // Non serve fare pushAndRemoveUntil perché c'è l'AuthGate che ascolta!
      // Ma se vuoi essere sicuro, puoi lasciare il pop per tornare indietro
      if (mounted) {
         // Chiudiamo la tastiera
         FocusScope.of(context).unfocus(); 
         // AuthGate nel main.dart vedrà il login e cambierà pagina da solo.
         // Possiamo solo fare un pop per chiudere la pagina di registrazione.
         navigator.pop(); 
      }

    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text("Eccezione: $e")));
    }
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
            child:
            Center
            (
              child:
              Column
              (
                mainAxisSize: MainAxisSize.min,
                children:
                [
                  Text("Registrazione", style: textTheme.headlineMedium),

                  const SizedBox(height: 32),
                  CineGlassTextField
                    (
                    hint: "Username",
                    controller: usernameController,
                  ),
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

                  const SizedBox(height: 16),
                  CineGlassTextField
                  (
                    hint: "Conferma password",
                    obscure: true,
                    controller: confirmPasswordController,
                  ),

                  const SizedBox(height: 32),
                  CineGlassButton(label: "Crea account", onTap:() {_signUp(context);}),
                ],
              ),
            ),
          ),

          //Padding
          //(
          //  padding: const EdgeInsets.only(left: 20, bottom: 20),
          //  child:
          //  CircleButton
          //  (
          //    icon: Icons.arrow_back,
          //    onTap: () => Navigator.pop(context),
          //  ),
          //),
        ],
      ),
    );
  }
}
