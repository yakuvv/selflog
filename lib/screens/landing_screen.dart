import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/app_theme.dart';
import 'timeline_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),

              // Logo/Title
              Text(
                'SELFLOG',
                style: Theme.of(context).textTheme.displayLarge,
              )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 100.ms)
                  .slideX(begin: -0.2, end: 0),

              const SizedBox(height: 16),

              Text(
                'Version control for human decisions',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 300.ms)
                  .slideX(begin: -0.2, end: 0),

              const SizedBox(height: 48),

              // Core principles
              _buildPrinciple(
                context,
                'Immutable',
                'Every decision is a commit. History cannot be rewritten.',
                0,
              ),

              const SizedBox(height: 24),

              _buildPrinciple(
                context,
                'Analytical',
                'Pure data-driven reasoning. No advice, only diffs.',
                1,
              ),

              const SizedBox(height: 24),

              _buildPrinciple(
                context,
                'Traceable',
                'Track confidence, constraints, and reasoning evolution.',
                2,
              ),

              const Spacer(),

              // CTA Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const TimelineScreen(),
                      ),
                    );
                  },
                  child: const Text('ENTER TIMELINE'),
                ),
              )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 800.ms)
                  .slideY(begin: 0.3, end: 0)
                  .scale(begin: const Offset(0.8, 0.8)),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrinciple(
    BuildContext context,
    String title,
    String description,
    int index,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.surfaceLight.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.primary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: (500 + index * 100).ms)
        .slideX(begin: -0.2, end: 0);
  }
}
