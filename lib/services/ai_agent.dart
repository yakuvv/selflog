import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/commit.dart';

class AIAgentService {
  static const String _apiUrl = 'https://api.anthropic.com/v1/messages';

  // API key - set this manually if you have one, otherwise uses local analysis
  static const String _apiKey = ''; // Leave empty for local mode

  // Generate advanced analysis using Claude
  Future<String> generateAdvancedAnalysis(Commit older, Commit newer) async {
    if (_apiKey.isEmpty) {
      return _generateLocalAnalysis(older, newer);
    }

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': 'claude-sonnet-4-20250514',
          'max_tokens': 1024,
          'messages': [
            {
              'role': 'user',
              'content': _buildAnalysisPrompt(older, newer),
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['content'][0]['text'];
      } else {
        return _generateLocalAnalysis(older, newer);
      }
    } catch (e) {
      print('AI Agent error: $e');
      return _generateLocalAnalysis(older, newer);
    }
  }

  String _buildAnalysisPrompt(Commit older, Commit newer) {
    return '''
Analyze these two decision commits using pure CS/data-oriented reasoning. No advice or emotions.

OLDER COMMIT (${older.id.substring(0, 8)}):
Title: ${older.title}
Timestamp: ${older.timestamp}
Context: ${older.context}
Constraints: ${older.constraints.join(', ')}
Confidence: ${older.confidence}%
Notes: ${older.notes}

NEWER COMMIT (${newer.id.substring(0, 8)}):
Title: ${newer.title}
Timestamp: ${newer.timestamp}
Context: ${newer.context}
Constraints: ${newer.constraints.join(', ')}
Confidence: ${newer.confidence}%
Notes: ${newer.notes}

Provide analytical output covering:
1. Confidence delta and trend
2. Constraint evolution (added/removed)
3. Context transformation pattern
4. Reasoning stability metrics
5. Decision vector analysis

Output format: Technical, data-driven, no subjective guidance.
''';
  }

  String _generateLocalAnalysis(Commit older, Commit newer) {
    final buffer = StringBuffer();
    buffer.writeln('=== LOCAL ANALYSIS MODE ===\n');
    buffer.writeln('(AI Agent unavailable - using local analysis)\n');

    final confidenceDelta = newer.confidence - older.confidence;
    buffer.writeln(
        'CONFIDENCE DELTA: ${confidenceDelta > 0 ? '+' : ''}$confidenceDelta%');

    final oldConstraints = Set<String>.from(older.constraints);
    final newConstraints = Set<String>.from(newer.constraints);
    final added = newConstraints.difference(oldConstraints);
    final removed = oldConstraints.difference(newConstraints);

    buffer.writeln('CONSTRAINTS ADDED: ${added.length}');
    for (var constraint in added) {
      buffer.writeln('  + $constraint');
    }
    buffer.writeln('\nCONSTRAINTS REMOVED: ${removed.length}');
    for (var constraint in removed) {
      buffer.writeln('  - $constraint');
    }
    buffer.writeln(
        '\nTIME DELTA: ${newer.timestamp.difference(older.timestamp).inHours}h');
    buffer.writeln(
        '\nCONTEXT EVOLUTION: ${_analyzeContext(older.context, newer.context)}');

    return buffer.toString();
  }

  String _analyzeContext(String oldContext, String newContext) {
    if (oldContext == newContext) return 'UNCHANGED';
    if (newContext.length > oldContext.length * 1.5) return 'EXPANDED';
    if (newContext.length < oldContext.length * 0.5) return 'REDUCED';
    return 'MODIFIED';
  }

  // Generate reasoning pattern insights
  Future<String> generatePatternInsights(List<Commit> commits) async {
    if (commits.length < 3) {
      return 'INSUFFICIENT_DATA: Need 3+ commits for pattern analysis';
    }

    final confidences = commits.map((c) => c.confidence).toList();
    final avgConfidence =
        confidences.reduce((a, b) => a + b) / confidences.length;
    final trend = (confidences.last - confidences.first) / (commits.length - 1);

    final buffer = StringBuffer();
    buffer.writeln('=== PATTERN ANALYSIS ===\n');
    buffer.writeln('COMMITS ANALYZED: ${commits.length}');
    buffer.writeln('AVG CONFIDENCE: ${avgConfidence.toStringAsFixed(1)}%');
    buffer.writeln(
        'CONFIDENCE TREND: ${trend > 0 ? 'INCREASING' : trend < 0 ? 'DECREASING' : 'STABLE'}');
    buffer.writeln('TREND RATE: ${trend.toStringAsFixed(2)}% per commit');

    return buffer.toString();
  }
}
