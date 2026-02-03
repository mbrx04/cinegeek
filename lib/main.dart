import 'package:cinegeek/UI/pages/LogInSignUp/auth_gate.dart';
import 'package:cinegeek/services/at_cinema_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'UI/pages/at_cinema_page.dart';
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
import 'services/notification_service.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    print("--- [Back end] Inizio: $task ---");
    try {
      WeekendContextManager manager = WeekendContextManager();
      await manager.init(isBackground: true);
      AtCinemaService cinemaService = AtCinemaService();
      await cinemaService.checkArrival();
      print("--- [Back end] OK ---");
      return Future.value(true);
    } catch (e) {
      print("--- [Back end] ERRORE: $e ---");
      return Future.value(false);
    }
  });
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("!!!!!!!!!!!!!!!! firebase inizializzato !!!!!!!!!!!!!!!!!!");

  //Notifiche
  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.scheduleCineGeekReminders();

  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false,
  );

  Workmanager().registerPeriodicTask(
    "1",
    "check_cinema_proximity",
    frequency: const Duration(minutes: 15),
  );

  runApp(const CineGeekApp());

  _initializeBackgroundServices();
}

Future<void> _initializeBackgroundServices() async {
  try {
    final weekendMgr = WeekendContextManager();
    await weekendMgr.init();

    final cinemaService = AtCinemaService();
    await cinemaService.checkArrival();

    print("--- [Servizi] Inizializzazione completata ---");
  } catch (e) {
    print("--- [Servizi] Errore inizializzazione: $e ---");
  }
}

class CineGeekApp extends StatelessWidget {
  const CineGeekApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, _) {
        return MaterialApp(
          navigatorKey: navigatorKey,
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

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  bool _isSearching = false;
  String _searchQuery = "";

  final GlobalKey<LiquidNavBarState> _navBarKey = GlobalKey<LiquidNavBarState>();

  @override
  void initState() {
    super.initState();
    // Esegue il controllo del cinema dopo che il primo frame è stato renderizzato
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkCinemaEntry();
    });
  }

  void _checkCinemaEntry() async {
    // Controllo se l'utente è già al cinema per mostrare la pagina dedicata
    final bool shouldShow = await AtCinemaService().shouldShowCinemaPage();
    if (shouldShow && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AtCinemaPage()),
      );
    }
  }

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
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;

        if (MediaQuery.of(context).viewInsets.bottom > 0) {
          FocusScope.of(context).unfocus();
          return;
        }

        final bool isBarOpen = _navBarKey.currentState?.isSearchOpen ?? false;

        if (_isSearching || isBarOpen) {
          _navBarKey.currentState?.closeSearch();
          setState(() {
            _isSearching = false;
            _searchQuery = "";
          });
          return;
        }

        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
          return;
        }

        if (context.mounted) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),
            if (_isSearching)
              Positioned.fill(
                child: Container(
                  color: Theme.of(context).colorScheme.surface,
                  child: SearchResultsPage(query: _searchQuery),
                ),
              ),
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