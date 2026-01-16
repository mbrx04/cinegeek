import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../model/app_user.dart';
import '../../services/auth_service.dart';
import '../widgets/top_bar.dart';
import 'movie_grid_page.dart';
import 'LogInSignUp/auth_landing_page.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final AuthService _authService = AuthService();
  AppUser? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  //per caricare i dati dell'utente direttament da firebase
  Future<void> _loadUserData() async {
    final user = await _authService.getCurrentUser();
    if (mounted) {
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    }
  }

  //funzione logout
  Future<void> _handleLogout() async {
    await _authService.logOut();
    if (mounted) {
      //toglie l'utente e fa alla schermata di login
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthLandingPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_currentUser == null) {
      return const Scaffold(body: Center(child: Text("Utente non trovato")));
    }

    return Scaffold(
      body: Column(
        children: [
          const TopBarLogo(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar( //avatar di default a prescindere perchè a pagamento su firebase
                    radius: 55,
                    backgroundColor: Colors.grey.shade800,
                    backgroundImage: _currentUser!.propicURL.isNotEmpty
                        ? NetworkImage(_currentUser!.propicURL) as ImageProvider
                        : const AssetImage('assets/images/default_avatar.png'),
                    child: _currentUser!.propicURL.isEmpty 
                        ? const Icon(Icons.person, size: 50, color: Colors.white) 
                        : null,
                  ),
                  const SizedBox(height: 16),

                  //username che prende da firebase
                  Text(
                    _currentUser!.username,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    _currentUser!.email,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),

                  const SizedBox(height: 30),

                  //impostazioni
                  _ProfileMenuItem(
                    title: 'Impostazioni',
                    icon: Icons.settings,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Funzionalità in arrivo!")),
                      );
                    },
                  ),

                  //watchlist collegata a firebase
                  _ProfileMenuItem(
                    title: 'Watchlist',
                    icon: Icons.bookmark_border,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MovieGridPage(
                            userId: _currentUser!.uid,  //si passa uid e non direttamente l'username
                            title: 'Watchlist',
                            type: MovieCollectionType.watchlist,
                          ),
                        ),
                      );
                    },
                  ),

                  //liked collegata a firebase
                  _ProfileMenuItem(
                    title: 'Film Piaciuti',
                    icon: Icons.favorite_border,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MovieGridPage(
                            userId: _currentUser!.uid,
                            title: 'Piaciuti',
                            type: MovieCollectionType.liked,
                          ),
                        ),
                      );
                    },
                  ),

                  const Divider(height: 40, color: Colors.grey),

                  //logout
                  _ProfileMenuItem(
                    title: 'Logout',
                    icon: Icons.logout,
                    isDestructive: true,
                    onTap: _handleLogout,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ProfileMenuItem({
    required this.title,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Icon(icon, color: isDestructive ? Colors.red : Colors.white),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDestructive ? Colors.red : Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white.withOpacity(0.5)),
            ],
          ),
        ),
      ),
    );
  }
}