import 'package:flutter/material.dart';

class TopBarLogo extends StatelessWidget {
  final double height;
  final bool showShadow;

  const TopBarLogo({
    super.key,
    this.height = 20, //cambiare dimensione del logo
    this.showShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 40, bottom: 16),  //alzare o abbassare il logo
      width: double.infinity,

      //ombre ecc....
      decoration: BoxDecoration(
        color: Colors.transparent,
        boxShadow: showShadow
            ? const [
                BoxShadow(
                  color: Colors.black38,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ]
            : null,
      ),

      //logo centrato
      child: Center(
        child: Image.asset(
          'assets/images/solo_testo.png',
          height: height,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
