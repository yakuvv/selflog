import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/commit.dart';

class StorageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  // Get user's commits collection reference
  CollectionReference get _commitsRef {
    if (_userId == null) throw Exception('User not logged in');
    return _firestore.collection('users').doc(_userId).collection('commits');
  }

  // Load all commits
  Future<List<Commit>> loadCommits() async {
    try {
      final snapshot =
          await _commitsRef.orderBy('timestamp', descending: true).get();
      return snapshot.docs
          .map((doc) => Commit.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading commits: $e');
      return [];
    }
  }

  // Add single commit
  Future<void> addCommit(Commit commit) async {
    try {
      await _commitsRef.doc(commit.id).set(commit.toJson());
    } catch (e) {
      print('Error adding commit: $e');
      rethrow;
    }
  }

  // Clear all commits (for testing)
  Future<void> clearAll() async {
    try {
      final snapshot = await _commitsRef.get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('Error clearing commits: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
