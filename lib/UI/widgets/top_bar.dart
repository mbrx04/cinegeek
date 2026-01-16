import 'package:flutter/material.dart';
//in questo caso abbiamo usato una topbar per mostrare il logo dell'app
//in alto in tutte le vie ma si potrebbe usare anche per altri scopi come
//per un hamburger menù o altre icone
class TopBarLogo extends StatelessWidget {
  final double height;
  final bool showShadow;

  const TopBarLogo({
    super.key,
    this.height = 25, //cambiare dimensione del logo
    this.showShadow = false,  //ombra di default in questo caso disattivata
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 40, bottom: 16),  //alzare o abbassare il logo verticalmente
      width: double.infinity, //occupa tutta la larghezza disponibile

      //decorazioni come ombre ecc....
      decoration: BoxDecoration(
        color: Colors.transparent,  //sfondo trasparente
        boxShadow: showShadow //mostra l'ombra se show shadow è truw
            ? const [
                BoxShadow(
                  color: Colors.black38,  //colore dell'ombra
                  blurRadius: 6,  //sfocatura dell'ombra
                  offset: Offset(0, 2), //posizione dx e sx dell'ombra
                ),
              ]
            : null,
      ),

      //logo centrato
      child: Center(
        child: Image.asset(
          'assets/images/solo_testo.png',
          height: height,
          fit: BoxFit.contain,  //mantiene le proporzioni
        ),
      ),
    );
  }
}