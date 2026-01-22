import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../utils/modern_theme.dart';
import 'timeline_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with TickerProviderStateMixin {
  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Animated gradient background
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      ModernTheme.background,
                      Color.lerp(
                        ModernTheme.iosPurple,
                        ModernTheme.iosBlue,
                        _particleController.value,
                      )!
                          .withOpacity(0.15),
                      ModernTheme.background,
                    ],
                  ),
                ),
              );
            },
          ),

          // Floating particles
          ...List.generate(
            5,
            (index) => _AnimatedParticle(
              controller: _particleController,
              index: index,
              size: size,
            ),
          ),

          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(flex: 1),

                  // App logo/icon
                  _buildLogo(),

                  const SizedBox(height: 24),

                  // Title
                  Text(
                    'SELFLOG',
                    style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.w900,
                      height: 0.9,
                      letterSpacing: -3,
                      foreground: Paint()
                        ..shader = LinearGradient(
                          colors: [
                            ModernTheme.iosBlue,
                            ModernTheme.iosPurple,
                          ],
                        ).createShader(const Rect.fromLTWH(0, 0, 300, 100)),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 800.ms, delay: 200.ms)
                      .slideY(begin: -0.5, curve: Curves.easeOutCubic)
                      .shimmer(delay: 1000.ms, duration: 2000.ms),

                  const SizedBox(height: 16),

                  Text(
                    'Version control for\nhuman decisions',
                    style: TextStyle(
                      fontSize: 22,
                      height: 1.3,
                      color: ModernTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 800.ms, delay: 400.ms)
                      .slideY(begin: -0.3, curve: Curves.easeOutCubic),

                  const Spacer(flex: 2),

                  // Feature highlights
                  _buildFeatureHighlight(
                    icon: '🔒',
                    title: 'Immutable',
                    subtitle: 'Every decision is a permanent commit',
                    delay: 600,
                  ),

                  const SizedBox(height: 20),

                  _buildFeatureHighlight(
                    icon: '🤖',
                    title: 'AI-Powered',
                    subtitle: 'Intelligent analysis of your evolution',
                    delay: 750,
                  ),

                  const SizedBox(height: 20),

                  _buildFeatureHighlight(
                    icon: '🎤',
                    title: 'Voice Notes',
                    subtitle: 'Capture thoughts instantly',
                    delay: 900,
                  ),

                  const Spacer(flex: 2),

                  // CTA Button
                  _buildGetStartedButton(),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [ModernTheme.iosBlue, ModernTheme.iosPurple],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ModernTheme.iosBlue.withOpacity(0.5),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Icon(
        Icons.psychology,
        size: 45,
        color: Colors.white,
      ),
    )
        .animate()
        .fadeIn(duration: 800.ms)
        .scale(begin: const Offset(0.5, 0.5), curve: Curves.easeOutBack);
  }

  Widget _buildFeatureHighlight({
    required String icon,
    required String title,
    required String subtitle,
    required int delay,
  }) {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ModernTheme.iosBlue.withOpacity(0.15),
                ModernTheme.iosPurple.withOpacity(0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: ModernTheme.iosBlue.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              icon,
              style: const TextStyle(fontSize: 28),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: ModernTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: ModernTheme.textTertiary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: delay.ms)
        .slideX(begin: -0.3, curve: Curves.easeOutCubic);
  }

  Widget _buildGetStartedButton() {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const TimelineScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                    CurvedAnimation(
                        parent: animation, curve: Curves.easeOutCubic),
                  ),
                  child: child,
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        height: 64,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [ModernTheme.iosBlue, ModernTheme.iosPurple],
          ),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: ModernTheme.iosBlue.withOpacity(0.5),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Get Started',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 12),
            const Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
              size: 24,
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 800.ms, delay: 1200.ms)
        .slideY(begin: 0.5, curve: Curves.easeOutCubic)
        .shimmer(delay: 2000.ms, duration: 2000.ms);
  }
}

class _AnimatedParticle extends StatelessWidget {
  final AnimationController controller;
  final int index;
  final Size size;

  const _AnimatedParticle({
    required this.controller,
    required this.index,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final random = (index * 37) % 100;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final progress = (controller.value + random / 100) % 1.0;

        return Positioned(
          left: size.width * (0.1 + (index * 0.2)),
          top: size.height * progress,
          child: Container(
            width: 100 + (index * 20),
            height: 100 + (index * 20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  [
                    ModernTheme.iosBlue,
                    ModernTheme.iosPurple,
                    ModernTheme.iosIndigo,
                  ][index % 3]
                      .withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
