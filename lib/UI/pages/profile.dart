import 'package:flutter/material.dart';
import '../widgets/top_bar.dart';

class profile extends StatelessWidget {
  final String username;
  final String avatar;

  const profile({
    super.key,
    required this.username,
    required this.avatar});


  Widget build(BuildContext context) {
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
                  const CircleAvatar(
                    radius: 55,
                    backgroundImage: AssetImage('assets/images/default.avatar.png'),
                  ),
                  const SizedBox(height: 16),


                  const Text(
                    'Username',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 30),


                  _ProfileMenuItem(title: 'Impostazioni'),
                  _ProfileMenuItem(title: 'Amici'),
                  _ProfileMenuItem(title: 'Watchlist'),
                  _ProfileMenuItem(title: 'Piaciuti'),
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

  const _ProfileMenuItem({
    required this.title
  });

  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey, width: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 18),
                ),
                const Icon(Icons.arrow_forward_ios,size: 16),
              ],
            ),
          ),
        );
      }
  }