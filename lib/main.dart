import 'package:cinegeek/UI/pages/LogInSignUp/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/weekend_context_manager.dart'; 
import 'UI/pages/home.dart';
import 'UI/pages/review.dart';
import 'UI/pages/profile.dart';
import 'UI/pages/search_result.dart';
import 'UI/widgets/navbar.dart';
import 'UI/theme.dart';
import 'package:workmanager/workmanager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized(); 
    print("--- [Back end] Inizio: $task ---");
    try {
      WeekendContextManager manager = WeekendContextManager();
      await manager.init(isBackground: true);
      print("--- [Back end] OK ---");
      return Future.value(true);
    } catch (e) {
      print("--- [Back end] ERRORE: $e ---");
      return Future.value(false);
    }
  });
}

void main() async{
  WidgetsFlutterBinding.ensureInitialized();  //inizializza binding

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("!!!!!!!!!!!!!!!!firebase inizializzato!!!!!!!!!!!!!!!!!!");
  
  Workmanager().initialize( //inizializzazione del workmanager per funzionare in background la posizione
    callbackDispatcher,
    isInDebugMode: false,
  );

  Workmanager().registerPeriodicTask( //ogni 15 minuti controlla la posizione
    "1",
    "check_cinema_proximity",
    frequency: const Duration(minutes: 15),
  );

  final weekendMgr = WeekendContextManager();
  await weekendMgr.init();

  //AGGIUNGETE QUI I VOSTRI MANAGER PER LE ALTRE FUNZIONALITà

  runApp(const CineGeekApp());
}

class CineGeekApp extends StatelessWidget {
  const CineGeekApp({super.key});

  @override
  Widget build(BuildContext context)
  {
    return ValueListenableBuilder<ThemeMode>
    (
      valueListenable: themeNotifier,
      builder: (context, currentMode, _)
      {
        return MaterialApp
        (
          debugShowCheckedModeBanner: false,
          title: 'CineGeek',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,
          home: const AuthGate(),
        );
      },
    );
  }
}

//nav bar e navigazione principale
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0; 
  bool _isSearching = false; 
  String _searchQuery = ""; 
  
  //key globale per comandare la navbar
  final GlobalKey<LiquidNavBarState> _navBarKey = GlobalKey<LiquidNavBarState>();

  static final List<Widget> _pages = <Widget>[
    const HomePage(),
    const ReviewsPage(),
    const Profile(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _handleSearch(String text) {
    setState(() {
      _searchQuery = text;
      _isSearching = text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, //disabilita la chiusura automatica
      onPopInvoked: (didPop) {
        if (didPop) return;

        //gestisce la tastiera
        if (MediaQuery.of(context).viewInsets.bottom > 0) {
          FocusScope.of(context).unfocus();
          return;
        }

        //gestisce la barra di ricerca
        final bool isBarOpen = _navBarKey.currentState?.isSearchOpen ?? false;

        if (_isSearching || isBarOpen) {
          _navBarKey.currentState?.closeSearch();
          setState(() {
            _isSearching = false;
            _searchQuery = "";
          });
          return;
        }

        //gestisce le pagine
        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
          return;
        }

        //chiude l'app
        if (context.mounted) {
          SystemNavigator.pop(); 
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            //layer 1
            IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),

            //layer 2
            if (_isSearching)
              Positioned.fill(
                child: Container(
                  //usa il colore di sfondo in base al tema
                  color: Theme.of(context).colorScheme.surface, 
                  child: SearchResultsPage(query: _searchQuery),
                ),
              ),

            //layer 3
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 100,
                child: LiquidNavBar(
                  key: _navBarKey,
                  selectedIndex: _selectedIndex,
                  onPageChanged: _onItemTapped,
                  onSearchChanged: _handleSearch,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// 🧁🧁🧁 🧁🧁🧁 🧁🧁🧁 🧁🧁🧁 🧁🧁🧁 🧁🧁🧁 🧁🧁🧁 🧁🧁🧁