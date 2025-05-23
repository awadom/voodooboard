import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors
  // Changed pinks to subtle purples
  static const Color _lightPrimary = Color(0xFF957DAD); // Soft muted purple
  static const Color _lightOnPrimary = Colors.white;
  static const Color _lightSecondary = Color(0xFFD3CCE3); // Light lavender
  static const Color _lightSurface = Colors.white;

  static const Color _darkPrimary = Colors.deepPurpleAccent;
  static const Color _darkSurface = Colors.black;

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: _lightPrimary,
        onPrimary: _lightOnPrimary,
        secondary: _lightSecondary,
        onSecondary: Colors.black87,
        error: Colors.red,
        onError: Colors.white,
        background: _lightSurface,
        onBackground: Colors.black,
        surface: _lightSurface,
        onSurface: Colors.black,
      ),
      scaffoldBackgroundColor: _lightSurface,
      textTheme: ThemeData.light().textTheme,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        labelStyle: const TextStyle(color: Colors.black87),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _lightPrimary, width: 1.5),
        ),
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData.dark(useMaterial3: true).copyWith(
      colorScheme: ColorScheme.dark().copyWith(
        primary: _darkPrimary,
        surface: _darkSurface,
      ),
      scaffoldBackgroundColor: _darkSurface,
      textTheme: ThemeData.dark().textTheme,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[900],
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        labelStyle: TextStyle(color: Colors.grey[300]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _darkPrimary, width: 1.5),
        ),
      ),
    );
  }

  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;

  static const EdgeInsets screenPadding = EdgeInsets.all(spacingMedium);
}
