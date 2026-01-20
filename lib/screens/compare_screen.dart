import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../models/commit.dart';
import '../services/analysis_service.dart';
import '../utils/app_theme.dart';

class CompareScreen extends StatelessWidget {
  final Commit olderCommit;
  final Commit newerCommit;

  const CompareScreen({
    super.key,
    required this.olderCommit,
    required this.newerCommit,
  });

  @override
  Widget build(BuildContext context) {
    final analysis = AnalysisService();
    final diff = analysis.generateDiff(olderCommit, newerCommit);
    final analyticalOutput = analysis.generateAnalysis(diff);

    return Scaffold(
      appBar: AppBar(
        title: const Text('COMMIT DIFF'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Header
          Text(
            'Comparing Commits',
            style: Theme.of(context).textTheme.headlineMedium,
          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),

          const SizedBox(height: 24),

          // Commit info cards
          _buildCommitCard(context, 'OLDER', olderCommit, 0),
          const SizedBox(height: 16),
          _buildCommitCard(context, 'NEWER', newerCommit, 1),

          const SizedBox(height: 32),

          // Analysis output
          Text(
            'Agent Analysis',
            style: Theme.of(context).textTheme.headlineMedium,
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 400.ms)
              .slideX(begin: -0.1, end: 0),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.surfaceLight.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: SelectableText(
              analyticalOutput,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                color: AppTheme.textPrimary,
                height: 1.6,
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms, delay: 600.ms)
              .slideY(begin: 0.1, end: 0),

          const SizedBox(height: 32),

          // Visual diff indicators
          _buildDiffSection(context, diff),
        ],
      ),
    );
  }

  Widget _buildCommitCard(
    BuildContext context,
    String label,
    Commit commit,
    int index,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: label == 'OLDER'
              ? AppTheme.error.withOpacity(0.3)
              : AppTheme.success.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: label == 'OLDER' ? AppTheme.error : AppTheme.success,
                ),
              ),
              const Spacer(),
              Text(
                commit.id.substring(0, 8),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            commit.title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            DateFormat('MMM d, y • HH:mm').format(commit.timestamp),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 12,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Confidence: '),
              Text(
                '${commit.confidence}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _getConfidenceColor(commit.confidence),
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: (200 + index * 100).ms)
        .slideX(begin: -0.1, end: 0);
  }

  Widget _buildDiffSection(BuildContext context, CommitDiff diff) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Visual Diff',
          style: Theme.of(context).textTheme.headlineMedium,
        )
            .animate()
            .fadeIn(duration: 400.ms, delay: 800.ms)
            .slideX(begin: -0.1, end: 0),

        const SizedBox(height: 16),

        // Confidence delta
        _buildDiffItem(
          context,
          'Confidence Delta',
          '${diff.confidenceDelta > 0 ? '+' : ''}${diff.confidenceDelta}%',
          diff.confidenceDelta > 0
              ? AppTheme.success
              : diff.confidenceDelta < 0
                  ? AppTheme.error
                  : AppTheme.textSecondary,
          Icons.trending_up,
          0,
        ),
        const SizedBox(height: 12),

        // Time elapsed
        _buildDiffItem(
          context,
          'Time Elapsed',
          _formatDuration(diff.timeDelta),
          AppTheme.primary,
          Icons.access_time,
          1,
        ),

        const SizedBox(height: 12),

        // Constraints added
        _buildDiffItem(
          context,
          'Constraints Added',
          '${diff.constraintsAdded.length}',
          AppTheme.success,
          Icons.add_circle_outline,
          2,
        ),

        const SizedBox(height: 12),

        // Constraints removed
        _buildDiffItem(
          context,
          'Constraints Removed',
          '${diff.constraintsRemoved.length}',
          AppTheme.error,
          Icons.remove_circle_outline,
          3,
        ),

        const SizedBox(height: 12),

        // Context evolution
        _buildDiffItem(
          context,
          'Context Evolution',
          diff.contextEvolution,
          AppTheme.accent,
          Icons.description,
          4,
        ),
      ],
    );
  }

  Widget _buildDiffItem(
    BuildContext context,
    String label,
    String value,
    Color color,
    IconData icon,
    int index,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge,
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
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: (1000 + index * 100).ms)
        .slideX(begin: -0.1, end: 0);
  }

  Color _getConfidenceColor(int confidence) {
    if (confidence >= 80) return AppTheme.success;
    if (confidence >= 50) return AppTheme.warning;
    return AppTheme.error;
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

