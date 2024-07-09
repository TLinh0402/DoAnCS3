import 'package:flutter/material.dart';

class ThemeChange extends ChangeNotifier {
  String currentTheme = "false";
  ThemeMode get themeMode {
    if (currentTheme == "true") {
      return ThemeMode.dark;
    } else {
      return ThemeMode.light;
    }
  }

  changeTheme(String theme) {
    currentTheme = theme;
    notifyListeners();
  }
}
