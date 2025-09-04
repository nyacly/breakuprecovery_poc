import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:breakup_recovery/services/auth_service.dart';
import 'package:breakup_recovery/repositories/breakup_recovery_repository.dart';
import 'package:breakup_recovery/models/plan_step_model.dart';
import 'package:breakup_recovery/models/plan_model.dart';
import 'package:breakup_recovery/models/user_model.dart';
import 'package:breakup_recovery/models/resource_model.dart';
import 'package:breakup_recovery/screens/step_detail_screen.dart';
import 'package:breakup_recovery/screens/paywall_screen.dart';
import 'package:breakup_recovery/screens/onboarding_screen.dart';
import 'package:breakup_recovery/screens/big_five_intro_screen.dart';
import 'package:breakup_recovery/widgets/br_components.dart';
import 'package:breakup_recovery/theme.dart';

class PlanOverviewScreen extends StatefulWidget {
  const PlanOverviewScreen({super.key});

  @override
  State<PlanOverviewScreen> createState() => _PlanOverviewScreenState();
}

class _PlanOverviewScreenState extends State<PlanOverviewScreen> {
  final AuthService _authService = AuthService();
  final BreakupRecoveryRepository _repository = BreakupRecoveryRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BRColors.background,
      body: Column(
        children: [
          BRAppBar(
            title: 'Recovery Plan',
            showBack: false,
            actions: [
              IconButton(
                onPressed: () => _navigateToAssessment(),
                icon: const Icon(Icons.psychology_outlined),
                color: BRColors.text,
                tooltip: 'Personality Assessment',
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'logout') _handleLogout();
                },
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: BRColors.text,
                ),
                color: Colors.white,
                surfaceTintColor: Colors.transparent,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout_rounded, color: BRColors.textSecondary, size: 18),
                        const SizedBox(width: BRSpacing.xs),
                        Text(
                          'Sign Out',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: BRColors.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return FutureBuilder<UserModel?>(
      future: _repository.getCurrentUser(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        final user = userSnapshot.data;
        if (user?.activePlanId == null) {
          return EmptyState(
            icon: Icons.track_changes_rounded,
            title: 'No Active Plan',
            message: 'You don\'t have an active recovery plan yet. Create one to get started!',
            buttonText: 'Get Started',
            onButtonPressed: () => _createNewPlan(),
          );
        }

        return FutureBuilder<PlanModel?>(
          future: _repository.getCurrentPlan(),
          builder: (context, planSnapshot) {
            return StreamBuilder<List<PlanStepModel>>(
              stream: _repository.getPlanSteps(user!.activePlanId!),
              builder: (context, stepSnapshot) {
                if (stepSnapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingState();
                }

                if (!stepSnapshot.hasData || stepSnapshot.data!.isEmpty) {
                  return EmptyState(
                    icon: Icons.psychology_rounded,
                    title: 'No Steps Found',
                    message: 'Your recovery plan doesn\'t have any steps yet.',
                  );
                }

                final steps = stepSnapshot.data!;
                final plan = planSnapshot.data;
                final completedCount = plan?.completedStepIds.length ?? 0;

                return RefreshIndicator(
                  onRefresh: () async => setState(() {}),
                  color: BRColors.primary,
                  backgroundColor: Colors.white,
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            ProgressCard(
                              completed: completedCount,
                              total: steps.length,
                            ),
                            _buildRecommendedSection(user),
                          ],
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(vertical: BRSpacing.sm),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final step = steps[index];
                              return PlanStepTile(
                                index: step.index,
                                title: step.title,
                                isPremium: step.isPremium,
                                isCompleted: step.completed,
                                onTap: () => _handleStepTap(user, step),
                              );
                            },
                            childCount: steps.length,
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: BRSpacing.xl),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        const SkeletonCard(height: 160),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: BRSpacing.sm),
            itemCount: 7,
            itemBuilder: (context, index) => const SkeletonCard(height: 80),
          ),
        ),
      ],
    );
  }

  void _createNewPlan() async {
    try {
      await _repository.initializeNewUser();
      setState(() {}); // Refresh the UI
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recovery plan created successfully!'),
            backgroundColor: BRColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create plan: $e'),
            backgroundColor: BRColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _handleStepTap(UserModel user, PlanStepModel step) {
    HapticFeedback.lightImpact();
    
    // Check if step is premium and user is not premium
    if (step.isPremium && !user.isPremium) {
      _showPaywall();
      return;
    }

    // Navigate to step detail
    _navigateToStepDetail(user.uid, user.activePlanId!, step);
  }

  void _showPaywall() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PaywallScreen(),
      ),
    );
  }

  void _navigateToStepDetail(String userId, String planId, PlanStepModel step) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StepDetailScreen(
          userId: userId,
          planId: planId,
          step: step,
          onStepCompleted: (completed) => _handleStepCompletion(step.index, completed),
        ),
      ),
    );
  }

  void _handleStepCompletion(int stepIndex, bool completed) {
    _repository.completePlanStep(stepIndex, completed);
    // The UI will automatically refresh due to the StreamBuilder
  }

  Future<void> _handleLogout() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        (route) => false,
      );
    }
  }

  Widget _buildRecommendedSection(UserModel user) {
    return FutureBuilder<List<ResourceModel>>(
      future: _repository.getRecommendedResources(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final resources = snapshot.data!.take(3).toList();

        return Container(
          margin: const EdgeInsets.all(BRSpacing.md),
          padding: const EdgeInsets.all(BRSpacing.lg),
          decoration: BoxDecoration(
            color: BRColors.card,
            borderRadius: BorderRadius.circular(BRRadius.standard),
            boxShadow: BRShadows.card,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: BRColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: BRSpacing.xs),
                      Text(
                        'Recommended for You',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to Library tab
                      if (context.findAncestorWidgetOfExactType<Navigator>() != null) {
                        // Find the main navigation screen and switch to Library tab
                        final mainNavState = context.findAncestorStateOfType<State>();
                        if (mainNavState != null && mainNavState.mounted) {
                          // This would need the navigation callback, but for simplicity we'll use a simple approach
                        }
                      }
                    },
                    child: const Text('View All'),
                  ),
                ],
              ),
              
              const SizedBox(height: BRSpacing.md),
              
              ...resources.map((resource) => Container(
                margin: const EdgeInsets.only(bottom: BRSpacing.sm),
                child: InkWell(
                  onTap: () => _openResource(resource, user),
                  borderRadius: BorderRadius.circular(BRRadius.standard),
                  child: Container(
                    padding: const EdgeInsets.all(BRSpacing.sm),
                    decoration: BoxDecoration(
                      border: Border.all(color: BRColors.border, width: 1),
                      borderRadius: BorderRadius.circular(BRRadius.standard),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(resource.imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: BRSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                resource.title,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${resource.type.toUpperCase()} • ${resource.duration}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        if (resource.premium)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: BRColors.warning,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Premium',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        const SizedBox(width: BRSpacing.xs),
                        const Icon(
                          Icons.chevron_right,
                          color: BRColors.textSecondary,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              )).toList(),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openResource(ResourceModel resource, UserModel user) async {
    // Check premium access
    if (resource.premium && !user.isPremium) {
      _showPaywall();
      return;
    }

    // In a real app, this would open the resource content
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(resource.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(resource.summary),
            const SizedBox(height: 16),
            Text('Type: ${resource.type.toUpperCase()}'),
            Text('Duration: ${resource.duration}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _navigateToAssessment() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const BigFiveIntroScreen(),
      ),
    );
  }
}