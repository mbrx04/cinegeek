import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryLime = Color.fromARGB(255, 204, 255, 0);
  
  static TextTheme _buildTextTheme(Color textColor) {
    return TextTheme(
      
      //font bebas neue per titoli ecc....
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
      
      //font montserrat per il resto del testo come recensioni, descrizioni ecc....
      bodyMedium: GoogleFonts.montserrat(
        fontSize: 15,
        height: 1.5,
        color: textColor.withOpacity(0.9),
        fontWeight: FontWeight.w400,
      ),
      
      labelMedium: GoogleFonts.montserrat(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: textColor.withOpacity(0.7),
      ),
    );
  }

  //tema chiaro
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorSchemeSeed: primaryLime,
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    textTheme: _buildTextTheme(Colors.black),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
    ),
  );

  //tema scuro
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorSchemeSeed: primaryLime,
    scaffoldBackgroundColor: const Color(0xFF121212),
    textTheme: _buildTextTheme(Colors.white),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
    ),
  );
}