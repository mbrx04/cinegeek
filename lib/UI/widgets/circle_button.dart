import 'package:flutter/material.dart';

class CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? borderColor;

  const CircleButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 55,
    this.backgroundColor,
    this.iconColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    final Color defaultBorderColor = isDark 
        ? Colors.white.withAlpha(26) 
        : Colors.black.withAlpha(26);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? (isDark ? Colors.black.withAlpha(64) : Colors.white.withAlpha(100)),
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor ?? defaultBorderColor,
          width: 1,
        ),
      ),
      child: IconButton(
        icon: Icon(icon, color: iconColor ?? (isDark ? Colors.white : Colors.black)),
        onPressed: onTap,
      ),
    );
  }
}