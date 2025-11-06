import 'package:flutter/material.dart';
import 'pages/home.dart';
import 'pages/review.dart';
import 'pages/profile.dart';
import 'tmdb_test.dart'; //serve per il check dell'API e mostrare che funziona

void main() {
  runApp(const CineGeekApp());
}

class CineGeekApp extends StatelessWidget {
  const CineGeekApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // nasconde la barra in alto a dx con scritto DEBUG in rosso
      title: 'CineGeek',
      theme: ThemeData(
        useMaterial3: true, // per usare material you
        colorSchemeSeed: const Color.fromARGB(255, 54, 82, 244), // colore principale del tema
        brightness: Brightness.dark, // imposta tema scuro
      ),
      //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!ATTENZIONE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      home: const MainNavigation(), // prima schermata dell’app
      //home: const TmdbTestPage(), //da togliere, usare solo per mostrare il corretto funzionamento dell'API di TMDB

    );
  }
}

/// Widget principale con la barra di navigazione in basso
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0; // tiene traccia della pagina selezionata

  // elenco delle 3 pagine principali
  static final List<Widget> _pages = <Widget>[
    const HomePage(),
    const ReviewsPage(),
    const ProfilePage(),
  ];

  // cambia pagina quando l’utente tocca un’icona della barra in basso
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // mostra la pagina selezionata
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.reviews_outlined),
            selectedIcon: Icon(Icons.reviews),
            label: 'Recensioni',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profilo',
          ),
        ],
      ),
    );
  }
}
