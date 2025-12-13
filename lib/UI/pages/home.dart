import 'package:flutter/material.dart';
import '../widgets/top_bar.dart';
import '../widgets/movie_card.dart';
import '../widgets/movie_carousel.dart';
// IMPORT PER PROVA
import 'LogInSignUp/authLandingPage.dart';
import '../widgets/cineGlassButton.dart';
// FINE IMPORT PROVA

//HARDCODED PER LISTA DEI FILM DA MODIFICARE POI CON DATI VERI
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, String>> testMovies = [
    {
      "title": "The Fast and The Furious",
      "imageUrl":
          "https://www.themoviedb.org/t/p/w1280/fMhRkSfn1gA7RriWlSAk9yCuZWp.jpg",
    },
    {
      "title": "Fast X",
      "imageUrl":
          "https://www.themoviedb.org/t/p/w1280/hC6mLdlgpFU63FOduX80xaGevGj.jpg",
    },
    {
      "title": "Gran Turismo - La storia di un sogno impossibile",
      "imageUrl":
          "https://www.themoviedb.org/t/p/w1280/34moeAXmzjYgDq73yzy1kuYe4di.jpg",
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TopBarLogo(),

          ////card con un film di esempio
          //Padding(
          //  padding: const EdgeInsets.all(16.0),
          //  child: MovieCard(
          //    imageUrl:
          //        "https://www.themoviedb.org/t/p/w1280/A1H2lnpur1IofI0ufcImcAnSytP.jpg",
          //    title: "Super Mario Bros",
          //    onTap: () {
          //      print("hai cliccato il film di super mario");
          //    },
          //  ),
          //),

          //tutti i caroselli scrollabili
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 85),
              child: Column(
                children: [
                  MovieCarousel(
                    title: "Film visti e non votati",
                    movies: testMovies,
                  ),
                  MovieCarousel(
                    title: "Consigliati per te",
                    movies: testMovies,
                  ),
                  MovieCarousel(
                    title: "Popolari",
                    movies: testMovies,
                  ),


                  // prova logIn DA CANCELLARE IN SEGUITO
                  const SizedBox(height: 24), // spazio tra caroselli e bottone
                  CineGlassButton(
                    label: "Login / Registrazione",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AuthLandingPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24), // padding finale
                  // FINE PROVA



                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}