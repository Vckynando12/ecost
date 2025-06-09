import 'package:flutter/material.dart';

final lightColorScheme = ColorScheme.fromSeed(
  seedColor: const Color(0xFF6750A4),
  primary: const Color(0xFF6750A4),
  onPrimary: Colors.white,
  secondary: const Color(0xFF625B71),
  onSecondary: Colors.white,
  tertiary: const Color(0xFF7D5260),
  surface: const Color(0xFFF6F5F7),
  error: const Color(0xFFBA1A1A),
);

class AppTheme {
  static const double borderRadius = 16.0;
  
  static BoxDecoration cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(borderRadius),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static InputDecoration textFieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: lightColorScheme.primary),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }
} 