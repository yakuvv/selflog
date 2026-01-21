import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../utils/modern_theme.dart';
import 'timeline_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    setState(() => _isLoading = true);

    // Simulate auth - in production, use Firebase Auth
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const TimelineScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ModernTheme.background,
              ModernTheme.iosPurple.withOpacity(0.15),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () => Navigator.pop(context),
                  color: ModernTheme.textPrimary,
                ),
                const SizedBox(height: 40),
                Text(
                  _isLogin ? 'Welcome\nBack' : 'Create\nAccount',
                  style: Theme.of(context).textTheme.displayMedium,
                )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: -0.2, end: 0, curve: Curves.easeOutQuart),
                const SizedBox(height: 60),
                _buildGlassInput(
                  controller: _emailController,
                  hint: 'Email',
                  icon: Icons.email_outlined,
                  delay: 0,
                ),
                const SizedBox(height: 20),
                _buildGlassInput(
                  controller: _passwordController,
                  hint: 'Password',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  delay: 150,
                ),
                const SizedBox(height: 40),
                _buildAuthButton(),
                const SizedBox(height: 24),
                Center(
                  child: GestureDetector(
                    onTap: () => setState(() => _isLogin = !_isLogin),
                    child: Text(
                      _isLogin
                          ? "Don't have an account? Sign Up"
                          : 'Already have an account? Login',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: ModernTheme.iosBlue,
                          ),
                    ),
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 600.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    required int delay,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: ModernTheme.glassBox(opacity: 0.05),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            style: const TextStyle(color: ModernTheme.textPrimary),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: ModernTheme.textTertiary),
              prefixIcon: Icon(icon, color: ModernTheme.iosBlue),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(20),
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: delay.ms)
        .slideX(begin: -0.2, end: 0, curve: Curves.easeOutQuart);
  }

  Widget _buildAuthButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _handleAuth,
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
          child: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  _isLogin ? 'Login' : 'Sign Up',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: 450.ms)
        .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuart)
        .scale(begin: const Offset(0.95, 0.95), curve: Curves.easeOutQuart);
  }
}
