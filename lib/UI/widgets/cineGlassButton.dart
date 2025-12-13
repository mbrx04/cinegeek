import 'package:flutter/material.dart';

class CineGlassButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const CineGlassButton({
    super.key,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 260,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(90),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Colors.white.withAlpha(26),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}