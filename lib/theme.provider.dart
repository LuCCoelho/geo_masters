import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark; // Initial theme mode

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = (_themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light);
    notifyListeners(); // Notify listeners to rebuild
  }
}
