import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeModel extends ChangeNotifier {
  ThemeData currentTheme = ThemeData.light();
  int currentThemeIndex = 0;

  ThemeModel() {
    loadTheme();
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    currentThemeIndex = prefs.getInt('themeIndex') ?? 0;
    currentTheme = availableThemes[currentThemeIndex];
    notifyListeners();
  }

  Future<void> saveTheme(int themeIndex) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeIndex', themeIndex);
  }

  List<ThemeData> availableThemes = [
    // Tema 1: Ocean Depths
    ThemeData(
      primaryColor: const Color(0xFF1A5F7A),
      scaffoldBackgroundColor: const Color(0xFFE5F8FF),
      appBarTheme: const AppBarTheme(
        color: Color(0xFF1A5F7A),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      cardColor: Colors.white,
      iconTheme: const IconThemeData(color: Color(0xFF1A5F7A)),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
            color: Color(0xFF1A5F7A),
            fontSize: 24,
            fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(
            color: Color(0xFF1A5F7A),
            fontSize: 20,
            fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: Color(0xFF333333)),
        bodyMedium: TextStyle(color: Color(0xFF666666)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A5F7A),
          foregroundColor: Colors.white,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF3CAEA3),
        foregroundColor: Colors.white,
      ),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF1A5F7A),
        secondary: Color(0xFF3CAEA3),
        tertiary: Color(0xFFF6D55C),
        background: Color(0xFFE5F8FF),
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFF333333),
      ),
    ),

    // Tema 2: Gustav's Green
    ThemeData(
      primaryColor: const Color(0xFF2C5F2D),
      scaffoldBackgroundColor: const Color(0xFFF0F7F4),
      appBarTheme: const AppBarTheme(
        color: Color(0xFF2C5F2D),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      cardColor: Colors.white,
      iconTheme: const IconThemeData(color: Color(0xFF2C5F2D)),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
            color: Color(0xFF2C5F2D),
            fontSize: 24,
            fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(
            color: Color(0xFF2C5F2D),
            fontSize: 20,
            fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: Color(0xFF333333)),
        bodyMedium: TextStyle(color: Color(0xFF666666)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2C5F2D),
          foregroundColor: Colors.white,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF2C5F2D),
        secondary: Color(0xFF4CAF50),
        tertiary: Color(0xFF97BC62),
        background: Color(0xFFF0F7F4),
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFF333333),
      ),
    ),

    // Tema 3: Mystic Amethyst
    ThemeData(
      primaryColor: const Color(0xFF4A0E4E),
      scaffoldBackgroundColor: const Color(0xFF2D2D3A),
      appBarTheme: const AppBarTheme(
        color: Color(0xFF4A0E4E),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      cardColor: const Color(0xFF3A3A4A),
      iconTheme: const IconThemeData(color: Colors.white),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
            color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white70),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF810CA8),
          foregroundColor: Colors.white,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF810CA8),
        foregroundColor: Colors.white,
      ),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF4A0E4E),
        secondary: Color(0xFF810CA8),
        tertiary: Color(0xFFC147E9),
        background: Color(0xFF2D2D3A),
        surface: Color(0xFF3A3A4A),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
      ),
    ),

    // Tema 4: Sunset Glow
    ThemeData(
      primaryColor: const Color(0xFFFF6B35),
      scaffoldBackgroundColor: const Color(0xFFFFF7F2),
      appBarTheme: const AppBarTheme(
        color: Color(0xFFFF6B35),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      cardColor: Colors.white,
      iconTheme: const IconThemeData(color: Color(0xFFFF6B35)),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
            color: Color(0xFFFF6B35),
            fontSize: 24,
            fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(
            color: Color(0xFFFF6B35),
            fontSize: 20,
            fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: Color(0xFF333333)),
        bodyMedium: TextStyle(color: Color(0xFF666666)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF6B35),
          foregroundColor: Colors.white,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFFF7C59F),
        foregroundColor: Colors.white,
      ),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFFFF6B35),
        secondary: Color(0xFFF7C59F),
        tertiary: Color(0xFFFFCA7A),
        background: Color(0xFFFFF7F2),
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Color(0xFF333333),
        onSurface: Color(0xFF333333),
      ),
    ),

    // Tema 5: Lavender Bliss
    ThemeData(
      primaryColor: const Color(0xFF7E57C2),
      scaffoldBackgroundColor: const Color(0xFFF6F3FF),
      appBarTheme: const AppBarTheme(
        color: Color(0xFF7E57C2),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      cardColor: Colors.white,
      iconTheme: const IconThemeData(color: Color(0xFF7E57C2)),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
            color: Color(0xFF7E57C2),
            fontSize: 24,
            fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(
            color: Color(0xFF7E57C2),
            fontSize: 20,
            fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: const Color(0xFF333333)),
        bodyMedium: TextStyle(color: Color(0xFF666666)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7E57C2),
          foregroundColor: Colors.white,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFFB39DDB),
        foregroundColor: Colors.white,
      ),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF7E57C2),
        secondary: Color(0xFFB39DDB),
        tertiary: Color(0xFFD1C4E9),
        background: Color(0xFFF6F3FF),
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Color(0xFF333333),
        onSurface: Color(0xFF333333),
      ),
    ),
  ];

  void changeTheme(int themeIndex) {
    currentThemeIndex = themeIndex;
    currentTheme = availableThemes[themeIndex];
    saveTheme(themeIndex);
    notifyListeners();
  }
}
