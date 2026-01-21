import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../models/commit.dart';
import '../services/storage_service.dart';
import '../services/voice_service.dart';
import '../utils/modern_theme.dart';

class NewCommitScreen extends StatefulWidget {
  const NewCommitScreen({super.key});

  @override
  State<NewCommitScreen> createState() => _NewCommitScreenState();
}

class _NewCommitScreenState extends State<NewCommitScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contextController = TextEditingController();
  final _notesController = TextEditingController();
  final _constraintController = TextEditingController();
  final List<String> _constraints = [];
  double _confidence = 50;
  bool _saving = false;

  final VoiceService _voiceService = VoiceService();
  bool _isRecording = false;
  String? _voiceNotePath;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contextController.dispose();
    _notesController.dispose();
    _constraintController.dispose();
    _voiceService.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _voiceService.stopRecording();
      setState(() {
        _isRecording = false;
        _voiceNotePath = path;
      });
      _pulseController.stop();

      if (path != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Voice note saved'),
            backgroundColor: ModernTheme.accentGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } else {
      final started = await _voiceService.startRecording();
      if (started) {
        setState(() => _isRecording = true);
        _pulseController.repeat(reverse: true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Microphone permission denied'),
            backgroundColor: ModernTheme.accentRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
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
      notes: _notesController.text.trim() +
             (_voiceNotePath != null ? '\n[Voice Note: $_voiceNotePath]' : ''),
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('New Commit'),
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
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 20),

                _buildGlassField(
                  controller: _titleController,
                  label: 'Decision Title',
                  hint: 'What did you decide?',
                  icon: Icons.title,
                  delay: 0,
                ),

                const SizedBox(height: 20),

                _buildGlassField(
                  controller: _contextController,
                  label: 'Context',
                  hint: 'Describe the situation...',
                  icon: Icons.description_outlined,
                  maxLines: 4,
                  delay: 100,
                ),

                const SizedBox(height: 30),

                _buildConstraintsSection(),

                const SizedBox(height: 30),

                _buildConfidenceSlider(),

                const SizedBox(height: 30),

                _buildVoiceNoteSection(),

                const SizedBox(height: 20),

                _buildGlassField(
                  controller: _notesController,
                  label: 'Additional Notes',
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
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ModernTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: ModernTheme.glassBox(opacity: 0.05),
              child: TextFormField(
                controller: controller,
                maxLines: maxLines,
                style: const TextStyle(color: ModernTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: const TextStyle(color: ModernTheme.textTertiary),
                  prefixIcon: Icon(icon, color: ModernTheme.iosBlue),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(20),
                ),
                validator: required
                    ? (v) => v?.trim().isEmpty ?? true ? 'Required' : null
                    : null,
              ),
            ),
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: delay.ms)
        .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuart);
  }

  Widget _buildConstraintsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Constraints',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ModernTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: ModernTheme.glassBox(opacity: 0.05),
                    child: TextField(
                      controller: _constraintController,
                      style: const TextStyle(color: ModernTheme.textPrimary),
                      decoration: const InputDecoration(
                        hintText: 'Add constraint...',
                        hintStyle: TextStyle(color: ModernTheme.textTertiary),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(20),
                      ),
                      onSubmitted: () => _addConstraint(),
                    ),
                  ),
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
                ),
                child: const Icon(Icons.add, color: Colors.white),
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
        .fadeIn(duration: 600.ms, delay: 200.ms)
        .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuart);
  }

  Widget _buildConstraintChip(String constraint, int index) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: ModernTheme.elevated.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                constraint,
                style: const TextStyle(color: ModernTheme.textPrimary),
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
        ),
      ),
    );
  }

  Widget _buildConfidenceSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Confidence Level',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ModernTheme.textSecondary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ModernTheme.iosBlue.withOpacity(0.2),
                    ModernTheme.iosPurple.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_confidence.round()}%',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ModernTheme.iosBlue,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
            activeTrackColor: ModernTheme.iosBlue,
            inactiveTrackColor: ModernTheme.elevated,
            thumbColor: ModernTheme.iosBlue,
            overlayColor: ModernTheme.iosBlue.withOpacity(0.2),
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
        .fadeIn(duration: 600.ms, delay: 300.ms)
        .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuart);
  }

  Widget _buildVoiceNoteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Voice Note',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ModernTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _toggleRecording,
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isRecording
                        ? [
                            ModernTheme.accentRed.withOpacity(
                                0.3 + _pulseController.value * 0.2),
                            ModernTheme.accentOrange.withOpacity(
                                0.3 + _pulseController.value * 0.2),
                          ]
                        : [
                            ModernTheme.iosBlue.withOpacity(0.15),
                            ModernTheme.iosPurple.withOpacity(0.15),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isRecording
                        ? ModernTheme.accentRed.withOpacity(0.5)
                        : ModernTheme.iosBlue.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      _isRecording ? Icons.stop_circle : Icons.mic_none,
                      size: 48,
                      color: _isRecording
                          ? ModernTheme.accentRed
                          : ModernTheme.iosBlue,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _isRecording
                          ? 'Recording...'
                          : _voiceNotePath != null
                              ? 'Voice note saved'
                              : 'Tap to record',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _isRecording
                            ? ModernTheme.accentRed
                            : ModernTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: 400.ms)
        .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuart);
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: _saving ? null : _saveCommit,
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [ModernTheme.iosBlue, ModernTheme.iosPurple],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: ModernTheme.iosBlue.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Center(
          child: _saving
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Commit Decision',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: 600.ms)
        .slideY(begin: 0.3, end: 0, curve: Curves.easeOutQuart)
        .scale(begin: const Offset(0.95, 0.95), curve: Curves.easeOutQuart);
  }
}

