import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/commit.dart';
import '../services/ai_agent_service.dart';
import '../utils/modern_theme.dart';

class DataTimelineScreen extends StatefulWidget {
  final List<Commit> commits;

  const DataTimelineScreen({super.key, required this.commits});

  @override
  State<DataTimelineScreen> createState() => _DataTimelineScreenState();
}

class _DataTimelineScreenState extends State<DataTimelineScreen> {
  final AIAgentService _aiService = AIAgentService();
  String _patternAnalysis = '';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadPatternAnalysis();
  }

  Future<void> _loadPatternAnalysis() async {
    if (widget.commits.length < 3) return;

    setState(() => _loading = true);
    final analysis = await _aiService.generatePatternInsights(widget.commits);
    setState(() {
      _patternAnalysis = analysis;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Data Timeline'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ModernTheme.background,
              ModernTheme.iosPurple.withOpacity(0.08),
            ],
          ),
        ),
        child: SafeArea(
          child: widget.commits.isEmpty
              ? _buildEmptyState()
              : ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    const SizedBox(height: 20),
                    _buildStatsCards(),
                    const SizedBox(height: 30),
                    if (widget.commits.length >= 3) _buildPatternAnalysis(),
                    const SizedBox(height: 30),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.insights_outlined,
            size: 80,
            color: ModernTheme.textTertiary.withOpacity(0.3),
          ),
          const SizedBox(height: 20),
          const Text(
            'Not enough data',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: ModernTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    final avgConfidence = widget.commits.isEmpty
        ? 0
        : widget.commits.map((c) => c.confidence).reduce((a, b) => a + b) /
            widget.commits.length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Commits',
            '${widget.commits.length}',
            Icons.commit,
            ModernTheme.iosBlue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Avg Confidence',
            '${avgConfidence.toInt()}%',
            Icons.trending_up,
            ModernTheme.accentGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: ModernTheme.glassBox(opacity: 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 16),
              Text(
                value,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: ModernTheme.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatternAnalysis() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AI Pattern Analysis',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: ModernTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ModernTheme.iosPurple.withOpacity(0.15),
                    ModernTheme.iosBlue.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : SelectableText(
                      _patternAnalysis,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        color: ModernTheme.textPrimary,
                        height: 1.6,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
