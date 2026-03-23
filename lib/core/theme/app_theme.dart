import 'package:flutter/material.dart';

class AppTheme {
  
  static ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      surface: Color(0xFFFFFFFF),
      primary: Color(0xFF000000),
      onPrimary: Color(0xFFFFFFFF),
      onSurface: Color(0xFF000000),
      secondary: Color(0xFF666666),
    ),
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFFFFFFF),
      foregroundColor: Color(0xFF000000),
      elevation: 0,
      iconTheme: IconThemeData(color: Color(0xFF000000)),
      titleTextStyle: TextStyle(
        color: Color(0xFF000000),
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFFFFFFFF),
      selectedItemColor: Color(0xFF000000),
      unselectedItemColor: Color(0xFF999999),
    ),
    cardColor: const Color(0xFFFFFFFF),
    dividerColor: const Color(0xFFE0E0E0),
    iconTheme: const IconThemeData(color: Color(0xFF000000)),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFF000000)),
      bodyMedium: TextStyle(color: Color(0xFF000000)),
      titleLarge: TextStyle(color: Color(0xFF000000)),
      titleMedium: TextStyle(color: Color(0xFF000000)),
      labelSmall: TextStyle(color: Color(0xFF666666)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: const Color(0xFFFFFFFF),
      filled: true,
      hintStyle: const TextStyle(color: Color(0xFF999999)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF000000),
      foregroundColor: Color(0xFFFFFFFF),
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      surface: Color(0xFF1A1A1A),
      primary: Color(0xFFFFFFFF),
      onPrimary: Color(0xFF000000),
      onSurface: Color(0xFFFFFFFF),
      secondary: Color(0xFF888888),
    ),
    scaffoldBackgroundColor: const Color(0xFF0A0A0A),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF111111),
      foregroundColor: Color(0xFFFFFFFF),
      elevation: 0,
      iconTheme: IconThemeData(color: Color(0xFFFFFFFF)),
      titleTextStyle: TextStyle(
        color: Color(0xFFFFFFFF),
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF111111),
      selectedItemColor: Color(0xFFFFFFFF),
      unselectedItemColor: Color(0xFF666666),
    ),
    cardColor: const Color(0xFF1A1A1A),
    dividerColor: const Color(0xFF222222),
    iconTheme: const IconThemeData(color: Color(0xFFFFFFFF)),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFFFFFFFF)),
      bodyMedium: TextStyle(color: Color(0xFFFFFFFF)),
      titleLarge: TextStyle(color: Color(0xFFFFFFFF)),
      titleMedium: TextStyle(color: Color(0xFFFFFFFF)),
      labelSmall: TextStyle(color: Color(0xFF888888)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: const Color(0xFF1A1A1A),
      filled: true,
      hintStyle: const TextStyle(color: Color(0xFF666666)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFFFFFFFF),
      foregroundColor: Color(0xFF000000),
    ),
  );

  static ThemeData get oceanTheme => ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      surface: Color(0xFF1A237E),
      primary: Color(0xFF64B5F6),
      onPrimary: Color(0xFF0D47A1),
      onSurface: Color(0xFFE3F2FD),
      secondary: Color(0xFF90CAF9),
    ),
    scaffoldBackgroundColor: const Color(0xFF0D47A1),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0D47A1),
      foregroundColor: Color(0xFFE3F2FD),
      elevation: 0,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF0D47A1),
      selectedItemColor: Color(0xFF64B5F6),
      unselectedItemColor: Color(0xFF90CAF9),
    ),
    dividerColor: const Color(0xFF1565C0),
  );

  static ThemeData get pinkTheme => ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      surface: Color(0xFFFCE4EC),
      primary: Color(0xFFE91E63),
      onPrimary: Color(0xFFFFFFFF),
      onSurface: Color(0xFF880E4F),
      secondary: Color(0xFFF06292),
    ),
    scaffoldBackgroundColor: const Color(0xFFF8BBD0),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFE91E63),
      foregroundColor: Color(0xFFFFFFFF),
      elevation: 0,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFFFCE4EC),
      selectedItemColor: Color(0xFFE91E63),
      unselectedItemColor: Color(0xFFF06292),
    ),
    dividerColor: const Color(0xFFF48FB1),
  );
}
