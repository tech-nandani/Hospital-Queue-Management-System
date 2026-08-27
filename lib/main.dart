import 'package:flutter/material.dart';
import 'screens/splash/splash_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const HospitalQueueApp());
}

class HospitalQueueApp extends StatelessWidget {
  const HospitalQueueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hospital Queue Management',

      theme:AppTheme.lightTheme,

      home: const SplashScreen(),
    );
  }
}