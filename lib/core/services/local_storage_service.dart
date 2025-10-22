import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _lastCityKey = 'last_city';

  Future<void> setLastCity(String cityName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastCityKey, cityName);
  }

  Future<String?> getLastCity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastCityKey);
  }
  static const String _themeKey = 'theme_preference';

  Future<void> setThemePreference(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, theme);
  }

  Future<String?> getThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey);
  }
}