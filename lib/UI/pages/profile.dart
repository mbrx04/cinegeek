//import 'package:cinegeek/UI/pages/movie_grid_page.dart';
//import 'package:flutter/material.dart';
//import '../widgets/top_bar.dart';
//
///* Widget principale che rappresenta la pagina del profilo utente*/
//class Profile extends StatelessWidget {
//  final String username;
//  final String avatar;
//
//  const Profile({
//    super.key,
//    required this.username,
//    required this.avatar});
//
//  Widget build(BuildContext context) {
//    return Scaffold(
//      body: Column(
//        children: [
//          const TopBarLogo(),
//          Expanded(
//            child: SingleChildScrollView(
//              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
//              child: Column(
//                crossAxisAlignment: CrossAxisAlignment.center,
//                children: [
//                  const CircleAvatar(
//                    radius: 55,
//                    backgroundImage: AssetImage('assets/images/default.avatar.png'),
//                  ),
//                  const SizedBox(height: 16),
//
//
//                  const Text(
//                    'username',
//                    style: TextStyle(
//                      fontSize: 24,
//                      fontWeight: FontWeight.bold,
//                    ),
//                  ),
//
//                  const SizedBox(height: 30),
//
//                  /* Naviga alla pagina delle impostazioni */
//                  _ProfileMenuItem(
//                    title: 'Impostazioni',
//                    onTap: () {
//                    // TODO: NAVIGA ALLE IMPOSTAZIONI
//                    },
//                  ),
//
//                  /* Naviga alla pagina degli amici */
//                  _ProfileMenuItem(title: 'Amici',
//                    onTap: () {
//                      // TODO: NAVIGA AGLI AMICI
//                    },
//                  ),
//
//                  /* Naviga alla pagina dei film da guardare */
//                  _ProfileMenuItem(
//                      title: 'Watchlist',
//                      onTap:(){
//                        Navigator.push(
//                          context,
//                          MaterialPageRoute(
//                            builder: (_) => MovieGridPage(
//                            username: username,
//                            title: 'Watchlist',
//                            type: MovieCollectionType.watchlist,
//                            ),
//                          ),
//                        );
//                      },
//                  ),
//
//                  /* Naviga alla pagina dei film piaciuti */
//                  _ProfileMenuItem(
//                    title: 'Piaciuti',
//                    onTap: (){
//                      Navigator.push(
//                          context,
//                          MaterialPageRoute(
//                            builder: (_) => MovieGridPage(
//                                username: username,
//                                title: 'Piaciuti',
//                                type: MovieCollectionType.liked,
//                            ),
//                          ),
//                      );
//                    },
//                  ),
//                ],
//              ),
//            ),
//          )
//        ],
//      ),
//    );
//  }
//}
//
//
// /* Widget privato usato per ogni voce nel menu dell'utente */
//class _ProfileMenuItem extends StatelessWidget {
//  final String title;
//  final VoidCallback? onTap;
//
//  const _ProfileMenuItem({
//    required this.title,
//    required this.onTap,
//    Key? key,
//  }) : super(key: key);
//
//  Widget build(BuildContext context) {
//    return Padding(
//        padding: const EdgeInsets.symmetric(vertical: 8.0),
//        child: InkWell( //permette di intercettare il tap e mostrare un effetto visivo
//          onTap: onTap,
//          child: Container(
//            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
//            decoration: const BoxDecoration(
//              border: Border(
//                bottom: BorderSide(
//                  color: Colors.grey, width: 0.3,
//                ),
//              ),
//          ),
//            child: Row(
//              mainAxisAlignment: MainAxisAlignment.spaceBetween,
//              children: [
//                Text(
//                  title,
//                  style: const TextStyle(fontSize: 18),
//                ),
//                const Icon(Icons.arrow_forward_ios,size: 16
//                ),
//              ],
//            ),
//            ),
//          ),
//        );
//      }
//  }