import 'package:flutter/material.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeData _themeData;

  ThemeNotifier(this._themeData);

  ThemeData getTheme() => _themeData;

  void setLightMode() {
    _themeData = ThemeData.light().copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        primary: Colors.blue,
        secondary: Colors.blueAccent,
      ),
    );
    notifyListeners();
  }

  void setDarkMode() {
    _themeData = ThemeData.dark().copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        primary: const Color.fromARGB(255, 255, 255, 255),
        secondary: const Color.fromARGB(255, 0, 0, 0),
      ),
    );
    notifyListeners();
  }
}
