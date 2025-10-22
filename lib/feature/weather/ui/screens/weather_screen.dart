import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/weather.dart';
import '../../logic/providers/weather_provider.dart';


class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _cityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Search Section
          _buildSearchSection(weatherProvider),
          const SizedBox(height: 24),

          // Weather Display
          Expanded(
            child: _buildWeatherDisplay(weatherProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection(WeatherProvider weatherProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Check Weather',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'Enter city name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: weatherProvider.isLoading
                      ? null
                      : () {
                    if (_cityController.text.isNotEmpty) {
                      weatherProvider.getWeather(_cityController.text);
                    }
                  },
                  child: const Text('Search'),
                ),
              ],
            ),
            if (weatherProvider.currentCity.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Last searched: ${weatherProvider.currentCity}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDisplay(WeatherProvider weatherProvider) {
    if (weatherProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (weatherProvider.error != null) {
      return _buildErrorWidget(weatherProvider);
    }

    if (weatherProvider.currentWeather != null) {
      return _buildWeatherDetails(weatherProvider.currentWeather!);
    }

    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Enter a city name to check the weather'),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(WeatherProvider weatherProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error: ${weatherProvider.error}',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => weatherProvider.clearError(),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherDetails(Weather weather) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // City Name
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_on, size: 24),
                const SizedBox(width: 8),
                Text(
                  weather.cityName,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Temperature
            Text(
              '${weather.temperature.toStringAsFixed(1)}°C',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Weather Condition
            Text(
              weather.condition,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              weather.description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 32),

            // Additional Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWeatherInfoItem(
                  'Humidity',
                  '${weather.humidity}%',
                  Icons.water_drop,
                ),
                _buildWeatherInfoItem(
                  'Wind Speed',
                  '${weather.windSpeed} m/s',
                  Icons.air,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherInfoItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }
}