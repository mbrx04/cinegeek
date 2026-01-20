import 'package:cinegeek/UI/pages/friends_page.dart';
import 'package:cinegeek/UI/pages/settings.dart';
import 'package:cinegeek/UI/widgets/top_bar.dart';
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

  Future<void> _loadUserData() async {
    final user = await _authService.getCurrentUser();
    if (mounted) {
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    await _authService.logOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthLandingPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
                  //avatar
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.grey.shade400,
                    backgroundImage: _currentUser!.propicURL.isNotEmpty
                        ? NetworkImage(_currentUser!.propicURL) as ImageProvider
                        : null,
                    child: _currentUser!.propicURL.isEmpty 
                        ? const Icon(Icons.person, size: 50, color: Colors.white) 
                        : null,
                  ),
                  const SizedBox(height: 16),

                  //username
                  Text(
                    _currentUser!.username,
                    style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                  ),
                  Text(
                    _currentUser!.email,
                    style: textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),

                  const SizedBox(height: 30),


                  _ProfileMenuItem
                    (
                    title: 'Amici',
                    icon: Icons.people_alt_outlined,
                    onTap: ()
                    {
                      Navigator.push(context,MaterialPageRoute(builder: (_) => const FriendsPage()));
                    },
                  ),

                  //watchlist
                  _ProfileMenuItem(
                    title: 'Watchlist',
                    icon: Icons.bookmark_border,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MovieGridPage(
                            userId: _currentUser!.uid,
                            title: 'Watchlist',
                            type: MovieCollectionType.watchlist,
                          ),
                        ),
                      );
                    },
                  ),

                  //liked
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

                  _ProfileMenuItem(
                    title: 'Impostazioni',
                    icon: Icons.settings,
                    onTap: () async
                    {
                      await Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
                      _loadUserData();
                    },
                  ),

                  const Divider(height: 40, color: Colors.grey),

                  _ProfileMenuItem(
                    title: 'Disconnettiti',
                    icon: Icons.logout,
                    isDestructive: true,
                    onTap: _handleLogout,
                  ),

                  const SizedBox(height: 180)
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
    //vede se tema chiaro o scuro
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color contentColor = isDestructive 
        ? Colors.red 
        : (isDark ? Colors.white : Colors.black87);

    final Color boxColor = isDark 
        ? Colors.white.withAlpha(13)
        : Colors.black.withAlpha(13);

    final Color borderColor = isDark 
        ? Colors.white.withAlpha(26)
        : Colors.black.withAlpha(26);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            color: boxColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Icon(icon, color: contentColor),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: contentColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios, 
                size: 16, 
                color: contentColor.withAlpha(128)
              ),
            ],
          ),
        ),
      ),
    );
  }
}