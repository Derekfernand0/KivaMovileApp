import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Paleta de Colores - Modo Claro
  static const Color lilac = Color(0xFFE5D6FF);
  static const Color blue = Color(0xFFCFEAFF);
  static const Color pink = Color(0xFFFFD6E7);
  static const Color yellow = Color(0xFFFFF4B8);
  static const Color peach = Color(0xFFFFD9C8);

  static const Color paperLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color inkLight = Color(0xFF101522);
  static const Color ink2Light = Color(0xFF2A3550);
  static const Color lineLight = Color(0x24000000); // rgba(0,0,0,.14)
  static const Color ringLight = Color(0xFF7C4DFF);

  // Paleta de Colores - Modo Oscuro
  static const Color paperDark = Color(0xFF020617);
  static const Color cardDark = Color(0xFF020617);
  static const Color inkDark = Color(0xFFE5E7EB);
  static const Color ink2Dark = Color(0xFFC7D2FE);
  static const Color lineDark = Color(0x8C94A3B8); // rgba(148,163,184,.55)
  static const Color ringDark = Color(0xFFA5B4FC);

  // 💡 CORRECCIÓN AQUÍ: Cambiamos a 'static const' y usamos Radius.circular
  static const BorderRadius defaultRadius = BorderRadius.all(
    Radius.circular(16.0),
  );
  static const BorderRadius pillRadius = BorderRadius.all(
    Radius.circular(999.0),
  );

  // Tema Claro
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: paperLight,
      colorScheme: const ColorScheme.light(
        primary: ringLight,
        secondary: pink,
        surface: cardLight,
        onSurface: inkLight,
        outline: lineLight,
      ),
      textTheme: GoogleFonts.nunitoTextTheme().apply(
        bodyColor: inkLight,
        displayColor: inkLight,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: peach,
          foregroundColor: inkLight,
          elevation: 2.0, // 💡 Decimal explícito
          shape: const RoundedRectangleBorder(borderRadius: defaultRadius),
          textStyle: GoogleFonts.fredoka(
            fontWeight: FontWeight.w700,
            fontSize: 16.0,
          ),
        ),
      ),
      // 💡 CORRECCIÓN AQUÍ: const CardTheme y valores decimales
      cardTheme: const CardThemeData(
        color: cardLight,
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: defaultRadius,
          side: BorderSide(color: lineLight, width: 1.0),
        ),
      ),
    );
  }

  // Tema Oscuro
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: paperDark,
      colorScheme: const ColorScheme.dark(
        primary: ringDark,
        secondary: Color(0xFFDB2777),
        surface: cardDark,
        onSurface: inkDark,
        outline: lineDark,
      ),
      textTheme: GoogleFonts.nunitoTextTheme(
        ThemeData.dark().textTheme,
      ).apply(bodyColor: inkDark, displayColor: inkDark),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1D4ED8),
          foregroundColor: inkDark,
          elevation: 2.0,
          shape: const RoundedRectangleBorder(borderRadius: defaultRadius),
          textStyle: GoogleFonts.fredoka(
            fontWeight: FontWeight.w700,
            fontSize: 16.0,
          ),
        ),
      ),
      // 💡 CORRECCIÓN AQUÍ
      cardTheme: const CardThemeData(
        color: cardDark,
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: defaultRadius,
          side: BorderSide(color: lineDark, width: 1.0),
        ),
      ),
    );
  }
}
