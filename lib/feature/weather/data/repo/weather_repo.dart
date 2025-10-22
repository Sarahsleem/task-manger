import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather.dart';

class WeatherService {
  static const String _apiKey = 'd8750178d9664e20a2d104843252210'; // Get from https://www.weatherapi.com/
  static const String _baseUrl = 'http://api.weatherapi.com/v1';

  Future<Weather> getWeather(String cityName) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/current.json?key=$_apiKey&q=$cityName&aqi=no'),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      print('Weather API Response: $jsonResponse'); // Debug print
      return Weather.fromJson(jsonResponse);
    } else if (response.statusCode == 400) {
      throw Exception('City not found or invalid request');
    } else if (response.statusCode == 401) {
      throw Exception('Invalid API key');
    } else {
      throw Exception('Failed to load weather data: ${response.statusCode}');
    }
  }

  // Optional: Get 3-day forecast
  Future<Map<String, dynamic>> getForecast(String cityName, int days) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/forecast.json?key=$_apiKey&q=$cityName&days=$days&aqi=no'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load forecast data');
    }
  }
}