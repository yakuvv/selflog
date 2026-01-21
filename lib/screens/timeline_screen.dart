import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import '../models/commit.dart';
import '../services/storage_service.dart';
import '../utils/modern_theme.dart';
import 'new_commit_screen.dart';
import 'compare_screen.dart';
import 'data_timeline_screen.dart';

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
  int _selectedTab = 0;

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
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => CompareScreen(
          olderCommit: commits[0],
          newerCommit: commits[1],
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('SELFLOG'),
        actions: [
          if (_selectedCommits.length == 2)
            IconButton(
              icon: const Icon(Icons.compare_arrows),
              onPressed: _compareSelected,
              color: ModernTheme.iosBlue,
            ),
          IconButton(
            icon: const Icon(Icons.insights_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DataTimelineScreen(commits: _commits),
                ),
              );
            },
            color: ModernTheme.iosBlue,
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
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildStatsBar(),
              const SizedBox(height: 20),
              Expanded(
                child: _loading
                    ? _buildLoadingState()
                    : _commits.isEmpty
                        ? _buildEmptyState()
                        : _buildCommitList(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildStatsBar() {
    if (_commits.isEmpty) return const SizedBox.shrink();

    final avgConfidence = _commits.isEmpty
        ? 0
        : _commits.map((c) => c.confidence).reduce((a, b) => a + b) /
            _commits.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
              child: _buildStatCard(
                  'Commits', '${_commits.length}', Icons.commit, 0)),
          const SizedBox(width: 12),
          Expanded(
              child: _buildStatCard('Avg Confidence',
                  '${avgConfidence.toInt()}%', Icons.trending_up, 1)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, int index) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: ModernTheme.glassBox(opacity: 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: ModernTheme.iosBlue, size: 20),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: ModernTheme.textPrimary,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: ModernTheme.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: (index * 100).ms)
        .slideX(begin: -0.2, end: 0, curve: Curves.easeOutQuart);
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              color: ModernTheme.iosBlue,
              strokeWidth: 3,
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .fadeIn(duration: 600.ms)
              .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeInOut),
          const SizedBox(height: 20),
          const Text(
            'Loading timeline...',
            style: TextStyle(color: ModernTheme.textTertiary),
          ).animate().fadeIn(duration: 600.ms, delay: 300.ms),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  ModernTheme.iosBlue.withOpacity(0.2),
                  ModernTheme.iosPurple.withOpacity(0.2),
                ],
              ),
            ),
            child: const Icon(
              Icons.timeline,
              size: 60,
              color: ModernTheme.iosBlue,
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .fadeIn(duration: 1000.ms)
              .scale(
                begin: const Offset(0.9, 0.9),
                end: const Offset(1.1, 1.1),
                duration: 2000.ms,
              )
              .then()
              .scale(
                begin: const Offset(1.1, 1.1),
                end: const Offset(0.9, 0.9),
                duration: 2000.ms,
              ),
          const SizedBox(height: 32),
          Text(
            'No commits yet',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: ModernTheme.textSecondary,
                ),
          ).animate().fadeIn(duration: 800.ms, delay: 400.ms),
          const SizedBox(height: 12),
          Text(
            'Start tracking your decisions',
            style: Theme.of(context).textTheme.bodyMedium,
          ).animate().fadeIn(duration: 800.ms, delay: 600.ms),
        ],
      ),
    );
  }

  Widget _buildCommitList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _commits.length,
      itemBuilder: (context, index) {
        return _buildCommitCard(_commits[index], index);
      },
    );
  }

  Widget _buildCommitCard(Commit commit, int index) {
    final isSelected = _selectedCommits.contains(commit.id);

    return GestureDetector(
      onTap: () => _toggleSelection(commit.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isSelected
                      ? [
                          ModernTheme.iosBlue.withOpacity(0.15),
                          ModernTheme.iosPurple.withOpacity(0.15),
                        ]
                      : [
                          ModernTheme.backgroundSecondary.withOpacity(0.5),
                          ModernTheme.backgroundTertiary.withOpacity(0.3),
                        ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? ModernTheme.iosBlue.withOpacity(0.5)
                      : Colors.white.withOpacity(0.05),
                  width: 1.5,
                ),
              ),
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
                  if (commit.constraints.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: commit.constraints
                          .take(3)
                          .map((c) => _buildConstraintChip(c))
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: ModernTheme.textTertiary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('MMM d, y • HH:mm').format(commit.timestamp),
                        style: const TextStyle(
                          fontSize: 12,
                          color: ModernTheme.textTertiary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        commit.id.substring(0, 8),
                        style: const TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                          color: ModernTheme.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: (index * 50).ms)
        .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuart)
        .scale(begin: const Offset(0.95, 0.95), curve: Curves.easeOutQuart);
  }

  Widget _buildConfidenceBadge(int confidence) {
    Color color;
    if (confidence >= 80) {
      color = ModernTheme.accentGreen;
    } else if (confidence >= 50) {
      color = ModernTheme.accentOrange;
    } else {
      color = ModernTheme.accentRed;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        '$confidence%',
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildConstraintChip(String constraint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: ModernTheme.elevated.withOpacity(0.4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Text(
        constraint,
        style: const TextStyle(
          color: ModernTheme.textSecondary,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const NewCommitScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutQuart,
                )),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
        _loadCommits();
      },
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [ModernTheme.iosBlue, ModernTheme.iosPurple],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: ModernTheme.iosBlue.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 32,
        ),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.05, 1.05),
          duration: 1500.ms,
        )
        .then()
        .scale(
          begin: const Offset(1.05, 1.05),
          end: const Offset(1, 1),
          duration: 1500.ms,
        );
  }
}
