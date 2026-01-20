import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/commit.dart';

class StorageService {
  static const String _commitsKey = 'commits';

  // Save all commits
  Future<void> saveCommits(List<Commit> commits) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = commits.map((c) => c.toJson()).toList();
    await prefs.setString(_commitsKey, jsonEncode(jsonList));
  }

  // Load all commits
  Future<List<Commit>> loadCommits() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_commitsKey);

    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => Commit.fromJson(json)).toList();
  }

  // Add single commit
  Future<void> addCommit(Commit commit) async {
    final commits = await loadCommits();
    commits.add(commit);
    await saveCommits(commits);
  }

  // Clear all commits (for testing)
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_commitsKey);
  }
}
