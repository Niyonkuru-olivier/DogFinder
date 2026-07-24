import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/app_providers.dart';
import 'providers/breed_provider.dart';
import 'routes/app_routes.dart';
import 'screens/compare_screen.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';
import 'utils/constants.dart';

void main() {
  runApp(const DogFinderApp());
}

class DogFinderApp extends StatelessWidget {
  const DogFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BreedProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => RandomDogProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => CompareProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: appName,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            initialRoute: AppRoutes.splash,
            routes: {
              AppRoutes.splash: (_) => const SplashScreen(),
              AppRoutes.home: (_) => const HomeScreen(),
              AppRoutes.compare: (_) => const CompareScreen(),
            },
          );
        },
      ),
    );
  }
}
