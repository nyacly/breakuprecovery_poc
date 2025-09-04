import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:breakup_recovery/widgets/br_components.dart';
import 'package:breakup_recovery/theme.dart';

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BRColors.background,
      body: Column(
        children: [
          BRAppBar(
            title: 'Upgrade to Premium',
            onBack: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(BRSpacing.lg),
              child: Column(
                children: [
                  _buildHeroSection(context),
                  const SizedBox(height: BRSpacing.xl),
                  _buildFeaturesList(context),
                  const SizedBox(height: BRSpacing.xl),
                  _buildPricingCard(context),
                  const SizedBox(height: BRSpacing.lg),
                  _buildCTAButtons(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
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
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(BRRadius.standard),
            ),
            child: const Icon(
              Icons.star_rounded,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: BRSpacing.lg),
          Text(
            'Unlock Your Full Recovery',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: BRSpacing.sm),
          Text(
            'Get access to advanced recovery techniques and personalized coaching',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesList(BuildContext context) {
    final features = [
      {
        'icon': Icons.psychology_rounded,
        'title': 'Advanced Emotional Regulation',
        'description': 'Learn proven techniques to manage complex emotions'
      },
      {
        'icon': Icons.favorite_rounded,
        'title': 'Future Relationship Planning',
        'description': 'Prepare for healthier relationships in the future'
      },
      {
        'icon': Icons.chat_rounded,
        'title': 'Unlimited Coach Access',
        'description': 'Get personalized support whenever you need it'
      },
      {
        'icon': Icons.insights_rounded,
        'title': 'Advanced Progress Insights',
        'description': 'Track your healing journey with detailed analytics'
      },
    ];

    return Column(
      children: features
          .map((feature) => _buildFeatureItem(
                context,
                feature['icon'] as IconData,
                feature['title'] as String,
                feature['description'] as String,
              ))
          .toList(),
    );
  }

  Widget _buildFeatureItem(BuildContext context, IconData icon, String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: BRSpacing.md),
      padding: const EdgeInsets.all(BRSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(BRRadius.standard),
        boxShadow: BRShadows.soft,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: BRColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(BRRadius.standard),
            ),
            child: Icon(
              icon,
              color: BRColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: BRSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: BRSpacing.xs),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(BRSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(BRRadius.large),
        boxShadow: BRShadows.card,
        border: Border.all(color: BRColors.primary, width: 2),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: BRSpacing.md,
              vertical: BRSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: BRColors.success,
              borderRadius: BorderRadius.circular(BRRadius.chip),
            ),
            child: Text(
              'MOST POPULAR',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: BRSpacing.lg),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '\$9.99',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: BRColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: '/month',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: BRColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: BRSpacing.sm),
          Text(
            'Cancel anytime • 7-day free trial',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: BRColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCTAButtons(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            boxShadow: BRShadows.button,
          ),
          child: ElevatedButton(
            onPressed: () => _handleStartTrial(context),
            child: const Text('Start 7-Day Free Trial'),
          ),
        ),
        const SizedBox(height: BRSpacing.md),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Maybe Later'),
        ),
      ],
    );
  }

  void _handleStartTrial(BuildContext context) {
    HapticFeedback.lightImpact();
    
    // TODO: Implement subscription logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Premium subscription coming soon!'),
        backgroundColor: BRColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}