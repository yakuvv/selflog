import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _particleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Animated mesh gradient
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

          // Floating orbs
          ...List.generate(8, (index) => _buildFloatingOrb(index, size)),

          // Main scrollable content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),

                          // Logo with glow
                          _buildLogoWithGlow(),

                          const SizedBox(height: 24),

                          // Title with gradient
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [
                                ModernTheme.iosBlue,
                                ModernTheme.iosPurple,
                                ModernTheme.iosIndigo,
                              ],
                            ).createShader(bounds),
                            child: const Text(
                              'SELFLOG',
                              style: TextStyle(
                                fontSize: 64,
                                fontWeight: FontWeight.w900,
                                height: 0.9,
                                letterSpacing: -3,
                                color: Colors.white,
                              ),
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 800.ms, delay: 200.ms)
                              .slideY(begin: -0.5, curve: Curves.easeOutCubic)
                              .shimmer(delay: 1000.ms, duration: 2000.ms),

                          const SizedBox(height: 16),

                          const Text(
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

                          const SizedBox(height: 60),

                          // Feature cards with icons
                          _buildEnhancedFeature(
                            icon: Icons.lock_outline,
                            iconColor: ModernTheme.iosBlue,
                            title: 'Immutable',
                            subtitle: 'Every decision is a permanent commit',
                            delay: 600,
                            gradient: [
                              ModernTheme.iosBlue,
                              ModernTheme.iosPurple
                            ],
                          ),

                          const SizedBox(height: 16),

                          _buildEnhancedFeature(
                            icon: Icons.psychology_outlined,
                            iconColor: ModernTheme.iosPurple,
                            title: 'AI-Powered',
                            subtitle: 'Intelligent analysis of your evolution',
                            delay: 750,
                            gradient: [
                              ModernTheme.iosPurple,
                              ModernTheme.iosIndigo
                            ],
                          ),

                          const SizedBox(height: 16),

                          _buildEnhancedFeature(
                            icon: Icons.mic_outlined,
                            iconColor: ModernTheme.iosIndigo,
                            title: 'Voice Notes',
                            subtitle: 'Capture thoughts instantly',
                            delay: 900,
                            gradient: [
                              ModernTheme.iosIndigo,
                              ModernTheme.iosBlue
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 60),

                      // CTA button at bottom
                      _buildEnhancedCTA(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingOrb(int index, Size size) {
    final random = (index * 37) % 100;
    final orbSize = 120.0 + (index * 30);

    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        final progress = ((_particleController.value * 2) + random / 100) % 1.0;
        final xOffset = math.sin(progress * math.pi * 2) * 40;

        return Positioned(
          left: size.width * (0.1 + (index * 0.15)) + xOffset,
          top: size.height * progress,
          child: Container(
            width: orbSize,
            height: orbSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  [
                    ModernTheme.iosBlue,
                    ModernTheme.iosPurple,
                    ModernTheme.iosIndigo,
                  ][index % 3]
                      .withOpacity(0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogoWithGlow() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [ModernTheme.iosBlue, ModernTheme.iosPurple],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: ModernTheme.iosBlue
                    .withOpacity(0.5 + _pulseController.value * 0.3),
                blurRadius: 30 + _pulseController.value * 20,
                offset: const Offset(0, 10),
                spreadRadius: _pulseController.value * 5,
              ),
            ],
          ),
          child: const Icon(
            Icons.psychology,
            size: 45,
            color: Colors.white,
          ),
        );
      },
    )
        .animate()
        .fadeIn(duration: 800.ms)
        .scale(begin: const Offset(0.5, 0.5), curve: Curves.easeOutBack);
  }

  Widget _buildEnhancedFeature({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required int delay,
    required List<Color> gradient,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient.map((c) => c.withOpacity(0.1)).toList(),
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradient.map((c) => c.withOpacity(0.2)).toList(),
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: gradient[0].withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 28,
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
                      style: const TextStyle(
                        fontSize: 14,
                        color: ModernTheme.textTertiary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: delay.ms)
        .slideX(begin: -0.3, curve: Curves.easeOutCubic)
        .shimmer(delay: (delay + 500).ms, duration: 1500.ms);
  }

  Widget _buildEnhancedCTA() {
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
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Container(
            width: double.infinity,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [ModernTheme.iosBlue, ModernTheme.iosPurple],
              ),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: ModernTheme.iosBlue
                      .withOpacity(0.5 + _pulseController.value * 0.2),
                  blurRadius: 30 + _pulseController.value * 10,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Get Started',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(width: 12),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ],
            ),
          );
        },
      ),
    )
        .animate()
        .fadeIn(duration: 800.ms, delay: 1200.ms)
        .slideY(begin: 0.5, curve: Curves.easeOutCubic)
        .shimmer(delay: 2000.ms, duration: 2000.ms);
  }
}
