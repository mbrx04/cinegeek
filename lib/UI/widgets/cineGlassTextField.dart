import 'package:flutter/material.dart';

class CineGlassTextField extends StatelessWidget {
  final String hint;
  final bool obscure;

  const CineGlassTextField({
    super.key,
    required this.hint,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(90),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Colors.white.withAlpha(26),
          ),
        ),
        child: TextField(
          obscureText: obscure,
          style: textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: textTheme.labelMedium,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}

