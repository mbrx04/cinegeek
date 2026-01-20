import 'package:flutter/material.dart';

class FriendCard extends StatelessWidget
{
  final String username;
  final Widget subtitle;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const FriendCard
  ({
    super.key,
    required this.username,
    required this.subtitle,
    required this.onTap,
    required this.onDelete
  });

  @override
  Widget build(BuildContext context)
  {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return
      InkWell
      (
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child:
        Container
        (
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration
          (
            color: isDark ? Colors.white.withAlpha(15) : Colors.black.withAlpha(10),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? Colors.white.withAlpha(20) : Colors.black.withAlpha(15),),
          ),

          child:
          Row
          (
            children:
            [
              const CircleAvatar
              (
                radius: 25,
                backgroundColor: Colors.blueGrey,
                child: Icon(Icons.person, color: Colors.white),
              ),

              const SizedBox(width: 16),

              Expanded
              (
                child:
                Column
                (
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                  [
                    Text
                    (
                      username,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),

                      subtitle,
                  ],
                ),
              ),

              GestureDetector
              (
                onTap: onDelete,
                child:
                Container
                (
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(color: Colors.redAccent.withAlpha(200), borderRadius: BorderRadius.circular(8),),
                  child: const Icon(Icons.remove, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      );
    }
}