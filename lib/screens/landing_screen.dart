import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../utils/modern_theme.dart';
import 'auth_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with TickerProviderStateMixin {
  late AnimationController _floatingController;

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ModernTheme.background,
              ModernTheme.iosPurple.withOpacity(0.1),
              ModernTheme.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Animated background particles
              ...List.generate(3, (index) => _buildFloatingOrb(index)),

              // Main content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(flex: 2),

                    // Logo/App name
                    _buildHeader(),

                    const SizedBox(height: 60),

                    // Feature cards
                    _buildFeatureCard(
                      'Immutable',
                      'Every decision is a commit.\nHistory cannot be rewritten.',
                      Icons.lock_outline,
                      ModernTheme.iosBlue,
                      0,
                    ),

                    const SizedBox(height: 20),

                    _buildFeatureCard(
                      'AI-Powered',
                      'Agentic analysis of your\nreasoning evolution.',
                      Icons.psychology_outlined,
                      ModernTheme.iosPurple,
                      1,
                    ),

                    const SizedBox(height: 20),

                    _buildFeatureCard(
                      'Voice Notes',
                      'Capture thoughts instantly\nwith voice recording.',
                      Icons.mic_none,
                      ModernTheme.iosIndigo,
                      2,
                    ),

                    const Spacer(flex: 3),

                    // CTA Button
                    _buildCTAButton(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingOrb(int index) {
    return AnimatedBuilder(
      animation: _floatingController,
      builder: (context, child) {
        return Positioned(
          top: 100 + (index * 200) + (_floatingController.value * 50),
          right: 50 + (index * 80),
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  [
                    ModernTheme.iosBlue,
                    ModernTheme.iosPurple,
                    ModernTheme.iosIndigo
                  ][index]
                      .withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: Container(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELFLOG',
          style: Theme.of(context).textTheme.displayLarge,
        )
            .animate()
            .fadeIn(duration: 800.ms, delay: 200.ms)
            .slideY(begin: -0.3, end: 0, curve: Curves.easeOutQuart)
            .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutQuart),
        const SizedBox(height: 12),
        Text(
          'Version control for\nhuman decisions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: ModernTheme.textTertiary,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
        )
            .animate()
            .fadeIn(duration: 800.ms, delay: 400.ms)
            .slideY(begin: -0.2, end: 0, curve: Curves.easeOutQuart),
      ],
    );
  }

  Widget _buildFeatureCard(
    String title,
    String description,
    IconData icon,
    Color color,
    int index,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: ModernTheme.glassBox(opacity: 0.05),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: color,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            height: 1.5,
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
        .fadeIn(duration: 600.ms, delay: (600 + index * 150).ms)
        .slideX(begin: -0.2, end: 0, curve: Curves.easeOutQuart)
        .scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutQuart);
  }

  Widget _buildCTAButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const AuthScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [ModernTheme.iosBlue, ModernTheme.iosPurple],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: ModernTheme.iosBlue.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Get Started',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: 1200.ms)
        .slideY(begin: 0.3, end: 0, curve: Curves.easeOutQuart)
        .scale(begin: const Offset(0.95, 0.95), curve: Curves.easeOutQuart)
        .then()
        .shimmer(
            duration: 2000.ms,
            delay: 1000.ms,
            color: Colors.white.withOpacity(0.3));
  }
}
