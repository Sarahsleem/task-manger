import 'package:flutter/material.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../data/models/weather.dart';
import '../../data/repo/weather_repo.dart';


class WeatherProvider with ChangeNotifier {
  final WeatherService _weatherService;
  final LocalStorageService _localStorageService;

  Weather? _currentWeather;
  String _currentCity = '';
  bool _isLoading = false;
  String? _error;

  WeatherProvider(this._weatherService, this._localStorageService) {
    _loadLastCity();
  }

  Weather? get currentWeather => _currentWeather;
  String get currentCity => _currentCity;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> _loadLastCity() async {
    final lastCity = await _localStorageService.getLastCity();
    if (lastCity != null) {
      _currentCity = lastCity;
      await getWeather(lastCity);
    }
  }

  Future<void> getWeather(String cityName) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentWeather = await _weatherService.getWeather(cityName);
      _currentCity = cityName;
      await _localStorageService.setLastCity(cityName);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}