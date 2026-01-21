import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import '../models/commit.dart';
import '../services/analysis_service.dart';
import '../services/ai_agent_service.dart';
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
  bool _showAI = false;

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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Commit Diff'),
        actions: [
          IconButton(
            icon: Icon(
              _showAI ? Icons.analytics : Icons.psychology_outlined,
              color: ModernTheme.iosPurple,
            ),
            onPressed: () => setState(() => _showAI = !_showAI),
          ),
        ],
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
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 20),

              _buildCommitCard('OLDER', widget.olderCommit, ModernTheme.accentRed, 0),

              const SizedBox(height: 16),

              _buildDiffIndicator(diff),

              const SizedBox(height: 16),

              _buildCommitCard('NEWER', widget.newerCommit, ModernTheme.accentGreen, 1),

              const SizedBox(height: 30),

              if (_showAI)
                _buildAIAnalysisCard()
              else
                _buildLocalAnalysisCard(diff),

              const SizedBox(height: 30),

              _buildDiffDetails(diff),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommitCard(String label, Commit commit, Color color, int index) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.3), width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    commit.id.substring(0, 8),
                    style: const TextStyle(
                      fontFamily: 'monospace',
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
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: ModernTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat('MMM d, y • HH:mm').format(commit.timestamp),
                style: const TextStyle(
                  fontSize: 14,
                  color: ModernTheme.textTertiary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text(
                    'Confidence: ',
                    style: TextStyle(color: ModernTheme.textSecondary),
                  ),
                  Text(
                    '${commit.confidence}%',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: (index * 150).ms)
        .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuart);
  }

  Widget _buildDiffIndicator(CommitDiff diff) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              ModernTheme.iosBlue.withOpacity(0.2),
              ModernTheme.iosPurple.withOpacity(0.2),
            ],
          ),
          shape: BoxShape.circle,
        ),
        child: Icon(
          diff.confidenceDelta > 0
              ? Icons.trending_up
              : diff.confidenceDelta < 0
                  ? Icons.trending_down
                  : Icons.trending_flat,
          size: 32,
          color: diff.confidenceDelta > 0
              ? ModernTheme.accentGreen
              : diff.confidenceDelta < 0
                  ? ModernTheme.accentRed
                  : ModernTheme.textTertiary,
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: 300.ms)
        .scale(begin: const Offset(0.5, 0.5), curve: Curves.easeOutBack);
  }

  Widget _buildAIAnalysisCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.psychology_outlined,
              color: ModernTheme.iosPurple,
              size: 24,
            ),
            const SizedBox(width: 12),
            const Text(
              'AI Agent Analysis',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: ModernTheme.textPrimary,
              ),
            ),
          ],
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
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ModernTheme.iosPurple.withOpacity(0.15),
                    ModernTheme.iosBlue.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: ModernTheme.iosPurple.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: _loadingAI
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(
                          color: ModernTheme.iosPurple,
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  : SelectableText(
                      _aiAnalysis,
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
        .fadeIn(duration: 600.ms, delay: 600.ms)
        .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuart);
  }

  Widget _buildLocalAnalysisCard(CommitDiff diff) {
    final localAnalysis = _analysisService.generateAnalysis(diff);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.analytics_outlined,
              color: ModernTheme.iosBlue,
              size: 24,
            ),
            const SizedBox(width: 12),
            const Text(
              'Local Analysis',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: ModernTheme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: ModernTheme.glassBox(opacity: 0.05),
              child: SelectableText(
                localAnalysis,
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
        .fadeIn(duration: 600.ms, delay: 600.ms)
        .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuart);
  }

  Widget _buildDiffDetails(CommitDiff diff) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detailed Diff',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: ModernTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),

        _buildDiffMetric(
          'Confidence Delta',
          '${diff.confidenceDelta > 0 ? '+' : ''}${diff.confidenceDelta}%',
          diff.confidenceDelta > 0
              ? ModernTheme.accentGreen
              : diff.confidenceDelta < 0
                  ? ModernTheme.accentRed
                  : ModernTheme.textTertiary,
          Icons.trending_up,
          0,
        ),

        const SizedBox(height: 12),

        _buildDiffMetric(
          'Time Elapsed',
          _formatDuration(diff.timeDelta),
          ModernTheme.iosBlue,
          Icons.access_time,
          1,
        ),

        const SizedBox(height: 12),

        _buildDiffMetric(
          'Constraints Added',
          '${diff.constraintsAdded.length}',
          ModernTheme.accentGreen,
          Icons.add_circle_outline,
          2,
        ),

        const SizedBox(height: 12),

        _buildDiffMetric(
          'Constraints Removed',
          '${diff.constraintsRemoved.length}',
          ModernTheme.accentRed,
          Icons.remove_circle_outline,
          3,
        ),

        const SizedBox(height: 12),

        _buildDiffMetric(
          'Context Status',
          diff.contextEvolution,
          ModernTheme.iosPurple,
          Icons.description,
          4,
        ),
      ],
    );
  }

  Widget _buildDiffMetric(
    String label,
    String value,
    Color color,
    IconData icon,
    int index,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: ModernTheme.glassBox(opacity: 0.05),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    color: ModernTheme.textSecondary,
                  ),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: (800 + index * 80).ms)
        .slideX(begin: -0.2, end: 0, curve: Curves.easeOutQuart);
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
