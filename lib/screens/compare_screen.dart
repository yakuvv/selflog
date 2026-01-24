// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:intl/intl.dart';
// import 'dart:ui';
// import '../models/commit.dart';
// import '../services/analysis_service.dart';
// import '../services/ai_agent_service.dart';
// import '../utils/modern_theme.dart';

// class CompareScreen extends StatefulWidget {
//   final Commit olderCommit;
//   final Commit newerCommit;

//   const CompareScreen({
//     super.key,
//     required this.olderCommit,
//     required this.newerCommit,
//   });

//   @override
//   State<CompareScreen> createState() => _CompareScreenState();
// }

// class _CompareScreenState extends State<CompareScreen> {
//   final AnalysisService _analysisService = AnalysisService();
//   final AIAgentService _aiService = AIAgentService();

//   String _aiAnalysis = '';
//   bool _loadingAI = false;
//   bool _showAI = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadAIAnalysis();
//   }

//   Future<void> _loadAIAnalysis() async {
//     setState(() => _loadingAI = true);

//     final analysis = await _aiService.generateAdvancedAnalysis(
//       widget.olderCommit,
//       widget.newerCommit,
//     );

//     setState(() {
//       _aiAnalysis = analysis;
//       _loadingAI = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final diff = _analysisService.generateDiff(
//       widget.olderCommit,
//       widget.newerCommit,
//     );

//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: const Text('Commit Diff'),
//         actions: [
//           IconButton(
//             icon: Icon(
//               _showAI ? Icons.analytics : Icons.psychology_outlined,
//               color: ModernTheme.iosPurple,
//             ),
//             onPressed: () => setState(() => _showAI = !_showAI),
//           ),
//         ],
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               ModernTheme.background,
//               ModernTheme.iosPurple.withOpacity(0.08),
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: ListView(
//             padding: const EdgeInsets.all(24),
//             children: [
//               const SizedBox(height: 20),

//               _buildCommitCard('OLDER', widget.olderCommit, ModernTheme.accentRed, 0),

//               const SizedBox(height: 16),

//               _buildDiffIndicator(diff),

//               const SizedBox(height: 16),

//               _buildCommitCard('NEWER', widget.newerCommit, ModernTheme.accentGreen, 1),

//               const SizedBox(height: 30),

//               if (_showAI)
//                 _buildAIAnalysisCard()
//               else
//                 _buildLocalAnalysisCard(diff),

//               const SizedBox(height: 30),

//               _buildDiffDetails(diff),

//               const SizedBox(height: 30),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildCommitCard(String label, Commit commit, Color color, int index) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(20),
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//         child: Container(
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [
//                 color.withOpacity(0.1),
//                 color.withOpacity(0.05),
//               ],
//             ),
//             borderRadius: BorderRadius.circular(20),
//             border: Border.all(color: color.withOpacity(0.3), width: 2),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                     decoration: BoxDecoration(
//                       color: color.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Text(
//                       label,
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                         color: color,
//                       ),
//                     ),
//                   ),
//                   const Spacer(),
//                   Text(
//                     commit.id.substring(0, 8),
//                     style: const TextStyle(
//                       fontFamily: 'monospace',
//                       fontSize: 12,
//                       color: ModernTheme.textTertiary,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 commit.title,
//                 style: const TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.w600,
//                   color: ModernTheme.textPrimary,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 DateFormat('MMM d, y • HH:mm').format(commit.timestamp),
//                 style: const TextStyle(
//                   fontSize: 14,
//                   color: ModernTheme.textTertiary,
//                 ),
//               ),
//               const SizedBox(height: 12),
//               Row(
//                 children: [
//                   const Text(
//                     'Confidence: ',
//                     style: TextStyle(color: ModernTheme.textSecondary),
//                   ),
//                   Text(
//                     '${commit.confidence}%',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: color,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     )
//         .animate()
//         .fadeIn(duration: 600.ms, delay: (index * 150).ms)
//         .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuart);
//   }

//   Widget _buildDiffIndicator(CommitDiff diff) {
//     return Center(
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               ModernTheme.iosBlue.withOpacity(0.2),
//               ModernTheme.iosPurple.withOpacity(0.2),
//             ],
//           ),
//           shape: BoxShape.circle,
//         ),
//         child: Icon(
//           diff.confidenceDelta > 0
//               ? Icons.trending_up
//               : diff.confidenceDelta < 0
//                   ? Icons.trending_down
//                   : Icons.trending_flat,
//           size: 32,
//           color: diff.confidenceDelta > 0
//               ? ModernTheme.accentGreen
//               : diff.confidenceDelta < 0
//                   ? ModernTheme.accentRed
//                   : ModernTheme.textTertiary,
//         ),
//       ),
//     )
//         .animate()
//         .fadeIn(duration: 600.ms, delay: 300.ms)
//         .scale(begin: const Offset(0.5, 0.5), curve: Curves.easeOutBack);
//   }

//   Widget _buildAIAnalysisCard() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Icon(
//               Icons.psychology_outlined,
//               color: ModernTheme.iosPurple,
//               size: 24,
//             ),
//             const SizedBox(width: 12),
//             const Text(
//               'AI Agent Analysis',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.w600,
//                 color: ModernTheme.textPrimary,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 16),
//         ClipRRect(
//           borderRadius: BorderRadius.circular(20),
//           child: BackdropFilter(
//             filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//             child: Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(24),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [
//                     ModernTheme.iosPurple.withOpacity(0.15),
//                     ModernTheme.iosBlue.withOpacity(0.1),
//                   ],
//                 ),
//                 borderRadius: BorderRadius.circular(20),
//                 border: Border.all(
//                   color: ModernTheme.iosPurple.withOpacity(0.3),
//                   width: 1.5,
//                 ),
//               ),
//               child: _loadingAI
//                   ? const Center(
//                       child: Padding(
//                         padding: EdgeInsets.all(20),
//                         child: CircularProgressIndicator(
//                           color: ModernTheme.iosPurple,
//                           strokeWidth: 2,
//                         ),
//                       ),
//                     )
//                   : SelectableText(
//                       _aiAnalysis,
//                       style: const TextStyle(
//                         fontFamily: 'monospace',
//                         fontSize: 13,
//                         color: ModernTheme.textPrimary,
//                         height: 1.6,
//                       ),
//                     ),
//             ),
//           ),
//         ),
//       ],
//     )
//         .animate()
//         .fadeIn(duration: 600.ms, delay: 600.ms)
//         .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuart);
//   }

//   Widget _buildLocalAnalysisCard(CommitDiff diff) {
//     final localAnalysis = _analysisService.generateAnalysis(diff);

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Icon(
//               Icons.analytics_outlined,
//               color: ModernTheme.iosBlue,
//               size: 24,
//             ),
//             const SizedBox(width: 12),
//             const Text(
//               'Local Analysis',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.w600,
//                 color: ModernTheme.textPrimary,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 16),
//         ClipRRect(
//           borderRadius: BorderRadius.circular(20),
//           child: BackdropFilter(
//             filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//             child: Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(24),
//               decoration: ModernTheme.glassBox(opacity: 0.05),
//               child: SelectableText(
//                 localAnalysis,
//                 style: const TextStyle(
//                   fontFamily: 'monospace',
//                   fontSize: 13,
//                   color: ModernTheme.textPrimary,
//                   height: 1.6,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     )
//         .animate()
//         .fadeIn(duration: 600.ms, delay: 600.ms)
//         .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuart);
//   }

//   Widget _buildDiffDetails(CommitDiff diff) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Detailed Diff',
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.w600,
//             color: ModernTheme.textPrimary,
//           ),
//         ),
//         const SizedBox(height: 16),

//         _buildDiffMetric(
//           'Confidence Delta',
//           '${diff.confidenceDelta > 0 ? '+' : ''}${diff.confidenceDelta}%',
//           diff.confidenceDelta > 0
//               ? ModernTheme.accentGreen
//               : diff.confidenceDelta < 0
//                   ? ModernTheme.accentRed
//                   : ModernTheme.textTertiary,
//           Icons.trending_up,
//           0,
//         ),

//         const SizedBox(height: 12),

//         _buildDiffMetric(
//           'Time Elapsed',
//           _formatDuration(diff.timeDelta),
//           ModernTheme.iosBlue,
//           Icons.access_time,
//           1,
//         ),

//         const SizedBox(height: 12),

//         _buildDiffMetric(
//           'Constraints Added',
//           '${diff.constraintsAdded.length}',
//           ModernTheme.accentGreen,
//           Icons.add_circle_outline,
//           2,
//         ),

//         const SizedBox(height: 12),

//         _buildDiffMetric(
//           'Constraints Removed',
//           '${diff.constraintsRemoved.length}',
//           ModernTheme.accentRed,
//           Icons.remove_circle_outline,
//           3,
//         ),

//         const SizedBox(height: 12),

//         _buildDiffMetric(
//           'Context Status',
//           diff.contextEvolution,
//           ModernTheme.iosPurple,
//           Icons.description,
//           4,
//         ),
//       ],
//     );
//   }

//   Widget _buildDiffMetric(
//     String label,
//     String value,
//     Color color,
//     IconData icon,
//     int index,
//   ) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(16),
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//         child: Container(
//           padding: const EdgeInsets.all(18),
//           decoration: ModernTheme.glassBox(opacity: 0.05),
//           child: Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: color.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Icon(icon, color: color, size: 22),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Text(
//                   label,
//                   style: const TextStyle(
//                     fontSize: 15,
//                     color: ModernTheme.textSecondary,
//                   ),
//                 ),
//               ),
//               Text(
//                 value,
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: color,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     )
//         .animate()
//         .fadeIn(duration: 400.ms, delay: (800 + index * 80).ms)
//         .slideX(begin: -0.2, end: 0, curve: Curves.easeOutQuart);
//   }

//   String _formatDuration(Duration duration) {
//     if (duration.inDays > 0) {
//       return '${duration.inDays}d ${duration.inHours % 24}h';
//     }
//     if (duration.inHours > 0) {
//       return '${duration.inHours}h ${duration.inMinutes % 60}m';
//     }
//     if (duration.inMinutes > 0) return '${duration.inMinutes}m';
//       return '${duration.inSeconds}s';
//   }
// }
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../models/commit.dart';
import '../services/ai_agent_service.dart';
import '../services/analysis_service.dart';
import '../utils/modern_theme.dart';

class CompareScreen extends StatefulWidget {
  final Commit olderCommit;
  final Commit newerCommit;

  const CompareScreen({
    super.key,
    required this.olderCommit,
    required this.newerCommit,
  });

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  final AnalysisService _analysisService = AnalysisService();
  final AIAgentService _aiService = AIAgentService();

  String _aiAnalysis = '';
  bool _loadingAI = false;
  bool _showAI = false;

  @override
  void initState() {
    super.initState();
    _loadAIAnalysis();
  }

  Future<void> _loadAIAnalysis() async {
    setState(() => _loadingAI = true);

    final analysis = await _aiService.generateAdvancedAnalysis(
      widget.olderCommit,
      widget.newerCommit,
    );

    setState(() {
      _aiAnalysis = analysis;
      _loadingAI = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final diff = _analysisService.generateDiff(
      widget.olderCommit,
      widget.newerCommit,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Compare Decisions'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: _showAI
                  ? LinearGradient(
                      colors: [ModernTheme.iosPurple, ModernTheme.iosBlue],
                    )
                  : null,
              color: _showAI ? null : ModernTheme.backgroundSecondary,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _showAI
                    ? ModernTheme.iosPurple
                    : ModernTheme.textTertiary.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _showAI ? Icons.psychology : Icons.analytics_outlined,
                  color: _showAI ? Colors.white : ModernTheme.iosBlue,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  _showAI ? 'AI' : 'Quick',
                  style: TextStyle(
                    color: _showAI ? Colors.white : ModernTheme.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ).animate(target: _showAI ? 1 : 0).shimmer(duration: 800.ms),
        ],
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          // Swipe to toggle between analyses
          if (details.primaryVelocity! > 0) {
            setState(() => _showAI = false);
          } else if (details.primaryVelocity! < 0) {
            setState(() => _showAI = true);
          }
        },
        child: Container(
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
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 20),

                _buildCommitCard(
                    'OLDER', widget.olderCommit, ModernTheme.accentRed, 0),

                const SizedBox(height: 16),

                _buildDiffIndicator(diff),

                const SizedBox(height: 16),

                _buildCommitCard(
                    'NEWER', widget.newerCommit, ModernTheme.accentGreen, 1),

                const SizedBox(height: 30),

                // Toggle instruction
                GestureDetector(
                  onTap: () => setState(() => _showAI = !_showAI),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: ModernTheme.backgroundSecondary.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: ModernTheme.textTertiary.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.swipe_left,
                          size: 16,
                          color: ModernTheme.textTertiary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Tap here or swipe to switch analysis modes',
                          style: TextStyle(
                            fontSize: 12,
                            color: ModernTheme.textTertiary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.swipe_right,
                          size: 16,
                          color: ModernTheme.textTertiary,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Analysis card with animation
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.1, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: _showAI
                      ? _buildAIAnalysisCard()
                      : _buildLocalAnalysisCard(diff),
                ),

                const SizedBox(height: 30),

                _buildDiffDetails(diff),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCommitCard(String label, Commit commit, Color color, int index) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.3), width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    commit.id.substring(0, 8),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: ModernTheme.textTertiary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                commit.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: ModernTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat('MMM d, y • HH:mm').format(commit.timestamp),
                style: const TextStyle(
                  fontSize: 14,
                  color: ModernTheme.textTertiary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text(
                    'Confidence: ',
                    style: TextStyle(color: ModernTheme.textSecondary),
                  ),
                  Text(
                    '${commit.confidence}%',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
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
        .fadeIn(duration: 600.ms, delay: (index * 150).ms)
        .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuart);
  }

  Widget _buildDiffIndicator(CommitDiff diff) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              ModernTheme.iosBlue.withOpacity(0.2),
              ModernTheme.iosPurple.withOpacity(0.2),
            ],
          ),
          shape: BoxShape.circle,
        ),
        child: Icon(
          diff.confidenceDelta > 0
              ? Icons.trending_up
              : diff.confidenceDelta < 0
                  ? Icons.trending_down
                  : Icons.trending_flat,
          size: 32,
          color: diff.confidenceDelta > 0
              ? ModernTheme.accentGreen
              : diff.confidenceDelta < 0
                  ? ModernTheme.accentRed
                  : ModernTheme.textTertiary,
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: 300.ms)
        .scale(begin: const Offset(0.5, 0.5), curve: Curves.easeOutBack);
  }

  Widget _buildAIAnalysisCard() {
    return Column(
      key: const ValueKey('ai-analysis'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [ModernTheme.iosPurple, ModernTheme.iosBlue],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.psychology,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'AI Analysis',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: ModernTheme.textPrimary,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: ModernTheme.iosPurple.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Enhanced',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: ModernTheme.iosPurple,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ModernTheme.iosPurple.withOpacity(0.15),
                    ModernTheme.iosBlue.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: ModernTheme.iosPurple.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: _loadingAI
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(
                          color: ModernTheme.iosPurple,
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  : SelectableText(
                      _aiAnalysis,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        color: ModernTheme.textPrimary,
                        height: 1.6,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocalAnalysisCard(CommitDiff diff) {
    final localAnalysis = _analysisService.generateAnalysis(diff);

    return Column(
      key: const ValueKey('local-analysis'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ModernTheme.iosBlue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.analytics_outlined,
                color: ModernTheme.iosBlue,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Quick Analysis',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: ModernTheme.textPrimary,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: ModernTheme.iosBlue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Fast',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: ModernTheme.iosBlue,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: ModernTheme.glassBox(opacity: 0.05),
              child: SelectableText(
                localAnalysis,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  color: ModernTheme.textPrimary,
                  height: 1.6,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDiffDetails(CommitDiff diff) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What Changed',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: ModernTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        _buildDiffMetric(
          'Confidence Change',
          '${diff.confidenceDelta > 0 ? '+' : ''}${diff.confidenceDelta}%',
          diff.confidenceDelta > 0
              ? ModernTheme.accentGreen
              : diff.confidenceDelta < 0
                  ? ModernTheme.accentRed
                  : ModernTheme.textTertiary,
          Icons.insights,
          0,
        ),
        const SizedBox(height: 12),
        _buildDiffMetric(
          'Time Between Decisions',
          _formatDuration(diff.timeDelta),
          ModernTheme.iosBlue,
          Icons.schedule,
          1,
        ),
        const SizedBox(height: 12),
        _buildDiffMetric(
          'New Factors Added',
          '${diff.constraintsAdded.length}',
          ModernTheme.accentGreen,
          Icons.add_task,
          2,
        ),
        const SizedBox(height: 12),
        _buildDiffMetric(
          'Factors Removed',
          '${diff.constraintsRemoved.length}',
          ModernTheme.accentRed,
          Icons.clear,
          3,
        ),
        const SizedBox(height: 12),
        _buildDiffMetric(
          'Reasoning Status',
          diff.contextEvolution,
          ModernTheme.iosPurple,
          Icons.auto_awesome,
          4,
        ),
      ],
    );
  }

  Widget _buildDiffMetric(
    String label,
    String value,
    Color color,
    IconData icon,
    int index,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: ModernTheme.glassBox(opacity: 0.05),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    color: ModernTheme.textSecondary,
                  ),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: (800 + index * 80).ms)
        .slideX(begin: -0.2, end: 0, curve: Curves.easeOutQuart);
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    }
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    }
    if (duration.inMinutes > 0) return '${duration.inMinutes}m';
    return '${duration.inSeconds}s';
  }
}
