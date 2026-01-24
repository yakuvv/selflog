import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/timeline_screen.dart';
import 'utils/modern_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: ModernTheme.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const SelfLogApp());
}

class SelfLogApp extends StatelessWidget {
  const SelfLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SELFLOG',
      theme: ModernTheme.darkTheme,
      home: const TimelineScreen(), // SKIP landing, go straight to timeline
      debugShowCheckedModeBanner: false,
    );
  }
}
