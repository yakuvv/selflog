import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../models/commit.dart';
import '../services/storage_service.dart';
import '../utils/modern_theme.dart';

class NewCommitScreen extends StatefulWidget {
  const NewCommitScreen({super.key});

  @override
  State<NewCommitScreen> createState() => _NewCommitScreenState();
}

class _NewCommitScreenState extends State<NewCommitScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contextController = TextEditingController();
  final _notesController = TextEditingController();
  final _constraintController = TextEditingController();
  final List<String> _constraints = [];
  double _confidence = 50;
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contextController.dispose();
    _notesController.dispose();
    _constraintController.dispose();
    super.dispose();
  }

  void _addConstraint() {
    final constraint = _constraintController.text.trim();
    if (constraint.isNotEmpty) {
      setState(() {
        _constraints.add(constraint);
        _constraintController.clear();
      });
    }
  }

  void _removeConstraint(int index) {
    setState(() => _constraints.removeAt(index));
  }

  Future<void> _saveCommit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_constraints.isEmpty) {
      _showError('Add at least one constraint');
      return;
    }

    setState(() => _saving = true);

    final commit = Commit(
      title: _titleController.text.trim(),
      context: _contextController.text.trim(),
      constraints: _constraints,
      confidence: _confidence.round(),
      notes: _notesController.text.trim(),
    );

    await StorageService().addCommit(commit);

    if (mounted) Navigator.pop(context);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ModernTheme.accentRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernTheme.background,
      appBar: AppBar(
        backgroundColor: ModernTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: ModernTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'New Commit',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: ModernTheme.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _buildGlassField(
                controller: _titleController,
                label: 'Decision Title',
                hint: 'What did you decide?',
                icon: Icons.lightbulb_outline,
                delay: 0,
              ),
              const SizedBox(height: 24),
              _buildGlassField(
                controller: _contextController,
                label: 'Context',
                hint: 'Describe the situation...',
                icon: Icons.description_outlined,
                maxLines: 4,
                delay: 100,
              ),
              const SizedBox(height: 32),
              _buildConstraintsSection(),
              const SizedBox(height: 32),
              _buildConfidenceSlider(),
              const SizedBox(height: 32),
              _buildVoiceNoteSection(),
              const SizedBox(height: 24),
              _buildGlassField(
                controller: _notesController,
                label: 'Additional Notes (Optional)',
                hint: 'Any extra thoughts...',
                icon: Icons.note_outlined,
                maxLines: 3,
                delay: 500,
                required: false,
              ),
              const SizedBox(height: 40),
              _buildSaveButton(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    required int delay,
    bool required = true,
  }) {
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: ModernTheme.textSecondary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: ModernTheme.backgroundSecondary,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: ModernTheme.textTertiary.withOpacity(0.1),
                ),
              ),
              child: TextFormField(
                controller: controller,
                maxLines: maxLines,
                style: const TextStyle(
                  color: ModernTheme.textPrimary,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(
                    color: ModernTheme.textTertiary.withOpacity(0.5),
                    fontSize: 15,
                  ),
                  prefixIcon: Icon(icon, color: ModernTheme.iosBlue, size: 22),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(18),
                ),
                validator: required
                    ? (v) => v?.trim().isEmpty ?? true
                          ? 'This field is required'
                          : null
                    : null,
              ),
            ),
          ],
        )
        .animate()
        .fadeIn(duration: 500.ms, delay: delay.ms)
        .slideY(begin: 0.1, end: 0, curve: Curves.easeOut);
  }

  Widget _buildConstraintsSection() {
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Constraints',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: ModernTheme.textSecondary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: ModernTheme.backgroundSecondary,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: ModernTheme.textTertiary.withOpacity(0.1),
                      ),
                    ),
                    child: TextField(
                      controller: _constraintController,
                      style: const TextStyle(
                        color: ModernTheme.textPrimary,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Add a constraint...',
                        hintStyle: TextStyle(
                          color: ModernTheme.textTertiary.withOpacity(0.5),
                          fontSize: 15,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(18),
                      ),
                      onSubmitted: (_) => _addConstraint(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _addConstraint,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [ModernTheme.iosBlue, ModernTheme.iosPurple],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: ModernTheme.iosBlue.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 26),
                  ),
                ),
              ],
            ),
            if (_constraints.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _constraints
                    .asMap()
                    .entries
                    .map((e) => _buildConstraintChip(e.value, e.key))
                    .toList(),
              ),
            ],
          ],
        )
        .animate()
        .fadeIn(duration: 500.ms, delay: 200.ms)
        .slideY(begin: 0.1, end: 0, curve: Curves.easeOut);
  }

  Widget _buildConstraintChip(String constraint, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: ModernTheme.backgroundTertiary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ModernTheme.iosBlue.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            constraint,
            style: const TextStyle(
              color: ModernTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _removeConstraint(index),
            child: const Icon(
              Icons.close,
              size: 18,
              color: ModernTheme.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceSlider() {
    Color confidenceColor;
    if (_confidence >= 80) {
      confidenceColor = ModernTheme.accentGreen;
    } else if (_confidence >= 50) {
      confidenceColor = ModernTheme.accentOrange;
    } else {
      confidenceColor = ModernTheme.accentRed;
    }

    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Confidence Level',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: ModernTheme.textSecondary,
                    letterSpacing: -0.3,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: confidenceColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: confidenceColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    '${_confidence.round()}%',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: confidenceColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SliderTheme(
              data: SliderThemeData(
                trackHeight: 8,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 28),
                activeTrackColor: confidenceColor,
                inactiveTrackColor: ModernTheme.backgroundTertiary,
                thumbColor: confidenceColor,
                overlayColor: confidenceColor.withOpacity(0.2),
              ),
              child: Slider(
                value: _confidence,
                min: 0,
                max: 100,
                onChanged: (value) => setState(() => _confidence = value),
              ),
            ),
          ],
        )
        .animate()
        .fadeIn(duration: 500.ms, delay: 300.ms)
        .slideY(begin: 0.1, end: 0, curve: Curves.easeOut);
  }

  Widget _buildVoiceNoteSection() {
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Voice Note',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: ModernTheme.textSecondary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: ModernTheme.backgroundSecondary,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: ModernTheme.textTertiary.withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.mic_off_outlined,
                    size: 48,
                    color: ModernTheme.textTertiary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    kIsWeb
                        ? 'Voice recording unavailable on web'
                        : 'Voice recording feature',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: ModernTheme.textTertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    kIsWeb
                        ? 'Use mobile app for voice notes'
                        : 'Coming soon in mobile version',
                    style: TextStyle(
                      fontSize: 13,
                      color: ModernTheme.textTertiary.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        )
        .animate()
        .fadeIn(duration: 500.ms, delay: 400.ms)
        .slideY(begin: 0.1, end: 0, curve: Curves.easeOut);
  }

  Widget _buildSaveButton() {
    return GestureDetector(
          onTap: _saving ? null : _saveCommit,
          child: Container(
            width: double.infinity,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [ModernTheme.iosBlue, ModernTheme.iosPurple],
              ),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: ModernTheme.iosBlue.withOpacity(0.5),
                  blurRadius: 25,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Center(
              child: _saving
                  ? const SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Commit Decision',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                        SizedBox(width: 10),
                        Icon(Icons.check_circle, color: Colors.white, size: 22),
                      ],
                    ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 500.ms, delay: 600.ms)
        .slideY(begin: 0.2, end: 0, curve: Curves.easeOut)
        .shimmer(delay: 1500.ms, duration: 2000.ms);
  }
}
