import '../models/commit.dart';

class CommitDiff {
  final int confidenceDelta;
  final List<String> constraintsAdded;
  final List<String> constraintsRemoved;
  final Duration timeDelta;
  final String contextEvolution;

  CommitDiff({
    required this.confidenceDelta,
    required this.constraintsAdded,
    required this.constraintsRemoved,
    required this.timeDelta,
    required this.contextEvolution,
  });
}

class AnalysisService {
  // Generate diff between two commits
  CommitDiff generateDiff(Commit older, Commit newer) {
    final confidenceDelta = newer.confidence - older.confidence;

    final oldConstraints = Set<String>.from(older.constraints);
    final newConstraints = Set<String>.from(newer.constraints);

    final constraintsAdded = newConstraints.difference(oldConstraints).toList();
    final constraintsRemoved =
        oldConstraints.difference(newConstraints).toList();

    final timeDelta = newer.timestamp.difference(older.timestamp);

    final contextEvolution =
        _analyzeContextChange(older.context, newer.context);

    return CommitDiff(
      confidenceDelta: confidenceDelta,
      constraintsAdded: constraintsAdded,
      constraintsRemoved: constraintsRemoved,
      timeDelta: timeDelta,
      contextEvolution: contextEvolution,
    );
  }

  String _analyzeContextChange(String oldContext, String newContext) {
    if (oldContext == newContext) return 'Unchanged';
    if (newContext.length > oldContext.length * 1.5) return 'Expanded';
    if (newContext.length < oldContext.length * 0.5) return 'Simplified';
    return 'Evolved';
  }

  // Generate analytical summary with better formatting
  String generateAnalysis(CommitDiff diff) {
    final buffer = StringBuffer();

    buffer.writeln('DECISION COMPARISON\n');

    // Confidence evolution
    if (diff.confidenceDelta > 0) {
      buffer.writeln('CONFIDENCE INCREASED: +${diff.confidenceDelta}%');
      buffer.writeln('Your certainty has grown over time.\n');
    } else if (diff.confidenceDelta < 0) {
      buffer.writeln('CONFIDENCE DECREASED: ${diff.confidenceDelta}%');
      buffer.writeln('You became more cautious about this decision.\n');
    } else {
      buffer.writeln('CONFIDENCE STABLE: No change in certainty level.\n');
    }

    // Constraint evolution
    if (diff.constraintsAdded.isNotEmpty) {
      buffer.writeln('NEW FACTORS (${diff.constraintsAdded.length}):');
      for (var constraint in diff.constraintsAdded) {
        buffer.writeln('  + $constraint');
      }
      buffer.writeln();
    }

    if (diff.constraintsRemoved.isNotEmpty) {
      buffer.writeln(
          'NO LONGER CONSIDERING (${diff.constraintsRemoved.length}):');
      for (var constraint in diff.constraintsRemoved) {
        buffer.writeln('  - $constraint');
      }
      buffer.writeln();
    }

    // Time delta
    buffer
        .writeln('TIME BETWEEN DECISIONS: ${_formatDuration(diff.timeDelta)}');
    buffer.writeln();

    // Context evolution
    buffer.writeln('REASONING STATUS: ${diff.contextEvolution}');

    return buffer.toString();
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0)
      return '${duration.inDays}d ${duration.inHours % 24}h';
    if (duration.inHours > 0)
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    if (duration.inMinutes > 0) return '${duration.inMinutes}m';
    return '${duration.inSeconds}s';
  }

  // Reasoning evolution pattern detection
  String detectPattern(List<Commit> commits) {
    if (commits.length < 2) return 'Not enough data to detect patterns';

    // Calculate confidence trend
    final confidences = commits.map((c) => c.confidence).toList();
    final avgChange =
        (confidences.last - confidences.first) / (commits.length - 1);

    if (avgChange > 5) return 'Your confidence is growing over time';
    if (avgChange < -5) return 'Your confidence is declining';
    return 'Your confidence fluctuates regularly';
  }
}
