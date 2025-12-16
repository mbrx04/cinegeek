import 'package:flutter/material.dart';

class CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;

  const CircleButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 55,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,  //larghezza
      height: size, //altezza
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.black.withAlpha(64),
        shape: BoxShape.circle, //forma a cerchio
        border: Border.all(
          color: Colors.white.withAlpha(26),
          width: 1, //spessore del bordo
        ),
      ),
      child: IconButton(  //icona nel bottone che viene scelta dove viene usato il widget
        icon: Icon(icon, color: iconColor ?? Colors.white),
        onPressed: onTap,
      ),
    );
  }
}
