// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:intl/intl.dart';
// import 'dart:ui';
// import '../models/commit.dart';
// import '../services/storage_service.dart';
// import '../utils/modern_theme.dart';
// import 'new_commit_screen.dart';
// import 'compare_screen.dart';
// import 'data_timeline_screen.dart';

// class TimelineScreen extends StatefulWidget {
//   const TimelineScreen({super.key});

//   @override
//   State<TimelineScreen> createState() => _TimelineScreenState();
// }

// class _TimelineScreenState extends State<TimelineScreen> {
//   final StorageService _storage = StorageService();
//   List<Commit> _commits = [];
//   bool _loading = true;
//   final Set<String> _selectedCommits = {};

//   @override
//   void initState() {
//     super.initState();
//     _loadCommits();
//   }

//   Future<void> _loadCommits() async {
//     setState(() => _loading = true);
//     final commits = await _storage.loadCommits();
//     setState(() {
//       _commits = commits..sort((a, b) => b.timestamp.compareTo(a.timestamp));
//       _loading = false;
//     });
//   }

//   void _toggleSelection(String commitId) {
//     setState(() {
//       if (_selectedCommits.contains(commitId)) {
//         _selectedCommits.remove(commitId);
//       } else {
//         if (_selectedCommits.length < 2) {
//           _selectedCommits.add(commitId);
//         } else {
//           _selectedCommits.clear();
//           _selectedCommits.add(commitId);
//         }
//       }
//     });
//   }

//   void _compareSelected() {
//     if (_selectedCommits.length != 2) return;

//     final commits = _selectedCommits
//         .map((id) => _commits.firstWhere((c) => c.id == id))
//         .toList()
//       ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => CompareScreen(
//           olderCommit: commits[0],
//           newerCommit: commits[1],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBodyBehindAppBar: false,
//       backgroundColor: ModernTheme.background,
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Custom App Bar
//             _buildAppBar(),

//             // Stats Row
//             if (_commits.isNotEmpty) _buildStatsRow(),

//             // Commit List
//             Expanded(
//               child: _loading
//                   ? _buildLoadingState()
//                   : _commits.isEmpty
//                       ? _buildEmptyState()
//                       : _buildCommitList(),
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: _buildFAB(),
//     );
//   }

//   Widget _buildAppBar() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//       child: Row(
//         children: [
//           Text(
//             'Timeline',
//             style: TextStyle(
//               fontSize: 34,
//               fontWeight: FontWeight.w900,
//               color: ModernTheme.textPrimary,
//               letterSpacing: -1.5,
//             ),
//           ),
//           const Spacer(),
//           if (_selectedCommits.length == 2)
//             GestureDetector(
//               onTap: _compareSelected,
//               child: Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [ModernTheme.iosBlue, ModernTheme.iosPurple],
//                   ),
//                   borderRadius: BorderRadius.circular(14),
//                 ),
//                 child: const Icon(Icons.compare_arrows,
//                     color: Colors.white, size: 20),
//               ),
//             ),
//           const SizedBox(width: 12),
//           GestureDetector(
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => DataTimelineScreen(commits: _commits),
//                 ),
//               );
//             },
//             child: Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: ModernTheme.backgroundSecondary,
//                 borderRadius: BorderRadius.circular(14),
//               ),
//               child: const Icon(Icons.insights,
//                   color: ModernTheme.iosBlue, size: 20),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatsRow() {
//     final avgConfidence =
//         _commits.map((c) => c.confidence).reduce((a, b) => a + b) /
//             _commits.length;

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//       child: Row(
//         children: [
//           Expanded(
//             child: _buildStatCard(
//               '${_commits.length}',
//               'Commits',
//               Icons.commit,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: _buildStatCard(
//               '${avgConfidence.toInt()}%',
//               'Avg Confidence',
//               Icons.trending_up,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatCard(String value, String label, IconData icon) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: ModernTheme.backgroundSecondary,
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: ModernTheme.iosBlue.withOpacity(0.15),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(icon, color: ModernTheme.iosBlue, size: 18),
//           ),
//           const SizedBox(width: 12),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 value,
//                 style: const TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.w800,
//                   color: ModernTheme.textPrimary,
//                 ),
//               ),
//               Text(
//                 label,
//                 style: const TextStyle(
//                   fontSize: 11,
//                   color: ModernTheme.textTertiary,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLoadingState() {
//     return const Center(
//       child: CircularProgressIndicator(color: ModernTheme.iosBlue),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 120,
//             height: 120,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   ModernTheme.iosBlue.withOpacity(0.2),
//                   ModernTheme.iosPurple.withOpacity(0.2),
//                 ],
//               ),
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(
//               Icons.timeline,
//               size: 60,
//               color: ModernTheme.iosBlue,
//             ),
//           ),
//           const SizedBox(height: 32),
//           const Text(
//             'No commits yet',
//             style: TextStyle(
//               fontSize: 28,
//               fontWeight: FontWeight.w700,
//               color: ModernTheme.textSecondary,
//             ),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             'Tap + to create your first decision',
//             style: TextStyle(
//               fontSize: 16,
//               color: ModernTheme.textTertiary,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCommitList() {
//     return ListView.builder(
//       padding: const EdgeInsets.only(left: 20, right: 20, bottom: 100, top: 8),
//       itemCount: _commits.length,
//       itemBuilder: (context, index) {
//         return _buildCommitCard(_commits[index], index);
//       },
//     );
//   }

//   Widget _buildCommitCard(Commit commit, int index) {
//     final isSelected = _selectedCommits.contains(commit.id);

//     return GestureDetector(
//       onTap: () => _toggleSelection(commit.id),
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 16),
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: isSelected
//                 ? [
//                     ModernTheme.iosBlue.withOpacity(0.25),
//                     ModernTheme.iosPurple.withOpacity(0.25),
//                   ]
//                 : [
//                     ModernTheme.backgroundSecondary,
//                     ModernTheme.backgroundTertiary,
//                   ],
//           ),
//           borderRadius: BorderRadius.circular(20),
//           border: isSelected
//               ? Border.all(color: ModernTheme.iosBlue, width: 2)
//               : null,
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Expanded(
//                   child: Text(
//                     commit.title,
//                     style: const TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.w700,
//                       color: ModernTheme.textPrimary,
//                       height: 1.2,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 _buildConfidenceBadge(commit.confidence),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Text(
//               commit.context,
//               style: const TextStyle(
//                 fontSize: 15,
//                 color: ModernTheme.textSecondary,
//                 height: 1.4,
//               ),
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//             ),
//             if (commit.constraints.isNotEmpty) ...[
//               const SizedBox(height: 16),
//               Wrap(
//                 spacing: 8,
//                 runSpacing: 8,
//                 children: commit.constraints
//                     .take(3)
//                     .map((c) => Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 12,
//                             vertical: 6,
//                           ),
//                           decoration: BoxDecoration(
//                             color: ModernTheme.elevated.withOpacity(0.5),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Text(
//                             c,
//                             style: const TextStyle(
//                               fontSize: 12,
//                               color: ModernTheme.textSecondary,
//                             ),
//                           ),
//                         ))
//                     .toList(),
//               ),
//             ],
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 Icon(
//                   Icons.access_time,
//                   size: 14,
//                   color: ModernTheme.textTertiary,
//                 ),
//                 const SizedBox(width: 6),
//                 Text(
//                   DateFormat('MMM d • HH:mm').format(commit.timestamp),
//                   style: const TextStyle(
//                     fontSize: 13,
//                     color: ModernTheme.textTertiary,
//                   ),
//                 ),
//                 const Spacer(),
//                 if (isSelected)
//                   const Icon(
//                     Icons.check_circle,
//                     color: ModernTheme.iosBlue,
//                     size: 20,
//                   ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     )
//         .animate()
//         .fadeIn(duration: 400.ms, delay: (index * 50).ms)
//         .slideX(begin: -0.1, curve: Curves.easeOut);
//   }

//   Widget _buildConfidenceBadge(int confidence) {
//     Color color;
//     if (confidence >= 80) {
//       color = ModernTheme.accentGreen;
//     } else if (confidence >= 50) {
//       color = ModernTheme.accentOrange;
//     } else {
//       color = ModernTheme.accentRed;
//     }

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.15),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: color.withOpacity(0.4), width: 1.5),
//       ),
//       child: Text(
//         '$confidence%',
//         style: TextStyle(
//           color: color,
//           fontSize: 14,
//           fontWeight: FontWeight.w800,
//         ),
//       ),
//     );
//   }

//   Widget _buildFAB() {
//     return GestureDetector(
//       onTap: () async {
//         await Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => const NewCommitScreen()),
//         );
//         _loadCommits();
//       },
//       child: Container(
//         width: 68,
//         height: 68,
//         decoration: BoxDecoration(
//           gradient: const LinearGradient(
//             colors: [ModernTheme.iosBlue, ModernTheme.iosPurple],
//           ),
//           shape: BoxShape.circle,
//           boxShadow: [
//             BoxShadow(
//               color: ModernTheme.iosBlue.withOpacity(0.6),
//               blurRadius: 25,
//               offset: const Offset(0, 12),
//             ),
//           ],
//         ),
//         child: const Icon(
//           Icons.add,
//           color: Colors.white,
//           size: 32,
//         ),
//       ),
//     );
//   }
// }

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../models/commit.dart';
import '../services/storage_service.dart';
import '../utils/modern_theme.dart';
import 'compare_screen.dart';
import 'data_timeline_screen.dart';
import 'new_commit_screen.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen>
    with TickerProviderStateMixin {
  final StorageService _storage = StorageService();
  List<Commit> _commits = [];
  bool _loading = true;
  final Set<String> _selectedCommits = {};
  late AnimationController _fabController;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _loadCommits();
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
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
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedCommits.contains(commitId)) {
        _selectedCommits.remove(commitId);
      } else {
        if (_selectedCommits.length < 2) {
          _selectedCommits.add(commitId);
        } else {
          _selectedCommits.clear();
          _selectedCommits.add(commitId);
        }
      }
    });
  }

  void _compareSelected() {
    if (_selectedCommits.length != 2) return;

    HapticFeedback.mediumImpact();
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
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      backgroundColor: ModernTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            if (_commits.isNotEmpty) _buildStatsRow(),
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
      floatingActionButton: _buildEnhancedFAB(),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ModernTheme.background,
            ModernTheme.background.withOpacity(0.9),
          ],
        ),
      ),
      child: Row(
        children: [
          Text(
            'Timeline',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              color: ModernTheme.textPrimary,
              letterSpacing: -1.5,
            ),
          ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2),
          const Spacer(),
          if (_selectedCommits.length == 2) _buildAnimatedCompareButton(),
          const SizedBox(width: 12),
          _buildIconButton(
            Icons.insights,
            () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DataTimelineScreen(commits: _commits),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedCompareButton() {
    return GestureDetector(
      onTap: _compareSelected,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [ModernTheme.iosBlue, ModernTheme.iosPurple],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: ModernTheme.iosBlue.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.compare_arrows, color: Colors.white, size: 20),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.1, 1.1),
            duration: 1000.ms)
        .shimmer(delay: 0.ms, duration: 1500.ms);
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: ModernTheme.backgroundSecondary,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: ModernTheme.iosBlue, size: 20),
      ),
    ).animate().fadeIn(duration: 400.ms).scale();
  }

  Widget _buildStatsRow() {
    final avgConfidence =
        _commits.map((c) => c.confidence).reduce((a, b) => a + b) /
            _commits.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              '${_commits.length}',
              'Commits',
              Icons.commit,
              0,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              '${avgConfidence.toInt()}%',
              'Avg Confidence',
              Icons.trending_up,
              1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, int index) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ModernTheme.iosBlue.withOpacity(0.1),
                ModernTheme.iosPurple.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ModernTheme.iosBlue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: ModernTheme.iosBlue, size: 18),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: ModernTheme.textPrimary,
                    ),
                  ),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: ModernTheme.textTertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: (index * 100).ms)
        .slideY(begin: 0.2, curve: Curves.easeOutCubic);
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [ModernTheme.iosBlue, ModernTheme.iosPurple],
              ),
              shape: BoxShape.circle,
            ),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .rotate(duration: 2000.ms),
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
              gradient: LinearGradient(
                colors: [
                  ModernTheme.iosBlue.withOpacity(0.2),
                  ModernTheme.iosPurple.withOpacity(0.2),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.timeline,
              size: 60,
              color: ModernTheme.iosBlue,
            ),
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(
                  duration: 2000.ms,
                  begin: const Offset(1, 1),
                  end: const Offset(1.1, 1.1)),
          const SizedBox(height: 32),
          const Text(
            'No commits yet',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: ModernTheme.textSecondary,
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 8),
          const Text(
            'Tap + to create your first decision',
            style: TextStyle(
              fontSize: 16,
              color: ModernTheme.textTertiary,
            ),
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }

  Widget _buildCommitList() {
    return ListView.builder(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 100, top: 8),
      itemCount: _commits.length,
      itemBuilder: (context, index) {
        return _buildEnhancedCommitCard(_commits[index], index);
      },
    );
  }

  Widget _buildEnhancedCommitCard(Commit commit, int index) {
    final isSelected = _selectedCommits.contains(commit.id);

    return GestureDetector(
      onTap: () {
        _toggleSelection(commit.id);
      },
      onLongPress: () {
        HapticFeedback.heavyImpact();
        _toggleSelection(commit.id);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isSelected
                    ? [
                        ModernTheme.iosBlue.withOpacity(0.25),
                        ModernTheme.iosPurple.withOpacity(0.25),
                      ]
                    : [
                        ModernTheme.backgroundSecondary,
                        ModernTheme.backgroundTertiary,
                      ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: isSelected
                  ? Border.all(color: ModernTheme.iosBlue, width: 2)
                  : Border.all(color: Colors.white.withOpacity(0.05), width: 1),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: ModernTheme.iosBlue.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        commit.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: ModernTheme.textPrimary,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildConfidenceBadge(commit.confidence),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  commit.context,
                  style: const TextStyle(
                    fontSize: 15,
                    color: ModernTheme.textSecondary,
                    height: 1.4,
                  ),
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
                        .map((c) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: ModernTheme.elevated.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: ModernTheme.iosBlue.withOpacity(0.2),
                                ),
                              ),
                              child: Text(
                                c,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: ModernTheme.textSecondary,
                                ),
                              ),
                            ))
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
                      DateFormat('MMM d • HH:mm').format(commit.timestamp),
                      style: const TextStyle(
                        fontSize: 13,
                        color: ModernTheme.textTertiary,
                      ),
                    ),
                    const Spacer(),
                    if (isSelected)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              ModernTheme.iosBlue,
                              ModernTheme.iosPurple
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        ),
                      )
                          .animate(onPlay: (controller) => controller.repeat())
                          .shimmer(duration: 1500.ms),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: (index * 50).ms)
        .slideX(begin: -0.1, curve: Curves.easeOut)
        .then()
        .shimmer(delay: (index * 100).ms, duration: 1000.ms);
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
      ),
      child: Text(
        '$confidence%',
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildEnhancedFAB() {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.mediumImpact();
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
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              );
            },
          ),
        );
        _loadCommits();
      },
      child: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [ModernTheme.iosBlue, ModernTheme.iosPurple],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: ModernTheme.iosBlue.withOpacity(0.6),
              blurRadius: 25,
              offset: const Offset(0, 12),
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
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
            duration: 2000.ms,
            begin: const Offset(1, 1),
            end: const Offset(1.05, 1.05))
        .then()
        .shimmer(duration: 2000.ms);
  }
}
