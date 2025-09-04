import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:breakup_recovery/theme.dart';

// BRAppBar: large title, back, optional actions
class BRAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBack;
  final VoidCallback? onBack;

  const BRAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBack = true,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: BRSpacing.md,
          vertical: BRSpacing.sm,
        ),
        child: Row(
          children: [
            if (showBack)
              IconButton(
                onPressed: onBack ?? () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded),
                iconSize: 24,
                color: BRColors.text,
                style: IconButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  padding: EdgeInsets.zero,
                ),
              ),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (actions != null) ...actions!,
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}

// ProgressCard: soft gradient with thin progress bar for light theme
class ProgressCard extends StatelessWidget {
  final int completed;
  final int total;
  final String? subtitle;

  const ProgressCard({
    super.key,
    required this.completed,
    required this.total,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? completed / total : 0.0;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: BRSpacing.md, vertical: BRSpacing.sm),
      padding: const EdgeInsets.all(BRSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [BRColors.primaryGradientStart, BRColors.primaryGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(BRRadius.large),
        boxShadow: BRShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: GoogleFonts.inter(
                  fontSize: BRTypography.h2Size,
                  fontWeight: BRTypography.h2Weight,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: BRSpacing.md,
                  vertical: BRSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(BRRadius.chip),
                ),
                child: Text(
                  '${(progress * 100).round()}%',
                  style: GoogleFonts.inter(
                    fontSize: BRTypography.bodySize,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: BRSpacing.lg),
          
          // Thin progress bar
          Container(
            width: double.infinity,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: BRSpacing.md),
          Text(
            subtitle ?? '$completed of $total steps completed',
            style: GoogleFonts.inter(
              fontSize: BRTypography.bodySize,
              fontWeight: BRTypography.bodyWeight,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

// PlanStepTile: redesigned for light theme with number avatar, title, and tiny premium pill
class PlanStepTile extends StatelessWidget {
  final int index;
  final String title;
  final bool isPremium;
  final bool isCompleted;
  final VoidCallback onTap;

  const PlanStepTile({
    super.key,
    required this.index,
    required this.title,
    this.isPremium = false,
    this.isCompleted = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedScale(
        scale: 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: BRSpacing.md,
            vertical: BRSpacing.xs,
          ),
          padding: const EdgeInsets.all(BRSpacing.lg),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(BRRadius.standard),
            boxShadow: BRShadows.card,
          ),
          child: Row(
            children: [
              // Number avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isCompleted 
                      ? BRColors.success 
                      : BRColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 20,
                        )
                      : Text(
                          '${index + 1}',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isCompleted 
                                ? Colors.white 
                                : BRColors.primary,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: BRSpacing.md),
              
              // Title and premium indicator
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: GoogleFonts.inter(
                              fontSize: BRTypography.titleSize,
                              fontWeight: FontWeight.w600,
                              color: isCompleted ? BRColors.textSecondary : BRColors.text,
                              decoration: isCompleted ? TextDecoration.lineThrough : null,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        
                        // Tiny Premium pill
                        if (isPremium) ...[
                          const SizedBox(width: BRSpacing.xs),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 10,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  'Premium',
                                  style: GoogleFonts.inter(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: BRSpacing.sm),
              
              // Chevron
              Icon(
                Icons.chevron_right_rounded,
                color: BRColors.textSecondary,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// JournalCard: mood emoji + title + snippet + right-aligned date
class JournalCard extends StatelessWidget {
  final String mood;
  final String title;
  final String snippet;
  final DateTime date;
  final VoidCallback onTap;

  const JournalCard({
    super.key,
    required this.mood,
    required this.title,
    required this.snippet,
    required this.date,
    required this.onTap,
  });

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return '${difference} days ago';
    
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: BRSpacing.md,
          vertical: BRSpacing.xs / 2,
        ),
        padding: const EdgeInsets.all(BRSpacing.md),
        decoration: BoxDecoration(
          color: BRColors.card,
          borderRadius: BorderRadius.circular(BRRadius.standard),
          boxShadow: BRShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  mood,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: BRSpacing.sm),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  _formatDate(date),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: BRSpacing.xs),
            Text(
              snippet,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// MoodChips: 5 emoji chips (terrible→great), single-select
class MoodChips extends StatefulWidget {
  final String? selectedMood;
  final ValueChanged<String> onMoodSelected;

  const MoodChips({
    super.key,
    this.selectedMood,
    required this.onMoodSelected,
  });

  @override
  State<MoodChips> createState() => _MoodChipsState();
}

class _MoodChipsState extends State<MoodChips> {
  static const moods = [
    {'emoji': '😢', 'label': 'Terrible'},
    {'emoji': '😔', 'label': 'Bad'},
    {'emoji': '😐', 'label': 'Okay'},
    {'emoji': '😊', 'label': 'Good'},
    {'emoji': '😍', 'label': 'Great'},
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: moods.map((mood) {
        final isSelected = widget.selectedMood == mood['label'];
        
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            widget.onMoodSelected(mood['label']!);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            padding: const EdgeInsets.symmetric(
              horizontal: BRSpacing.sm,
              vertical: BRSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: isSelected ? BRColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(BRRadius.chip),
              border: Border.all(
                color: isSelected ? BRColors.primary : BRColors.border,
                width: 1.5,
              ),
              boxShadow: isSelected ? [] : BRShadows.soft,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  mood['emoji']!,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(height: BRSpacing.xs / 2),
                Text(
                  mood['label']!,
                  style: GoogleFonts.inter(
                    fontSize: BRTypography.captionSize,
                    fontWeight: BRTypography.captionWeight,
                    color: isSelected ? Colors.white : BRColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ChatBubble: user (right, primary bubble) / coach (left, card bubble)
class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final DateTime timestamp;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isUser,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: BRSpacing.md,
        vertical: BRSpacing.xs / 2,
      ),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: BRColors.primary,
              child: const Icon(
                Icons.psychology_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: BRSpacing.xs),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(BRSpacing.sm),
              decoration: BoxDecoration(
                color: isUser ? BRColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(BRRadius.standard).copyWith(
                  bottomLeft: isUser ? const Radius.circular(BRRadius.standard) : Radius.zero,
                  bottomRight: isUser ? Radius.zero : const Radius.circular(BRRadius.standard),
                ),
                border: isUser ? null : Border.all(color: BRColors.border, width: 1.5),
                boxShadow: isUser ? [] : BRShadows.soft,
              ),
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isUser ? Colors.white : BRColors.text,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: BRSpacing.xs),
            CircleAvatar(
              radius: 16,
              backgroundColor: BRColors.success,
              child: const Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// BRTabBar: 4 tabs (Plan, Journal, Library, Coach) with pill highlight
class BRTabBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BRTabBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const tabs = [
    {'icon': Icons.track_changes_rounded, 'label': 'Plan'},
    {'icon': Icons.book_rounded, 'label': 'Journal'},
    {'icon': Icons.library_books_rounded, 'label': 'Library'},
    {'icon': Icons.psychology_rounded, 'label': 'Coach'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(BRSpacing.md),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(BRRadius.chip),
        boxShadow: BRShadows.card,
      ),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = index == currentIndex;
          
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onTap(index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                padding: const EdgeInsets.symmetric(
                  vertical: BRSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? BRColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(BRRadius.chip),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      tab['icon'] as IconData,
                      color: isSelected ? Colors.white : BRColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: BRSpacing.xs),
                    Text(
                      tab['label'] as String,
                      style: GoogleFonts.inter(
                        fontSize: BRTypography.bodySize,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected ? Colors.white : BRColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// Loading skeleton for cards
class SkeletonCard extends StatelessWidget {
  final double? width;
  final double height;

  const SkeletonCard({
    super.key,
    this.width,
    this.height = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.symmetric(
        horizontal: BRSpacing.md,
        vertical: BRSpacing.xs / 2,
      ),
      decoration: BoxDecoration(
        color: BRColors.card,
        borderRadius: BorderRadius.circular(BRRadius.standard),
        boxShadow: BRShadows.soft,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(BRRadius.standard),
          gradient: LinearGradient(
            colors: [
              BRColors.card,
              BRColors.border.withValues(alpha: 0.2),
              BRColors.card,
            ],
            stops: const [0.0, 0.5, 1.0],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }
}

// Empty state widget
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.buttonText,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(BRSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(BRSpacing.lg),
              margin: const EdgeInsets.all(BRSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(BRRadius.large),
                boxShadow: BRShadows.card,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: BRColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(BRRadius.standard),
                    ),
                    child: Icon(
                      icon,
                      color: BRColors.primary,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: BRSpacing.lg),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: BRSpacing.sm),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  if (buttonText != null && onButtonPressed != null) ...[
                    const SizedBox(height: BRSpacing.lg),
                    ElevatedButton(
                      onPressed: onButtonPressed,
                      child: Text(buttonText!),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}