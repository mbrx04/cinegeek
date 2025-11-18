import 'package:flutter/material.dart';
import '../widgets/top_bar.dart';
import '../widgets/movie_card.dart';
import '../widgets/movie_carousel.dart';

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

          // ⭐ Tutti i caroselli scrollabili
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  MovieCarousel(
                    title: "Consigliati per te",
                    movies: testMovies,
                  ),
                  MovieCarousel(
                    title: "Film visti e non votati",
                    movies: testMovies,
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
