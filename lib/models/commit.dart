import 'package:uuid/uuid.dart';

class Commit {
  final String id;
  final DateTime timestamp;
  final String title;
  final String context;
  final List<String> constraints;
  final int confidence; // 0-100
  final String notes;

  Commit({
    String? id,
    DateTime? timestamp,
    required this.title,
    required this.context,
    required this.constraints,
    required this.confidence,
    required this.notes,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  // Convert to JSON for storage
  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'title': title,
        'context': context,
        'constraints': constraints,
        'confidence': confidence,
        'notes': notes,
      };

  // Create from JSON
  factory Commit.fromJson(Map<String, dynamic> json) => Commit(
        id: json['id'],
        timestamp: DateTime.parse(json['timestamp']),
        title: json['title'],
        context: json['context'],
        constraints: List<String>.from(json['constraints']),
        confidence: json['confidence'],
        notes: json['notes'],
      );

  // Create copy with modifications (immutability)
  Commit copyWith({
    String? id,
    DateTime? timestamp,
    String? title,
    String? context,
    List<String>? constraints,
    int? confidence,
    String? notes,
  }) =>
      Commit(
        id: id ?? this.id,
        timestamp: timestamp ?? this.timestamp,
        title: title ?? this.title,
        context: context ?? this.context,
        constraints: constraints ?? this.constraints,
        confidence: confidence ?? this.confidence,
        notes: notes ?? this.notes,
      );
}
