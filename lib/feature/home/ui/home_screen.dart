import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../task/logic/providers/task_provider.dart';
import '../../weather/logic/providers/weather_provider.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) { // Make sure this is 'context' lowercase
    final taskProvider = Provider.of<TaskProvider>(context);
    final weatherProvider = Provider.of<WeatherProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          _buildWelcomeSection(context),
          const SizedBox(height: 24),

          // Task Summary
          _buildTaskSummary(context, taskProvider),
          const SizedBox(height: 24),

          // Weather Section
          _buildWeatherSection(context, weatherProvider),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) { // Add BuildContext parameter
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome!',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Here\'s your overview for today',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskSummary(BuildContext context, TaskProvider taskProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Task Summary',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  context,
                  'Total',
                  taskProvider.totalTasks.toString(),
                  Icons.list_alt,
                ),
                _buildSummaryItem(
                  context,
                  'Completed',
                  taskProvider.completedTasks.toString(),
                  Icons.check_circle,
                  color: Colors.green,
                ),
                _buildSummaryItem(
                  context,
                  'Pending',
                  taskProvider.pendingTasks.toString(),
                  Icons.pending_actions,
                  color: Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(BuildContext context, String title, String value, IconData icon, {Color? color}) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
  Widget _buildWeatherSection(BuildContext context, WeatherProvider weatherProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Weather',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: weatherProvider.isLoading
                      ? null
                      : () {
                    if (weatherProvider.currentCity.isNotEmpty) {
                      weatherProvider.getWeather(weatherProvider.currentCity);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (weatherProvider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (weatherProvider.error != null)
              _buildErrorWidget(context, weatherProvider)
            else if (weatherProvider.currentWeather != null)
                _buildWeatherInfo(context, weatherProvider)
              else
                _buildNoWeatherInfo(context, weatherProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, WeatherProvider weatherProvider) {
    return Column(
      children: [
        Text(
          'Error: ${weatherProvider.error}',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => weatherProvider.clearError(),
          child: const Text('Dismiss'),
        ),
      ],
    );
  }

  Widget _buildWeatherInfo(BuildContext context, WeatherProvider weatherProvider) {
    final weather = weatherProvider.currentWeather!;
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.location_on),
            const SizedBox(width: 8),
            Text(
              '${weather.cityName}, ${weather.country}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              '${weather.temperature.toStringAsFixed(1)}°C',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Condition: ${weather.condition}'),
                Text('Humidity: ${weather.humidity}%'),
                Text('Wind: ${weather.windSpeed.toStringAsFixed(1)} kph'),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNoWeatherInfo(BuildContext context, WeatherProvider weatherProvider) {
    return Column(
      children: [
        const Text('No weather data available'),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            // You can navigate to weather screen or trigger search
            // For now, let's just show a message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Enter a city in the Weather tab')),
            );
          },
          child: const Text('Check Weather'),
        ),
      ],
    );
  }
}