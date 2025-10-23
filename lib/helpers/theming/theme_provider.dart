import 'package:flutter/material.dart';
import 'package:health_dashboard/helpers/theming/theme.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _themeMode = lightMode;
  ThemeData get themeData => _themeMode;
  bool isDarkMode = false;

  set themeState(ThemeData themeData) {
    _themeMode = themeData;
    notifyListeners();
  }

  void toggleTheme() {
    if (_themeMode == lightMode) {
      _themeMode = darkMode;
      isDarkMode = true;
    } else {
      _themeMode = lightMode;
      isDarkMode = false;
    }
    notifyListeners();
  }
}
