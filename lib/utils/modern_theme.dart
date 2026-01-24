import 'package:flutter/material.dart';

class ResponsiveSize {
  static late double _screenWidth;
  static late double _screenHeight;
  static late double _scaleFactor;

  static void init(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height;

    // iPhone 16 Pro Max reference: 430 x 932
    _scaleFactor = _screenWidth / 430;
  }

  static double width(double size) => size * _scaleFactor;
  static double height(double size) => size * (_screenHeight / 932);
  static double font(double size) => size * _scaleFactor;
}

class ModernTheme {
  // iOS-inspired colors
  static const Color iosBlue = Color(0xFF007AFF);
  static const Color iosPurple = Color(0xFF5856D6);
  static const Color iosIndigo = Color(0xFF5AC8FA);

  // Dark theme colors
  static const Color background = Color(0xFF000000);
  static const Color backgroundSecondary = Color(0xFF1C1C1E);
  static const Color backgroundTertiary = Color(0xFF2C2C2E);
  static const Color elevated = Color(0xFF3A3A3C);

  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFEBEBF5);
  static const Color textTertiary = Color(0xFF8E8E93);

  // Accent colors
  static const Color accent = Color(0xFF5E5CE6);
  static const Color accentGreen = Color(0xFF30D158);
  static const Color accentOrange = Color(0xFFFF9F0A);
  static const Color accentRed = Color(0xFFFF453A);

  // Glass morphism effect
  static BoxDecoration glassBox({
    Color? color,
    double blur = 20,
    double opacity = 0.1,
  }) {
    return BoxDecoration(
      color: (color ?? Colors.white).withOpacity(opacity),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: Colors.white.withOpacity(0.1),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: blur,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    primaryColor: iosBlue,
    colorScheme: const ColorScheme.dark(
      primary: iosBlue,
      secondary: iosPurple,
      surface: backgroundSecondary,
      background: background,
      error: accentRed,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: textPrimary,
        fontSize: 56,
        fontWeight: FontWeight.w700,
        letterSpacing: -2,
        height: 1.1,
      ),
      displayMedium: TextStyle(
        color: textPrimary,
        fontSize: 40,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.5,
      ),
      headlineMedium: TextStyle(
        color: textPrimary,
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
      titleLarge: TextStyle(
        color: textPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
      ),
      bodyLarge: TextStyle(
        color: textPrimary,
        fontSize: 17,
        height: 1.5,
        letterSpacing: -0.4,
      ),
      bodyMedium: TextStyle(
        color: textSecondary,
        fontSize: 15,
        height: 1.4,
        letterSpacing: -0.2,
      ),
    ),
  );
}
