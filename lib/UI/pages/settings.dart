import 'package:flutter/material.dart';
import 'package:cinegeek/services/auth_service.dart';
import 'package:cinegeek/UI/theme.dart';
import '../widgets/circle_button.dart';
import '../widgets/top_bar.dart';

class SettingsPage extends StatefulWidget
{
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
{
  final _authService = AuthService();
  final _userController = TextEditingController();



  @override
  Widget build(BuildContext context) {
    final navigator=Navigator.of(context);
    final messenger=ScaffoldMessenger.of(context);
    return Scaffold(
      body:
      Column
      (
        children:
        [
          Row
            (
              children:
              [
                SizedBox(width: 40, height: 40, child: CircleButton(icon: Icons.arrow_back, onTap: () => navigator.pop(),),),
                Expanded(child: Align(alignment: Alignment.center,child: const TopBarLogo())),
                const SizedBox(width: 40)
              ]
          ),

          Expanded
          (
            child:
            ListView
            (
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children:
              [
                const SizedBox(height: 20),

                const Text("PROFILO", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),),

                const SizedBox(height: 15),

                const Center(child: CircleAvatar(radius: 50, backgroundColor: Colors.blueGrey, child: Icon(Icons.person, size: 50, color: Colors.white),),),

                Center
                (
                  child: TextButton
                  (
                    child:
                    const Text("Cambia foto", style: TextStyle(color: AppTheme.primaryLime)),
                    onPressed: ()
                    {
                      messenger.showSnackBar(const SnackBar(content: Text("Funzionalità in Arrivo")));
                    }
                  ),
                ),

                const SizedBox(height: 10),

                ListTile
                (
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  tileColor: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(77),
                  leading: const Icon(Icons.edit, size: 20),
                  title: const Text("Username"),
                  subtitle: const Text("Modifica il tuo nome pubblico"),
                  onTap: ()
                  {
                    showDialog
                    (
                      context: context,
                      builder: (context) =>
                      AlertDialog
                      (
                        title: const Text("Nuovo Username"),
                        content: TextField
                        (
                          controller: _userController,
                          autofocus: true,
                          decoration: const InputDecoration(hintText: "Scrivi qui..."),
                        ),
                        actions:
                        [
                          TextButton(onPressed: () => navigator.pop(), child: const Text("Chiudi")),
                          ElevatedButton
                          (
                            onPressed: () async
                            {
                              if (_userController.text.isNotEmpty)
                              {
                                await _authService.setUsername(_userController.text.trim());
                                if (mounted) navigator.pop();
                              }
                            },
                            child: const Text("Salva"),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 30),

                const Text("TEMA", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),),

                const SizedBox(height: 15),

                Container
                (
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(77), borderRadius: BorderRadius.circular(20),),
                  child:
                  ValueListenableBuilder<ThemeMode>
                  (
                    valueListenable: themeNotifier,
                    builder: (context, currentMode, _ )
                    {
                      return
                      Column
                      (
                        children:
                        [
                          _optionTile("Sistema", Icons.brightness_auto, ThemeMode.system, currentMode),

                          Divider(height: 1, color: Colors.white.withAlpha(13), indent: 55),

                          _optionTile("Chiaro", Icons.light_mode, ThemeMode.light, currentMode),

                          Divider(height: 1, color: Colors.white.withAlpha(13), indent: 55),

                          _optionTile("Scuro", Icons.dark_mode, ThemeMode.dark, currentMode),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _optionTile(String label, IconData icon, ThemeMode mode, ThemeMode current)
  {
    final active = current == mode;
    return ListTile
    (
      leading: Icon(icon, color: active ? AppTheme.primaryLime : Colors.grey),
      title: Text(label, style: TextStyle(color: active ? Colors.white : Colors.grey)),
      trailing: active ? const Icon(Icons.check, color: AppTheme.primaryLime, size: 20) : null,
      onTap: () => themeNotifier.value = mode,
    );
  }
}