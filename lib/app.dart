// import 'package:flutter/material.dart';
// import 'feature/home/ui/home_screen.dart';
// import 'feature/task/ui/screens/task_screen.dart';
// import 'feature/weather/ui/screens/weather_screen.dart';
//
// //
// // class App extends StatefulWidget {
// //   const App({super.key});
// //
// //   @override
// //   State<App> createState() => _AppState();
// // }
// //
// // class _AppState extends State<App> {
// //   int _currentIndex = 0;
// //   ThemeMode _themeMode = ThemeMode.system;
// //
// //   final List<Widget> _screens = [
// //     const HomeScreen(),
// //     const TasksScreen(),
// //     const WeatherScreen(),
// //   ];
// //
// //   final List<String> _appBarTitles = [
// //     'Dashboard',
// //     'Tasks',
// //     'Weather',
// //   ];
// //
// //   void _toggleTheme() {
// //     setState(() {
// //       _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
// //     });
// //   }
// //
// //   bool get _isDarkMode => _themeMode == ThemeMode.dark;
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       debugShowCheckedModeBanner: false,
// //       theme: ThemeData(
// //         useMaterial3: true,
// //         colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
// //         brightness: Brightness.light,
// //       ),
// //       darkTheme: ThemeData(
// //         useMaterial3: true,
// //         colorScheme: ColorScheme.fromSeed(
// //           seedColor: Colors.blue,
// //           brightness: Brightness.dark,
// //         ),
// //       ),
// //       themeMode: _themeMode,
// //       home: Scaffold(
// //         appBar: AppBar(
// //           title: Text(_appBarTitles[_currentIndex]),
// //           actions: [
// //             IconButton(
// //               icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
// //               onPressed: _toggleTheme,
// //             ),
// //           ],
// //         ),
// //         body: _screens[_currentIndex],
// //         bottomNavigationBar: NavigationBar(
// //           selectedIndex: _currentIndex,
// //           onDestinationSelected: (index) {
// //             setState(() {
// //               _currentIndex = index;
// //             });
// //           },
// //           destinations: const [
// //             NavigationDestination(
// //               icon: Icon(Icons.dashboard),
// //               label: 'Dashboard',
// //             ),
// //             NavigationDestination(
// //               icon: Icon(Icons.task),
// //               label: 'Tasks',
// //             ),
// //             NavigationDestination(
// //               icon: Icon(Icons.cloud),
// //               label: 'Weather',
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'feature/home/logic/providers/local_auth_provider.dart';
// import 'feature/home/logic/providers/theme_provider.dart';
// import 'feature/home/ui/home_screen.dart';
// import 'feature/lock/ui/lock_screen.dart';
// import 'feature/task/ui/screens/task_screen.dart';
// import 'feature/weather/ui/screens/weather_screen.dart';
//
//
// class App extends StatefulWidget {
//   const App({super.key});
//
//   @override
//   State<App> createState() => _AppState();
// }
//
// class _AppState extends State<App> {
//   int _currentIndex = 0;
//   ThemeMode _themeMode = ThemeMode.system;
//   final List<Widget> _screens = [
//     const HomeScreen(),
//     const TasksScreen(),
//     const WeatherScreen(),
//   ];
//
//   final List<String> _appBarTitles = [
//     'Dashboard',
//     'Tasks',
//     'Weather',
//   ];
//   void _toggleTheme() {
//     setState(() {
//       _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
//     });
//   }
//   bool get _isDarkMode => _themeMode == ThemeMode.dark;
//   @override
//   Widget build(BuildContext context) {
//     final authProvider = Provider.of<AuthProvider>(context);
//     final themeProvider = Provider.of<ThemeProvider>(context);
//
//     // Show lock screen if not authenticated
//     if (!authProvider.isAuthenticated) {
//       return const LockScreen();
//     }
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(_appBarTitles[_currentIndex]),
//         actions: [
//           IconButton(
//             icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
//             onPressed: () => themeProvider.toggleTheme(),
//           ),
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: () => authProvider.logout(),
//             tooltip: 'Lock App',
//           ),
//         ],
//       ),
//       body: _screens[_currentIndex],
//       bottomNavigationBar: NavigationBar(
//         selectedIndex: _currentIndex,
//         onDestinationSelected: (index) {
//           setState(() {
//             _currentIndex = index;
//           });
//         },
//         destinations: const [
//           NavigationDestination(
//             icon: Icon(Icons.dashboard),
//             label: 'Dashboard',
//           ),
//           NavigationDestination(
//             icon: Icon(Icons.task),
//             label: 'Tasks',
//           ),
//           NavigationDestination(
//             icon: Icon(Icons.cloud),
//             label: 'Weather',
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'feature/home/logic/providers/local_auth_provider.dart';
import 'feature/home/logic/providers/theme_provider.dart';

import 'feature/home/ui/home_screen.dart';
import 'feature/lock/ui/lock_screen.dart';
import 'feature/task/ui/screens/task_screen.dart';
import 'feature/weather/ui/screens/weather_screen.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const TasksScreen(),
    const WeatherScreen(),
  ];

  final List<String> _appBarTitles = [
    'Dashboard',
    'Tasks',
    'Weather',
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Show lock screen if not authenticated
    if (!authProvider.isAuthenticated) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
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
        themeMode: themeProvider.themeMode,
        home: const LockScreen(),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
      themeMode: themeProvider.themeMode,
      home: Scaffold(
        appBar: AppBar(
          title: Text(_appBarTitles[_currentIndex]),
          actions: [
            IconButton(
              icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: () => themeProvider.toggleTheme(),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => authProvider.logout(),
              tooltip: 'Lock App',
            ),
          ],
        ),
        body: _screens[_currentIndex],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.task),
              label: 'Tasks',
            ),
            NavigationDestination(
              icon: Icon(Icons.cloud),
              label: 'Weather',
            ),
          ],
        ),
      ),
    );
  }
}