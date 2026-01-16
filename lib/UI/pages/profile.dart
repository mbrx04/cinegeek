import 'package:cinegeek/UI/pages/movie_grid_page.dart';
import 'package:flutter/material.dart';
import '../widgets/top_bar.dart';

/// Pagina profilo utente, mostra avatar, username e menu di navigazione
class Profile extends StatelessWidget {
  final String username;  // Username dinamico passato al profilo
  final String avatar;    // Percorso avatar (potresti usarlo per immagini personalizzate)

  const Profile({
    super.key,
    required this.username,
    required this.avatar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Logo in alto (widget personalizzato)
          const TopBarLogo(),

          // Contenuto scrollabile sotto il logo
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar utente (qui immagine statica di default)
                  const CircleAvatar(
                    radius: 55,
                    backgroundImage: AssetImage('assets/images/default.avatar.png'),
                  ),
                  const SizedBox(height: 16),

                  // Username dinamico mostrato in modo grande e in grassetto
                  Text(
                    username,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Voci del menu del profilo, con azione di tap per navigazione
                  _ProfileMenuItem(
                    title: 'Impostazioni',
                    onTap: () {
                      // TODO: Implementa navigazione pagina impostazioni
                    },
                  ),
                  _ProfileMenuItem(
                    title: 'Amici',
                    onTap: () {
                      // TODO: Implementa navigazione pagina amici
                    },
                  ),
                  _ProfileMenuItem(
                    title: 'Watchlist',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MovieGridPage(
                            username: username,
                            title: 'Watchlist',
                            type: MovieCollectionType.watchlist,
                          ),
                        ),
                      );
                    },
                  ),
                  _ProfileMenuItem(
                    title: 'Piaciuti',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MovieGridPage(
                            username: username,
                            title: 'Piaciuti',
                            type: MovieCollectionType.liked,
                          ),
                        ),
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

/// Widget privato che rappresenta ogni voce cliccabile del menu profilo
class _ProfileMenuItem extends StatelessWidget {
  final String title;          // Titolo voce menu
  final VoidCallback? onTap;   // Callback da eseguire al tap

  const _ProfileMenuItem({
    required this.title,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: onTap,  // Rileva il tap e richiama la callback
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey, width: 0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 18),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
