import 'package:flutter/material.dart';

class AppTheme {
  static const _seedColor = Color(0xFF1B5E20);

  static final light = ThemeData(
    brightness: Brightness.light,
    colorSchemeSeed: _seedColor,
    scaffoldBackgroundColor: const Color(0xFFFFF8E1),
    appBarTheme: const AppBarTheme(centerTitle: true),
  );

  static final dark = ThemeData(
    brightness: Brightness.dark,
    colorSchemeSeed: _seedColor,
    scaffoldBackgroundColor: const Color(0xFF1A1A2E),
    appBarTheme: const AppBarTheme(centerTitle: true),
  );
}
