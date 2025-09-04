import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import 'package:breakup_recovery/services/firestore_service.dart';
import 'package:breakup_recovery/models/plan_step_model.dart';
import 'package:breakup_recovery/widgets/br_components.dart';
import 'package:breakup_recovery/theme.dart';

class StepDetailScreen extends StatefulWidget {
  final String userId;
  final String planId;
  final PlanStepModel step;
  final Function(bool completed)? onStepCompleted;

  const StepDetailScreen({
    super.key,
    required this.userId,
    required this.planId,
    required this.step,
    this.onStepCompleted,
  });

  @override
  State<StepDetailScreen> createState() => _StepDetailScreenState();
}

class _StepDetailScreenState extends State<StepDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _noteController = TextEditingController();
  late ConfettiController _confettiController;
  bool _isCompleted = false;
  bool _isLoading = false;
  bool _wasCompletedBefore = false;

  @override
  void initState() {
    super.initState();
    _isCompleted = widget.step.completed;
    _wasCompletedBefore = widget.step.completed;
    _noteController.text = widget.step.note;
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BRColors.background,
      body: Stack(
        children: [
          Column(
            children: [
              BRAppBar(
                title: 'Step ${widget.step.index + 1}',
              ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: BRSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: BRSpacing.lg),
                  
                  // Hero title
                  Text(
                    widget.step.title,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: BRColors.text,
                    ),
                  ),
                  
                  if (widget.step.isPremium) ...[
                    const SizedBox(height: BRSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: BRSpacing.sm,
                        vertical: BRSpacing.xs / 2,
                      ),
                      decoration: BoxDecoration(
                        color: BRColors.warning.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(BRRadius.chip),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: BRColors.warning,
                          ),
                          const SizedBox(width: BRSpacing.xs / 2),
                          Text(
                            'Premium',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: BRColors.warning,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: BRSpacing.lg),
                  
                  // Description card
                  Container(
                    width: double.infinity,
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
                    child: Text(
                      _getStepDescription(widget.step.title),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 16,
                        height: 1.5,
                        color: BRColors.text,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: BRSpacing.lg),
                  
                  // Completion switch
                  Container(
                    width: double.infinity,
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
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Mark as completed',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: BRColors.text,
                            ),
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Switch(
                            key: ValueKey(_isCompleted),
                            value: _isCompleted,
                            activeColor: BRColors.primary,
                            onChanged: _isLoading ? null : (value) {
                              HapticFeedback.mediumImpact();
                              setState(() => _isCompleted = value);
                              _updateStepCompletion();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: BRSpacing.lg),
                  
                  // Note field
                  Container(
                    width: double.infinity,
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
                          'Personal Notes',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: BRColors.text,
                          ),
                        ),
                        const SizedBox(height: BRSpacing.sm),
                        TextField(
                          controller: _noteController,
                          maxLines: 4,
                          onChanged: (value) => _saveNote(),
                          decoration: InputDecoration(
                            hintText: 'How did this step go? What did you learn?\n\nReflect on your experience...',
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
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: BRSpacing.xxl),
                ],
              ),
            ),
          ),
          
            // Sticky continue button
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
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
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
                            'Continue',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
        // Confetti overlay
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple,
            ],
          ),
        ),
      ],
    ),
  );
  }

  Future<void> _updateStepCompletion() async {
    setState(() => _isLoading = true);
    try {
      await _firestoreService.updatePlanStep(
        widget.userId,
        widget.planId,
        widget.step.index,
        _isCompleted,
        note: _noteController.text,
      );
      
      // Show confetti on first completion
      if (_isCompleted && !_wasCompletedBefore) {
        HapticFeedback.heavyImpact();
        _confettiController.play();
      }
      
      // Notify parent screen about completion change
      if (widget.onStepCompleted != null) {
        widget.onStepCompleted!(_isCompleted);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating step: $e'),
            backgroundColor: BRColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      setState(() => _isCompleted = !_isCompleted);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveNote() async {
    if (_noteController.text.trim() != widget.step.note) {
      try {
        await _firestoreService.updatePlanStepNote(
          widget.userId,
          widget.planId,
          widget.step.index,
          _noteController.text,
        );
      } catch (e) {
        // Silently fail note updates
      }
    }
  }

  String _getStepDescription(String title) {
    switch (title) {
      case 'Understanding Your Emotions':
        return 'Learn to recognize and name your emotions without judgment. Understanding what you\'re feeling is the first step toward healing. Practice emotional awareness and validate your feelings as part of the natural healing process.';
      case 'Building a Support Network':
        return 'Reach out to friends, family, or support groups who can provide emotional support during this time. Building strong connections will help you feel less isolated and provide different perspectives on your healing journey.';
      case 'Developing Self-Care Routines':
        return 'Create daily habits that prioritize your physical and mental well-being. This includes regular exercise, proper nutrition, adequate sleep, and activities that bring you joy and relaxation.';
      case 'Processing Grief and Loss':
        return 'Allow yourself to grieve the relationship and what it meant to you. Grief is a natural response to loss, and working through it is essential for moving forward. Consider journaling or talking to a counselor.';
      case 'Rediscovering Your Identity':
        return 'Reconnect with who you are outside of the relationship. Explore your interests, values, and goals. This is an opportunity to rediscover aspects of yourself that may have been overshadowed.';
      case 'Advanced Emotional Regulation':
        return '🔒 Premium: Master advanced techniques for managing intense emotions, including cognitive restructuring, distress tolerance skills, and healthy coping strategies that will serve you throughout life.';
      case 'Future Relationship Planning':
        return '🔒 Premium: Learn how to prepare for future relationships by identifying patterns, setting healthy boundaries, and developing the skills needed for lasting, fulfilling partnerships.';
      default:
        return 'Take your time with this step and be patient with yourself as you work through the healing process. Every small step forward is progress worth celebrating.';
    }
  }
}