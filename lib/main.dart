import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'core/services/local_auth_service.dart';
import 'core/services/local_storage_service.dart';
import 'database/database.dart';
import 'feature/home/logic/providers/local_auth_provider.dart';
import 'feature/home/logic/providers/theme_provider.dart';
import 'feature/task/logic/providers/task_provider.dart';
import 'feature/weather/data/repo/weather_repo.dart';
import 'feature/weather/logic/providers/weather_provider.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AppDatabase database = AppDatabase();
  final WeatherService weatherService = WeatherService();
  final LocalStorageService localStorageService = LocalStorageService();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppDatabase>(create: (_) => database),
        ChangeNotifierProvider(
          create: (_) => TaskProvider(database),
        ),
        ChangeNotifierProvider(
          create: (_) => WeatherProvider(weatherService, localStorageService),
        ),
        ChangeNotifierProvider( // Add ThemeProvider
          create: (_) => ThemeProvider(localStorageService),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(LocalAuthService()),
        ),
      ],
      child: MaterialApp(
        title: 'Task & Weather App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
        ),
        themeMode: ThemeMode.system,
        home: const App(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}