import 'dart:developer';

import 'package:flutter/material.dart';

class ThemeServices with ChangeNotifier {
  bool isDarkMode = true;

  bool get themeValue => isDarkMode;

  ThemeMode get themeMode => isDarkMode ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    log("isDarkMode: $isDarkMode");
    notifyListeners();
  }
}
