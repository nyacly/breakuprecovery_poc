import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:breakup_recovery/services/auth_service.dart';
import 'package:breakup_recovery/repositories/breakup_recovery_repository.dart';
import 'package:breakup_recovery/models/journal_entry_model.dart';
import 'package:breakup_recovery/widgets/br_components.dart';
import 'package:breakup_recovery/theme.dart';

class JournalEditorScreen extends StatefulWidget {
  final JournalEntryModel? entry;

  const JournalEditorScreen({super.key, this.entry});

  @override
  State<JournalEditorScreen> createState() => _JournalEditorScreenState();
}

class _JournalEditorScreenState extends State<JournalEditorScreen> {
  final AuthService _authService = AuthService();
  final BreakupRecoveryRepository _repository = BreakupRecoveryRepository();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final FocusNode _bodyFocusNode = FocusNode();
  
  Mood _selectedMood = Mood.okay;
  bool _isLoading = false;
  bool get _isEditing => widget.entry != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _titleController.text = widget.entry!.title;
      _bodyController.text = widget.entry!.body;
      _selectedMood = widget.entry!.mood;
    }
  }

  bool get _canSave => 
      _titleController.text.trim().isNotEmpty &&
      _bodyController.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BRColors.background,
      body: Column(
        children: [
          BRAppBar(
            title: _isEditing ? 'Edit Entry' : 'New Entry',
            actions: [
              if (_isEditing)
                IconButton(
                  onPressed: _showDeleteDialog,
                  icon: Icon(
                    Icons.delete_rounded,
                    color: BRColors.error,
                  ),
                ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: BRSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: BRSpacing.lg),
                  
                  // Mood selector
                  Text(
                    'How are you feeling?',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: BRColors.text,
                    ),
                  ),
                  const SizedBox(height: BRSpacing.lg),
                  
                  _buildMoodChips(),
                  
                  const SizedBox(height: BRSpacing.lg),
                  
                  // Title input
                  Container(
                    padding: const EdgeInsets.all(BRSpacing.lg),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          offset: const Offset(0, 6),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Title',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: BRColors.text,
                          ),
                        ),
                        const SizedBox(height: BRSpacing.sm),
                        TextField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            hintText: 'Give your entry a title...',
                            hintStyle: TextStyle(
                              color: BRColors.textSecondary,
                              fontSize: 16,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 16,
                            color: BRColors.text,
                          ),
                          onSubmitted: (_) => _bodyFocusNode.requestFocus(),
                          onChanged: (_) => setState(() {}),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: BRSpacing.lg),
                  
                  // Body input
                  Container(
                    padding: const EdgeInsets.all(BRSpacing.lg),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          offset: const Offset(0, 6),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Thoughts',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: BRColors.text,
                          ),
                        ),
                        const SizedBox(height: BRSpacing.sm),
                        TextField(
                          controller: _bodyController,
                          focusNode: _bodyFocusNode,
                          maxLines: 12,
                          decoration: InputDecoration(
                            hintText: 'What\'s on your mind today? How are you feeling about your journey?\n\nReflect on your progress, challenges, victories, or anything that comes to mind...',
                            hintStyle: TextStyle(
                              color: BRColors.textSecondary,
                              fontSize: 16,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 16,
                            color: BRColors.text,
                            height: 1.5,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: BRSpacing.xxl),
                ],
              ),
            ),
          ),
          
          // Save button
          Container(
            padding: const EdgeInsets.all(BRSpacing.md),
            decoration: BoxDecoration(
              color: BRColors.background,
              border: Border(
                top: BorderSide(
                  color: Colors.grey.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _canSave ? 1.0 : 0.5,
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: (_canSave && !_isLoading) ? _saveEntry : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BRColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            _isEditing ? 'Update Entry' : 'Save Entry',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodChips() {
    return Wrap(
      spacing: BRSpacing.sm,
      runSpacing: BRSpacing.sm,
      children: Mood.values.map((mood) {
        final isSelected = _selectedMood == mood;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _selectedMood = mood);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: BRSpacing.md,
              vertical: BRSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: isSelected ? BRColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? BRColors.primary : Colors.grey.withValues(alpha: 0.3),
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: BRColors.primary.withValues(alpha: 0.2),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                  ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  mood.emoji,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: BRSpacing.xs),
                Text(
                  mood.name.toUpperCase(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : BRColors.text,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _saveEntry() async {
    final user = _authService.currentUser;
    if (user == null) return;

    if (_titleController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter a title for your entry');
      return;
    }

    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();

    try {
      if (_isEditing) {
        final updatedEntry = widget.entry!.copyWith(
          title: _titleController.text.trim(),
          body: _bodyController.text.trim(),
          mood: _selectedMood,
        );
        await _repository.updateJournalEntry(updatedEntry);
      } else {
        await _repository.createJournalEntry(
          _titleController.text.trim(),
          _bodyController.text.trim(),
          _selectedMood,
        );
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Entry updated!' : 'Entry saved!'),
            backgroundColor: BRColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      _showErrorSnackBar('Failed to save entry: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this journal entry? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: _deleteEntry,
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteEntry() async {
    if (!_isEditing) return;

    Navigator.of(context).pop(); // Close dialog

    try {
      await _repository.deleteJournalEntry(widget.entry!.id);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Entry deleted'),
            backgroundColor: BRColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      _showErrorSnackBar('Failed to delete entry: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: BRColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _bodyFocusNode.dispose();
    super.dispose();
  }
}