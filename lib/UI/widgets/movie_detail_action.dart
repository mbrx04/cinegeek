import 'package:flutter/material.dart';
import 'circle_button.dart';

class MovieDetailAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;
  final Color? activeColor;

  const MovieDetailAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveColor = activeColor ?? Colors.white;
    final Color? iconColor = isActive ? effectiveColor : null;
    final Color? borderColor = isActive ? effectiveColor : null;

    final Color? backgroundColor = isActive 
        ? effectiveColor.withOpacity(0.2) 
        : null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleButton(
          size: 50,
          icon: icon,
          onTap: onTap,
          iconColor: iconColor,
          borderColor: borderColor,
          backgroundColor: backgroundColor,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontSize: 11,
            color: isActive ? effectiveColor : null,
          ),
        ),
      ],
    );
  }
}