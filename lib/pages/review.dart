import 'package:flutter/material.dart';
import '../widgets/loghi_widget.dart';
import '../widgets/top_bar.dart';

class ReviewsPage extends StatelessWidget {
  const ReviewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
      children: const [
        TopBarLogo(),
        Expanded(child: Center(child: Text("Recensioni"))),
  ],
)

    );
  }
}