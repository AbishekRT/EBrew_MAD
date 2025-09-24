import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Theme provider managing app theme state
class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isDarkMode = false;

  // Getters
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _isDarkMode;

  /// Set theme mode
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _updateDarkModeStatus();
    notifyListeners();
  }

  /// Toggle between light and dark theme
  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      setThemeMode(ThemeMode.dark);
    } else if (_themeMode == ThemeMode.dark) {
      setThemeMode(ThemeMode.light);
    } else {
      // If system mode, toggle to opposite of current system theme
      setThemeMode(_isDarkMode ? ThemeMode.light : ThemeMode.dark);
    }
  }

  /// Update dark mode status based on current theme mode
  void _updateDarkModeStatus() {
    if (_themeMode == ThemeMode.dark) {
      _isDarkMode = true;
    } else if (_themeMode == ThemeMode.light) {
      _isDarkMode = false;
    }
    // For system mode, this will be updated by the system
  }

  /// Update system theme status (called when system theme changes)
  void updateSystemTheme(bool isSystemDark) {
    if (_themeMode == ThemeMode.system) {
      _isDarkMode = isSystemDark;
      notifyListeners();
    }
  }

  /// Get light theme data
  ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.brown,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFD7CCC8),
      foregroundColor: Color(0xFF3E2723),
      elevation: 2,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFFFFF3E0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFA1887F),
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFFD7CCC8),
      selectedItemColor: Color(0xFF4E342E),
      unselectedItemColor: Color(0xFFA5817B),
      type: BottomNavigationBarType.fixed,
    ),
  );

  /// Get dark theme data
  ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.brown,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF1C1C1C),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF4E342E),
      foregroundColor: Color(0xFFFFF3E0),
      elevation: 2,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF3E2723),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6D4C41),
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF6D4C41),
      selectedItemColor: Color(0xFFFFAB91),
      unselectedItemColor: Color(0xFFBDBDBD),
      type: BottomNavigationBarType.fixed,
    ),
  );
}
