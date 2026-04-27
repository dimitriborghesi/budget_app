import 'package:flutter/material.dart';

class AppTheme {

  static ThemeData light = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF6F7FB),

    primaryColor: const Color(0xFFE53935),

    cardColor: Colors.white,

    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Color(0xFF1A1A1A)),
    ),
  );

  static ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0F0F0F),

    primaryColor: const Color(0xFF6C63FF),

    cardColor: const Color(0xFF1C1C1E),

    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.white),
    ),
  );
}