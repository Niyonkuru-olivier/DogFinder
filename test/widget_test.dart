import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:dogfinder/providers/app_providers.dart';
import 'package:dogfinder/providers/breed_provider.dart';
import 'package:dogfinder/routes/app_routes.dart';
import 'package:dogfinder/screens/splash_screen.dart';

void main() {
  testWidgets('Splash screen shows app branding', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => BreedProvider()),
          ChangeNotifierProvider(create: (_) => FavoritesProvider()..initialize()),
          ChangeNotifierProvider(create: (_) => RandomDogProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()..initialize()),
          ChangeNotifierProvider(create: (_) => CompareProvider()),
        ],
        child: MaterialApp(
          routes: {
            AppRoutes.home: (_) => const Scaffold(body: Text('Home')),
          },
          home: const SplashScreen(),
        ),
      ),
    );

    expect(find.text('DogFinder'), findsOneWidget);
    expect(find.text('Discover amazing dog breeds'), findsOneWidget);
    expect(find.text('Loading...'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });
}
