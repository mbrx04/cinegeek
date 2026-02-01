import 'package:cinegeek/UI/pages/user_view.dart';
import 'package:cinegeek/UI/widgets/cineGlassTextField.dart';
import 'package:cinegeek/UI/widgets/circle_button.dart';
import 'package:cinegeek/UI/widgets/top_bar.dart';
import 'package:cinegeek/services/auth_service.dart';
import 'package:flutter/material.dart';
import '../widgets/friend_card.dart';

class FriendsPage extends StatefulWidget
{
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage>
{
  final TextEditingController _usernameController = TextEditingController();
  final AuthService _authService=AuthService();
  late Future<List<Map<String,dynamic>>> _friendsFuture;

  @override
  void initState()
  {
    super.initState();
    _friendsFuture = _authService.getFriends();
  }

  void _refreshFriends()
  {
    setState(()
      {
        _friendsFuture = _authService.getFriends();
      }
    );
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold
    (
      body:
      Column
      (
        mainAxisAlignment: MainAxisAlignment.center,
        children:
        [
          Row
          (
            children:
            [
              SizedBox(width: 40, height: 40, child: CircleButton(icon: Icons.arrow_back, onTap: () => Navigator.of(context).pop(),),),
              Expanded(child: Align(alignment: Alignment.center,child: const TopBarLogo())),
              const SizedBox(width: 40)
            ]
          ),

          Expanded
          (
            child:
            Padding
              (
              padding: const EdgeInsets.all(16.0),
              child:
              Column
                (
                children:
                [
                  Row
                    (
                    children:
                    [
                      Expanded
                        (
                        child:
                        CineGlassTextField
                        (
                          hint: "Inserisci l'username del tuo amico",
                          obscure: false,
                          controller: _usernameController,
                        ),
                      ),

                      const SizedBox(width: 2),

                      CircleButton
                        (
                          icon: Icons.arrow_circle_right_outlined,
                          onTap: ()  async
                          {
                            try
                            {
                              if(_usernameController.text!='')
                              {
                                await _authService.addFriend(_usernameController.text.trim());

                                if (context.mounted)
                                {
                                  ScaffoldMessenger.of(context).showSnackBar
                                  (
                                    const SnackBar
                                    (
                                      backgroundColor: Color(0xFFCCFF00),
                                      content: Text("Amico aggiunto con successo!", style: TextStyle(color: Colors.black)),
                                    ),
                                  );
                                  _refreshFriends();
                                }
                              }
                            }
                            catch (e)
                            {
                              if (context.mounted)
                              {
                                ScaffoldMessenger.of(context).showSnackBar
                                  (
                                  SnackBar
                                    (
                                    backgroundColor: Colors.red,
                                    content: Text("Errore: $e"),
                                  ),
                                );
                              }
                            }
                          }
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(thickness: 1,indent: 20,endIndent: 20,),

                  Expanded
                  (
                    child: FutureBuilder<List<Map<String, dynamic>>>
                    (
                      future: _friendsFuture,
                      builder: (context, snapshot)
                      {
                        if (snapshot.connectionState == ConnectionState.waiting)
                        {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final friends = snapshot.data ?? const [];

                        if (friends.isEmpty)
                        {
                          return const
                          Center
                          (
                            child: Text("Non hai ancora amici.\n Inizia a cercarne uno sopra!", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                          );
                        }

                        return ListView.separated
                        (
                          padding: const EdgeInsets.all(16),
                          itemCount: friends.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index)
                          {
                            final friend = friends[index];
                            return FriendCard
                            (
                              username: friend['username'],
                              subtitle: FutureBuilder<String>(future: _authService.lastWatched(friend['username']), builder: (context,movieSnapshot)
                              {
                                if(movieSnapshot.connectionState==ConnectionState.waiting)
                                {
                                  return const Text("Caricamento...", style: TextStyle(fontSize: 12));
                                }
                                final film = movieSnapshot.data ?? '';
                                return Text
                                (
                                  film.isNotEmpty ? "Ha visto: $film" : "Nessun film visto",
                                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                                );
                              },),

                              onTap: ()
                              {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => UserViewPage(userId: friend['uid'],userName:friend['username']),),);
                              },
                              onDelete: () async
                              {
                                try
                                {
                                  await _authService.removeFriend(friend['uid']);
                                  _refreshFriends();
                                }
                                catch (e)
                                {
                                  if (context.mounted)
                                  {
                                    ScaffoldMessenger.of(context).showSnackBar
                                    (
                                      SnackBar
                                      (
                                        backgroundColor: Colors.red,
                                        content: Text("Errore: $e"),
                                      ),
                                    );
                                  }
                                }
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            )
          )
        ],
      )
    );
  }
}