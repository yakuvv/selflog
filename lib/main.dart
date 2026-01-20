import 'package:flutter/material.dart';
import 'screens/landing_screen.dart';
import 'utils/app_theme.dart';

void main() {
  runApp(const SelfLogApp());
}

class SelfLogApp extends StatelessWidget {
  const SelfLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SELFLOG',
      theme: AppTheme.darkTheme,
      home: const LandingScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
