import 'package:flutter/material.dart';

class ThemeServices with ChangeNotifier {
  bool isDarkMode = true;

  final bool _isThemeLoading = false;
  bool get isThemeLoading => _isThemeLoading;

  bool get themeValue => isDarkMode;

  ThemeMode get themeMode => isDarkMode ? ThemeMode.dark : ThemeMode.light;

  // void toggleTheme() {
  //   if (_isThemeLoading) return;
  //   try {
  //     _isThemeLoading = true;
  //     notifyListeners();
  //     isDarkMode = !isDarkMode;
  //     log("isDarkMode: $isDarkMode");
  //     _isThemeLoading = false;
  //     notifyListeners();
  //   } catch (e) {
  //     _isThemeLoading = false;
  //     notifyListeners();
  //   }
  // }
  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }
}
