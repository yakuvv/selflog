import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import 'dart:math' as math;
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
    final sortedCommits = [...widget.commits]
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
                    _buildConfidenceGraph(sortedCommits),
                    const SizedBox(height: 30),
                    _buildConstraintEvolution(sortedCommits),
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
          const SizedBox(height: 8),
          const Text(
            'Create more commits to see insights',
            style: TextStyle(color: ModernTheme.textTertiary),
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

    final totalConstraints = widget.commits.fold<int>(
      0,
      (sum, c) => sum + c.constraints.length,
    );

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Commits',
            '${widget.commits.length}',
            Icons.commit,
            ModernTheme.iosBlue,
            0,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Avg Confidence',
            '${avgConfidence.toInt()}%',
            Icons.trending_up,
            ModernTheme.accentGreen,
            1,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    int index,
  ) {
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
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 16),
              Text(
                value,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
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
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: (index * 100).ms)
        .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuart)
        .scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutQuart);
  }

  Widget _buildConfidenceGraph(List<Commit> commits) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Confidence Evolution',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: ModernTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 20),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: ModernTheme.glassBox(opacity: 0.05),
              child: SizedBox(
                height: 200,
                child: CustomPaint(
                  painter: ConfidenceGraphPainter(commits),
                  child: Container(),
                ),
              ),
            ),
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: 200.ms)
        .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuart);
  }

  Widget _buildConstraintEvolution(List<Commit> commits) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Constraint Evolution',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: ModernTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 20),
        ...commits.asMap().entries.map((entry) {
          final index = entry.key;
          final commit = entry.value;
          return _buildConstraintBar(commit, index, commits.length);
        }).toList(),
      ],
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: 300.ms)
        .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuart);
  }

  Widget _buildConstraintBar(Commit commit, int index, int total) {
    final maxConstraints = widget.commits
        .map((c) => c.constraints.length)
        .reduce((a, b) => a > b ? a : b);
    final percentage =
        maxConstraints > 0 ? commit.constraints.length / maxConstraints : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: ModernTheme.glassBox(opacity: 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        commit.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ModernTheme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${commit.constraints.length}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ModernTheme.iosBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: ModernTheme.elevated.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation(
                      ModernTheme.iosBlue,
                    ),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: (400 + index * 50).ms)
        .slideX(begin: -0.2, end: 0, curve: Curves.easeOutQuart);
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
        const SizedBox(height: 20),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ModernTheme.iosPurple.withOpacity(0.1),
                    ModernTheme.iosBlue.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: ModernTheme.iosPurple.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: ModernTheme.iosPurple,
                        strokeWidth: 2,
                      ),
                    )
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
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: 500.ms)
        .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuart);
  }
}

class ConfidenceGraphPainter extends CustomPainter {
  final List<Commit> commits;

  ConfidenceGraphPainter(this.commits);

  @override
  void paint(Canvas canvas, Size size) {
    if (commits.isEmpty) return;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final gradient = LinearGradient(
      colors: [ModernTheme.iosBlue, ModernTheme.iosPurple],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    paint.shader = gradient;

    final path = Path();
    final points = <Offset>[];

    for (int i = 0; i < commits.length; i++) {
      final x = (size.width / (commits.length - 1)) * i;
      final y = size.height - (commits[i].confidence / 100 * size.height);
      points.add(Offset(x, y));

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Draw points
    final pointPaint = Paint()
      ..color = ModernTheme.iosBlue
      ..style = PaintingStyle.fill;

    for (var point in points) {
      canvas.drawCircle(point, 6, pointPaint);
      canvas.drawCircle(
        point,
        4,
        Paint()..color = ModernTheme.background,
      );
    }

    // Draw grid lines
    final gridPaint = Paint()
      ..color = ModernTheme.textTertiary.withOpacity(0.1)
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      final y = (size.height / 4) * i;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
