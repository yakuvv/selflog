import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../models/commit.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';
import 'new_commit_screen.dart';
import 'compare_screen.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  final StorageService _storage = StorageService();
  List<Commit> _commits = [];
  bool _loading = true;
  final Set<String> _selectedCommits = {};

  @override
  void initState() {
    super.initState();
    _loadCommits();
  }

  Future<void> _loadCommits() async {
    setState(() => _loading = true);
    final commits = await _storage.loadCommits();
    setState(() {
      _commits = commits..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      _loading = false;
    });
  }

  void _toggleSelection(String commitId) {
    setState(() {
      if (_selectedCommits.contains(commitId)) {
        _selectedCommits.remove(commitId);
      } else {
        if (_selectedCommits.length < 2) {
          _selectedCommits.add(commitId);
        } else {
          // Replace oldest selection
          _selectedCommits.remove(_selectedCommits.first);
          _selectedCommits.add(commitId);
        }
      }
    });
  }

  void _compareSelected() {
    if (_selectedCommits.length != 2) return;

    final commits = _selectedCommits
        .map((id) => _commits.firstWhere((c) => c.id == id))
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CompareScreen(
          olderCommit: commits[0],
          newerCommit: commits[1],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TIMELINE'),
        actions: [
          if (_selectedCommits.length == 2)
            IconButton(
              icon: const Icon(Icons.compare_arrows),
              onPressed: _compareSelected,
              tooltip: 'Compare selected commits',
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _commits.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _commits.length,
                  itemBuilder: (context, index) {
                    return _buildCommitCard(_commits[index], index)
                        .animate()
                        .fadeIn(
                          duration: 400.ms,
                          delay: (index * 50).ms,
                        )
                        .slideX(begin: -0.1, end: 0);
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NewCommitScreen(),
            ),
          );
          _loadCommits();
        },
        icon: const Icon(Icons.add),
        label: const Text('NEW COMMIT'),
        backgroundColor: AppTheme.primary,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timeline,
            size: 80,
            color: AppTheme.textSecondary.withOpacity(0.3),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .fadeIn(duration: 1000.ms)
              .then()
              .shimmer(duration: 2000.ms),
          const SizedBox(height: 24),
          Text(
            'No commits yet',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first decision commit',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildCommitCard(Commit commit, int index) {
    final isSelected = _selectedCommits.contains(commit.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppTheme.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () => _toggleSelection(commit.id),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      commit.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  _buildConfidenceBadge(commit.confidence),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                commit.context,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: commit.constraints
                    .take(3)
                    .map((c) => _buildConstraintChip(c))
                    .toList(),
              ),
              if (commit.constraints.length > 3) ...[
                const SizedBox(height: 8),
                Text(
                  '+${commit.constraints.length - 3} more constraints',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM d, y • HH:mm').format(commit.timestamp),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                        ),
                  ),
                  const Spacer(),
                  Text(
                    commit.id.substring(0, 8),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfidenceBadge(int confidence) {
    Color color;
    if (confidence >= 80) {
      color = AppTheme.success;
    } else if (confidence >= 50) {
      color = AppTheme.warning;
    } else {
      color = AppTheme.error;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        '$confidence%',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildConstraintChip(String constraint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight.withOpacity(0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        constraint,
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 12,
        ),
      ),
    );
  }
}
