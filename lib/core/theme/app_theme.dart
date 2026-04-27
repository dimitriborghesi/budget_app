import 'package:flutter/material.dart';

class AppTheme {

  /// 🌞 LIGHT
  static ThemeData light = ThemeData(
    brightness: Brightness.light,
      fontFamily: 'Inter', // ✅ ICI

    scaffoldBackgroundColor: const Color(0xFFF8F8FA),

    primaryColor: const Color(0xFFE53935),

    cardColor: Colors.white,
  dividerColor: const Color(0xFFE5E5E5), // 👈 ICI

textTheme: const TextTheme(
  bodyMedium: TextStyle(color: Color(0xFF111111)), // 👈 plus net
  bodySmall: TextStyle(color: Color(0xFF6B6B6B)), // 👈 moins gris triste
),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFFE53935),
    ),
  );

  /// 🌙 DARK
static ThemeData dark = ThemeData(
  brightness: Brightness.dark,
  fontFamily: 'Inter',

scaffoldBackgroundColor: const Color(0xFF0D0F12),

  primaryColor: const Color(0xFFB4C255), // 👈 plus vivant

  cardColor: const Color(0xFF18181A), // 👈 meilleur contraste
  dividerColor: const Color(0xFF2A2A2A), // 👈 ICI

  textTheme: const TextTheme(
    bodyMedium: TextStyle(
      color: Color(0xFFEDEDED), // 👈 pas blanc pur (fatigue yeux)
    ),
    bodySmall: TextStyle(
      color: Color(0xFF9A9A9A), // 👈 vrai gris lisible
    ),
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFFB4C255),
  ),
);
}