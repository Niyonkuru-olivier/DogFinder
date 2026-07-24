import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../routes/app_routes.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.pets, size: 72, color: Colors.white),
            )
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .scale(
                  begin: const Offset(0.92, 0.92),
                  end: const Offset(1.08, 1.08),
                  duration: 1200.ms,
                ),
            const SizedBox(height: 28),
            Text(
              appName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
            const SizedBox(height: 10),
            Text(
              appTagline,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 16,
              ),
            ).animate().fadeIn(duration: 800.ms, delay: 200.ms),
            const SizedBox(height: 40),
            const Text(
              'Loading...',
              style: TextStyle(color: Colors.white70),
            ).animate(onPlay: (controller) => controller.repeat()).fade(
                  begin: 0.4,
                  end: 1,
                  duration: 900.ms,
                ),
          ],
        ),
      ),
    );
  }
}
