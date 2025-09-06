import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeSwitch extends ChangeNotifier {
  static const String _themeModeKey = 'themeMode';
  ThemeMode themeModeValue = ThemeMode.system;

  ThemeSwitch() {
    _loadThemeMode(); // Load from shared prefs
  }
  bool get isDarkMode => themeModeValue == ThemeMode.dark;
  bool get isLightMode => themeModeValue == ThemeMode.light;
  void switchThemeData(bool isOn) {
    themeModeValue = isOn ? ThemeMode.light : ThemeMode.dark;
    _saveThemeMode(themeModeValue);
    notifyListeners();
  }
  void switchToSystemTheme() {
    themeModeValue = ThemeMode.system;
    _saveThemeMode(themeModeValue);
    notifyListeners();
  }

  Future<void> _saveThemeMode(ThemeMode themeMode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, themeMode.index);
  }

Future<void> _loadThemeMode() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey(_themeModeKey)) {
    int index = prefs.getInt(_themeModeKey)!;
    themeModeValue = ThemeMode.values[index];
  } else {
    themeModeValue = ThemeMode.system; // use device theme
  }
  notifyListeners();
}

}

