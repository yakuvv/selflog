import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/commit.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';

class NewCommitScreen extends StatefulWidget {
  const NewCommitScreen({super.key});

  @override
  State<NewCommitScreen> createState() => _NewCommitScreenState();
}

class _NewCommitScreenState extends State<NewCommitScreen> {
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
    setState(() {
      _constraints.removeAt(index);
    });
  }

  Future<void> _saveCommit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_constraints.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add at least one constraint'),
          backgroundColor: AppTheme.error,
        ),
      );
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

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NEW COMMIT'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Decision Title',
                hintText: 'e.g., Switch to Flutter for mobile dev',
              ),
              validator: (v) => v?.trim().isEmpty ?? true ? 'Required' : null,
              textCapitalization: TextCapitalization.sentences,
            ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),

            const SizedBox(height: 24),

            // Context
            TextFormField(
              controller: _contextController,
              decoration: const InputDecoration(
                labelText: 'Context',
                hintText: 'Describe the situation and decision factors',
              ),
              maxLines: 4,
              validator: (v) => v?.trim().isEmpty ?? true ? 'Required' : null,
              textCapitalization: TextCapitalization.sentences,
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 100.ms)
                .slideX(begin: -0.1, end: 0),

            const SizedBox(height: 24),

            // Constraints
            Text(
              'Constraints',
              style: Theme.of(context).textTheme.titleLarge,
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 200.ms)
                .slideX(begin: -0.1, end: 0),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _constraintController,
                    decoration: const InputDecoration(
                      hintText: 'Add a constraint',
                    ),
                    onSubmitted: (_) => _addConstraint(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addConstraint,
                  icon: const Icon(Icons.add_circle),
                  color: AppTheme.primary,
                ),
              ],
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 300.ms)
                .slideX(begin: -0.1, end: 0),

            const SizedBox(height: 16),

            if (_constraints.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _constraints
                    .asMap()
                    .entries
                    .map((e) => _buildConstraintChip(e.value, e.key))
                    .toList(),
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 400.ms)
                  .slideX(begin: -0.1, end: 0),

            const SizedBox(height: 24),

            // Confidence
            Text(
              'Confidence: ${_confidence.round()}%',
              style: Theme.of(context).textTheme.titleLarge,
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 500.ms)
                .slideX(begin: -0.1, end: 0),

            const SizedBox(height: 12),

            Slider(
              value: _confidence,
              min: 0,
              max: 100,
              divisions: 20,
              label: '${_confidence.round()}%',
              onChanged: (value) => setState(() => _confidence = value),
              activeColor: AppTheme.primary,
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 600.ms)
                .slideX(begin: -0.1, end: 0),

            const SizedBox(height: 24),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Additional Notes (Optional)',
                hintText: 'Any extra context or thoughts',
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 700.ms)
                .slideX(begin: -0.1, end: 0),

            const SizedBox(height: 32),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _saveCommit,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('COMMIT DECISION'),
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 800.ms)
                .slideY(begin: 0.2, end: 0),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildConstraintChip(String constraint, int index) {
    return Chip(
      label: Text(constraint),
      deleteIcon: const Icon(Icons.close, size: 18),
      onDeleted: () => _removeConstraint(index),
      backgroundColor: AppTheme.surfaceLight,
      deleteIconColor: AppTheme.textSecondary,
      labelStyle: const TextStyle(color: AppTheme.textPrimary),
    );
  }
}
