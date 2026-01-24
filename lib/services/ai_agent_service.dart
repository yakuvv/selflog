// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../models/commit.dart';

// class AIAgentService {
//   static const String _apiUrl = 'https://api.anthropic.com/v1/messages';
//   static const String _apiKey = ''; // Leave empty for local mode

//   Future<String> generateAdvancedAnalysis(Commit older, Commit newer) async {
//     if (_apiKey.isEmpty) {
//       return _generateLocalAnalysis(older, newer);
//     }

//     try {
//       final response = await http.post(
//         Uri.parse(_apiUrl),
//         headers: {
//           'Content-Type': 'application/json',
//           'x-api-key': _apiKey,
//           'anthropic-version': '2023-06-01',
//         },
//         body: jsonEncode({
//           'model': 'claude-sonnet-4-20250514',
//           'max_tokens': 1024,
//           'messages': [
//             {
//               'role': 'user',
//               'content': _buildAnalysisPrompt(older, newer),
//             }
//           ],
//         }),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         return data['content'][0]['text'];
//       } else {
//         return _generateLocalAnalysis(older, newer);
//       }
//     } catch (e) {
//       print('AI Agent error: $e');
//       return _generateLocalAnalysis(older, newer);
//     }
//   }

//   String _buildAnalysisPrompt(Commit older, Commit newer) {
//     return '''
// Analyze these two decision commits using pure CS/data-oriented reasoning.

// OLDER COMMIT (${older.id.substring(0, 8)}):
// Title: ${older.title}
// Context: ${older.context}
// Constraints: ${older.constraints.join(', ')}
// Confidence: ${older.confidence}%

// NEWER COMMIT (${newer.id.substring(0, 8)}):
// Title: ${newer.title}
// Context: ${newer.context}
// Constraints: ${newer.constraints.join(', ')}
// Confidence: ${newer.confidence}%

// Provide technical analysis of confidence delta, constraint evolution, and reasoning patterns.
// ''';
//   }

//   String _generateLocalAnalysis(Commit older, Commit newer) {
//     final buffer = StringBuffer();
//     buffer.writeln('=== LOCAL ANALYSIS MODE ===\n');

//     final confidenceDelta = newer.confidence - older.confidence;
//     buffer.writeln('CONFIDENCE DELTA: ${confidenceDelta > 0 ? '+' : ''}$confidenceDelta%');

//     final oldConstraints = Set<String>.from(older.constraints);
//     final newConstraints = Set<String>.from(newer.constraints);
//     final added = newConstraints.difference(oldConstraints);
//     final removed = oldConstraints.difference(newConstraints);

//     buffer.writeln('CONSTRAINTS ADDED: ${added.length}');
//     for (var constraint in added) {
//       buffer.writeln('  + $constraint');
//     }

//     buffer.writeln('\nCONSTRAINTS REMOVED: ${removed.length}');
//     for (var constraint in removed) {
//       buffer.writeln('  - $constraint');
//     }

//     buffer.writeln('\nTIME DELTA: ${newer.timestamp.difference(older.timestamp).inHours}h');

//     return buffer.toString();
//   }

//   Future<String> generatePatternInsights(List<Commit> commits) async {
//     if (commits.length < 3) {
//       return 'INSUFFICIENT_DATA: Need 3+ commits for pattern analysis';
//     }

//     final confidences = commits.map((c) => c.confidence).toList();
//     final avgConfidence = confidences.reduce((a, b) => a + b) / confidences.length;
//     final trend = (confidences.last - confidences.first) / (commits.length - 1);

//     final buffer = StringBuffer();
//     buffer.writeln('=== PATTERN ANALYSIS ===\n');
//     buffer.writeln('COMMITS ANALYZED: ${commits.length}');
//     buffer.writeln('AVG CONFIDENCE: ${avgConfidence.toStringAsFixed(1)}%');
//     buffer.writeln('TREND: ${trend > 0 ? 'INCREASING' : trend < 0 ? 'DECREASING' : 'STABLE'}');

//     return buffer.toString();
//   }
// }
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/commit.dart';

class AIAgentService {
  static const String _apiUrl = 'https://api.anthropic.com/v1/messages';
  static const String _apiKey = ''; // Leave empty for local mode

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
Analyze these two decision commits using pure CS/data-oriented reasoning.

OLDER COMMIT (${older.id.substring(0, 8)}):
Title: ${older.title}
Context: ${older.context}
Constraints: ${older.constraints.join(', ')}
Confidence: ${older.confidence}%

NEWER COMMIT (${newer.id.substring(0, 8)}):
Title: ${newer.title}
Context: ${newer.context}
Constraints: ${newer.constraints.join(', ')}
Confidence: ${newer.confidence}%

Provide technical analysis of confidence delta, constraint evolution, and reasoning patterns.
''';
  }

  String _generateLocalAnalysis(Commit older, Commit newer) {
    final buffer = StringBuffer();
    buffer.writeln('DECISION COMPARISON\n');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    final confidenceDelta = newer.confidence - older.confidence;

    if (confidenceDelta > 0) {
      buffer.writeln('CONFIDENCE INCREASED: +$confidenceDelta%');
      buffer.writeln('Your certainty has grown over time.');
    } else if (confidenceDelta < 0) {
      buffer.writeln('CONFIDENCE DECREASED: ${confidenceDelta.abs()}%');
      buffer.writeln('You became more cautious.');
    } else {
      buffer.writeln('CONFIDENCE STABLE: No change');
      buffer.writeln('Your certainty level stayed the same.');
    }

    final oldConstraints = Set<String>.from(older.constraints);
    final newConstraints = Set<String>.from(newer.constraints);
    final added = newConstraints.difference(oldConstraints);
    final removed = oldConstraints.difference(newConstraints);

    buffer.writeln('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    if (added.isNotEmpty) {
      buffer.writeln('NEW FACTORS (${added.length}):');
      for (var constraint in added) {
        buffer.writeln('  + $constraint');
      }
    }

    if (removed.isNotEmpty) {
      buffer.writeln('\nNO LONGER CONSIDERING (${removed.length}):');
      for (var constraint in removed) {
        buffer.writeln('  - $constraint');
      }
    }

    final hours = newer.timestamp.difference(older.timestamp).inHours;
    final days = (hours / 24).floor();

    buffer.writeln('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    buffer.writeln('TIME ELAPSED:');
    if (days > 0) {
      buffer.writeln('$days days between decisions');
    } else if (hours > 0) {
      buffer.writeln('$hours hours between decisions');
    } else {
      buffer.writeln('Less than an hour between decisions');
    }

    return buffer.toString();
  }

  Future<String> generatePatternInsights(List<Commit> commits) async {
    if (commits.length < 3) {
      return 'Need at least 3 decisions to detect meaningful patterns.\n\nKeep committing decisions to unlock insights!';
    }

    final confidences = commits.map((c) => c.confidence).toList();
    final avgConfidence =
        confidences.reduce((a, b) => a + b) / confidences.length;
    final trend = (confidences.last - confidences.first) / (commits.length - 1);

    final buffer = StringBuffer();
    buffer.writeln('PATTERN INSIGHTS\n');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    buffer.writeln('Total Decisions: ${commits.length}');
    buffer.writeln('Average Confidence: ${avgConfidence.toStringAsFixed(1)}%');

    buffer.writeln('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    if (trend > 5) {
      buffer.writeln('TREND: Growing Confidence');
      buffer.writeln('\nYour decision-making confidence');
      buffer.writeln('is improving over time.');
    } else if (trend < -5) {
      buffer.writeln('TREND: Declining Confidence');
      buffer.writeln('\nYou are becoming more cautious');
      buffer.writeln('in your decisions.');
    } else {
      buffer.writeln('TREND: Stable Confidence');
      buffer.writeln('\nYour confidence levels remain');
      buffer.writeln('consistent over time.');
    }

    return buffer.toString();
  }
}
