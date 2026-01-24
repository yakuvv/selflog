import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../models/commit.dart';
import '../services/ai_agent_service.dart';
import '../services/analysis_service.dart';
import '../utils/modern_theme.dart';

class CompareScreen extends StatefulWidget {
  final Commit olderCommit;
  final Commit newerCommit;

  const CompareScreen({
    super.key,
    required this.olderCommit,
    required this.newerCommit,
  });

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  final AnalysisService _analysisService = AnalysisService();
  final AIAgentService _aiService = AIAgentService();

  String _aiAnalysis = '';
  bool _loadingAI = false;

  @override
  void initState() {
    super.initState();
    _loadAIAnalysis();
  }

  Future<void> _loadAIAnalysis() async {
    setState(() => _loadingAI = true);

    final analysis = await _aiService.generateAdvancedAnalysis(
      widget.olderCommit,
      widget.newerCommit,
    );

    setState(() {
      _aiAnalysis = analysis;
      _loadingAI = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final diff = _analysisService.generateDiff(
      widget.olderCommit,
      widget.newerCommit,
    );

    return Scaffold(
      backgroundColor: ModernTheme.background,
      appBar: AppBar(
        backgroundColor: ModernTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ModernTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Commit Comparison',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: ModernTheme.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildCommitCard(
                'BEFORE', widget.olderCommit, ModernTheme.accentRed, 0),
            const SizedBox(height: 20),
            _buildDiffIndicator(diff),
            const SizedBox(height: 20),
            _buildCommitCard(
                'AFTER', widget.newerCommit, ModernTheme.accentGreen, 1),
            const SizedBox(height: 30),
            _buildModernAnalysis(diff),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildCommitCard(String label, Commit commit, Color color, int index) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ModernTheme.backgroundSecondary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: color,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                DateFormat('MMM d, HH:mm').format(commit.timestamp),
                style: const TextStyle(
                  fontSize: 12,
                  color: ModernTheme.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            commit.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: ModernTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                'Confidence: ',
                style: TextStyle(
                  fontSize: 14,
                  color: ModernTheme.textSecondary,
                ),
              ),
              Text(
                '${commit.confidence}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: (index * 100).ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildDiffIndicator(diff) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ModernTheme.iosBlue.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(
          diff.confidenceDelta > 0
              ? Icons.trending_up
              : diff.confidenceDelta < 0
                  ? Icons.trending_down
                  : Icons.trending_flat,
          size: 40,
          color: diff.confidenceDelta > 0
              ? ModernTheme.accentGreen
              : diff.confidenceDelta < 0
                  ? ModernTheme.accentRed
                  : ModernTheme.textTertiary,
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 200.ms)
        .scale(begin: const Offset(0.5, 0.5), curve: Curves.easeOutBack);
  }

  Widget _buildModernAnalysis(diff) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Analysis',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: ModernTheme.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 20),
        _buildMetricCard(
          'Confidence Change',
          '${diff.confidenceDelta > 0 ? '+' : ''}${diff.confidenceDelta}%',
          diff.confidenceDelta > 0
              ? 'Your certainty increased'
              : diff.confidenceDelta < 0
                  ? 'Your certainty decreased'
                  : 'Certainty remained stable',
          diff.confidenceDelta > 0
              ? ModernTheme.accentGreen
              : diff.confidenceDelta < 0
                  ? ModernTheme.accentRed
                  : ModernTheme.textTertiary,
          Icons.insights,
          0,
        ),
        const SizedBox(height: 16),
        _buildMetricCard(
          'New Constraints',
          '${diff.constraintsAdded.length}',
          diff.constraintsAdded.isEmpty
              ? 'No new limitations added'
              : 'Additional factors considered',
          ModernTheme.iosBlue,
          Icons.add_circle_outline,
          1,
        ),
        const SizedBox(height: 16),
        _buildMetricCard(
          'Removed Constraints',
          '${diff.constraintsRemoved.length}',
          diff.constraintsRemoved.isEmpty
              ? 'No limitations removed'
              : 'Factors no longer relevant',
          ModernTheme.iosPurple,
          Icons.remove_circle_outline,
          2,
        ),
        const SizedBox(height: 16),
        _buildMetricCard(
          'Time Elapsed',
          _formatDuration(diff.timeDelta),
          'Time between decisions',
          ModernTheme.iosIndigo,
          Icons.schedule,
          3,
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    String description,
    Color color,
    IconData icon,
    int index,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ModernTheme.backgroundSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: ModernTheme.textTertiary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: color,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: ModernTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: (400 + index * 80).ms)
        .slideX(begin: -0.1, end: 0);
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    }
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    }
    if (duration.inMinutes > 0) return '${duration.inMinutes}m';
    return '${duration.inSeconds}s';
  }
}
