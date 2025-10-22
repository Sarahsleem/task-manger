import 'package:flutter/material.dart';
import '../../../../core/services/local_storage_service.dart';


class ThemeProvider with ChangeNotifier {
  final LocalStorageService _localStorageService;
  ThemeMode _themeMode = ThemeMode.system;

  ThemeProvider(this._localStorageService) {
    _loadThemePreference();
  }

  ThemeMode get themeMode => _themeMode;

  Future<void> _loadThemePreference() async {
    final themeString = await _localStorageService.getThemePreference();
    if (themeString == 'dark') {
      _themeMode = ThemeMode.dark;
    } else if (themeString == 'light') {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _localStorageService.setThemePreference(
        mode == ThemeMode.dark ? 'dark' :
        mode == ThemeMode.light ? 'light' : 'system'
    );
    notifyListeners();
  }

  void toggleTheme() {
    final newMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    setThemeMode(newMode);
  }

  bool get isDarkMode => _themeMode == ThemeMode.dark;
}