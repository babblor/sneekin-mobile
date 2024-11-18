import 'dart:developer';

import 'package:flutter/material.dart';

class ThemeServices with ChangeNotifier {
  bool isDarkMode = true;

  ThemeMode get themeMode => isDarkMode ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    log("isDarkMode: $isDarkMode");
    notifyListeners();
  }
}
