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
    if (oldContext == newContext) return 'CONTEXT_UNCHANGED';
    if (newContext.length > oldContext.length * 1.5) return 'CONTEXT_EXPANDED';
    if (newContext.length < oldContext.length * 0.5) return 'CONTEXT_REDUCED';
    return 'CONTEXT_MODIFIED';
  }

  // Generate analytical summary
  String generateAnalysis(CommitDiff diff) {
    final buffer = StringBuffer();

    buffer.writeln('=== COMMIT DIFF ANALYSIS ===\n');

    // Confidence evolution
    buffer.writeln(
        'CONFIDENCE DELTA: ${diff.confidenceDelta > 0 ? '+' : ''}${diff.confidenceDelta}');
    if (diff.confidenceDelta > 0) {
      buffer.writeln('STATUS: Certainty increased');
    } else if (diff.confidenceDelta < 0) {
      buffer.writeln('STATUS: Certainty decreased');
    } else {
      buffer.writeln('STATUS: Certainty stable');
    }
    buffer.writeln();

    // Constraint evolution
    buffer.writeln('CONSTRAINTS ADDED: ${diff.constraintsAdded.length}');
    for (var constraint in diff.constraintsAdded) {
      buffer.writeln('  + $constraint');
    }
    buffer.writeln();

    buffer.writeln('CONSTRAINTS REMOVED: ${diff.constraintsRemoved.length}');
    for (var constraint in diff.constraintsRemoved) {
      buffer.writeln('  - $constraint');
    }
    buffer.writeln();

    // Time delta
    buffer.writeln('TIME ELAPSED: ${_formatDuration(diff.timeDelta)}');
    buffer.writeln();

    // Context evolution
    buffer.writeln('CONTEXT STATUS: ${diff.contextEvolution}');

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
    if (commits.length < 2) return 'INSUFFICIENT_DATA';

    // Calculate confidence trend
    final confidences = commits.map((c) => c.confidence).toList();
    final avgChange =
        (confidences.last - confidences.first) / (commits.length - 1);

    if (avgChange > 5) return 'CONFIDENCE_INCREASING';
    if (avgChange < -5) return 'CONFIDENCE_DECREASING';
    return 'CONFIDENCE_OSCILLATING';
  }
}
