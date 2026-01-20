import 'package:flutter/material.dart';
import 'package:cinegeek/services/auth_service.dart';
import 'package:cinegeek/model/app_user.dart';
import '../widgets/circle_button.dart';
import '../widgets/top_bar.dart';

class UserViewPage extends StatefulWidget {
  final String userId;

  const UserViewPage({super.key, required this.userId});

  @override
  State<UserViewPage> createState() => _UserViewPageState();
}

class _UserViewPageState extends State<UserViewPage> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final navigator=Navigator.of(context);

    return Scaffold
    (
      body:
      Column
      (
        children:
        [
          Row
            (
              children:
              [
                SizedBox(width: 40, height: 40, child: CircleButton(icon: Icons.arrow_back, onTap: () => navigator.pop(),),),
                Expanded(child: Align(alignment: Alignment.center,child: const TopBarLogo())),
                const SizedBox(width: 40)
              ]
          ),
          Expanded
          (
            child: FutureBuilder<AppUser?>
            (
              future: _authService.fetchUserData(widget.userId),
              builder: (context, snapshot)
              {
                if (snapshot.connectionState == ConnectionState.waiting)
                {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError || !snapshot.hasData || snapshot.data == null)
                {
                  return const Center(child: Text("Impossibile caricare il profilo"));
                }

                final user = snapshot.data!;

                return SingleChildScrollView
                (
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child:
                  Column
                  (
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children:
                    [
                      const Center(child: CircleAvatar(radius: 50, backgroundColor: Colors.blueGrey, child: Icon(Icons.person, size: 50, color: Colors.white),),),

                      const SizedBox(height: 16),

                      Text(user.username, style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface,),),


                      const SizedBox(height: 30),
                      const Divider(height: 1, color: Colors.grey),
                      const SizedBox(height: 30),

                      // Rimpiazzare con matrice di film visti dall'user ordinati in ordine decrescente di timestamp
                      Icon(Icons.movie_filter_outlined, size: 40, color: colorScheme.onSurface.withAlpha(51),),
                      const SizedBox(height: 10), Text("Attività recente non disponibile", style: TextStyle(color: Colors.grey.withAlpha(153)),),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
