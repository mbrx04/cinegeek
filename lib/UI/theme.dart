import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryLime = Color.fromARGB(255, 204, 255, 0);  //COLORE PRINCIPALE!!!!

  static TextTheme _buildTextTheme(Color textColor) {
    return TextTheme(
      
      //font bebas neue per i titoli o testi corti
      headlineLarge: GoogleFonts.bebasNeue(
        fontSize: 42,
        fontWeight: FontWeight.w400,
        color: textColor,
        letterSpacing: 1.5,
      ),
      headlineMedium: GoogleFonts.bebasNeue(
        fontSize: 30,
        fontWeight: FontWeight.w400,
        color: textColor,
        letterSpacing: 0.5,
      ),
      headlineSmall: GoogleFonts.bebasNeue(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        color: textColor,
        letterSpacing: 0.25,
      ),
      
      //font montserrat per i testi normali e lunghi
      bodyMedium: GoogleFonts.montserrat(
        fontSize: 15,
        height: 1.5,
        color: textColor, 
        fontWeight: FontWeight.w400,
      ),
      bodySmall: GoogleFonts.montserrat(
        fontSize: 12,
        color: textColor.withOpacity(0.7),
        fontWeight: FontWeight.w400,
      ),
      labelMedium: GoogleFonts.montserrat(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: textColor.withOpacity(0.8),
      ),
    );
  }

  //tema chiaro
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorSchemeSeed: primaryLime, 
    scaffoldBackgroundColor: const Color(0xFFF5F5F5), 
    textTheme: _buildTextTheme(Colors.black87),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(color: Colors.black, fontSize: 20),
    ),
    iconTheme: const IconThemeData(color: Colors.black87),
  );

  //tema scuro, è quello dominate e più usato. usa material
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorSchemeSeed: primaryLime,
    textTheme: _buildTextTheme(Colors.white),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    iconTheme: const IconThemeData(color: Colors.white),
  );
}