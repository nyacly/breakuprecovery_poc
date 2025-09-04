import 'package:flutter/material.dart';
import 'package:breakup_recovery/widgets/br_components.dart';
import 'package:breakup_recovery/theme.dart';
import 'package:breakup_recovery/screens/big_five_assessment_screen.dart';

class BigFiveIntroScreen extends StatelessWidget {
  const BigFiveIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BRColors.background,
      appBar: const BRAppBar(title: 'Personality Assessment'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(BRSpacing.md),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: BRSpacing.lg),
                      
                      // Hero section
                      Container(
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
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: BRColors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.psychology_outlined,
                                    color: BRColors.primary,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: BRSpacing.sm),
                                Expanded(
                                  child: Text(
                                    'Know Yourself Better',
                                    style: Theme.of(context).textTheme.headlineSmall,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: BRSpacing.md),
                            Text(
                              'Understanding your personality helps us personalize your recovery journey with resources and strategies that work best for you.',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: BRSpacing.xl),
                      
                      // What to expect section
                      Text(
                        'What to Expect',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: BRSpacing.md),
                      
                      _buildExpectationItem(
                        context,
                        icon: Icons.quiz_outlined,
                        title: '20 Quick Questions',
                        description: 'Each question takes just a few seconds to answer',
                      ),
                      const SizedBox(height: BRSpacing.md),
                      
                      _buildExpectationItem(
                        context,
                        icon: Icons.schedule_outlined,
                        title: '5 Minutes Total',
                        description: 'The entire assessment is designed to be quick and easy',
                      ),
                      const SizedBox(height: BRSpacing.md),
                      
                      _buildExpectationItem(
                        context,
                        icon: Icons.insights_outlined,
                        title: 'Personalized Results',
                        description: 'Get insights into your personality traits and tailored recommendations',
                      ),
                      
                      const SizedBox(height: BRSpacing.xl),
                      
                      // Privacy note
                      Container(
                        padding: const EdgeInsets.all(BRSpacing.md),
                        decoration: BoxDecoration(
                          color: BRColors.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(BRRadius.standard),
                          border: Border.all(
                            color: BRColors.primary.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.lock_outline,
                              color: BRColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: BRSpacing.sm),
                            Expanded(
                              child: Text(
                                'Your responses are completely private and used only to personalize your experience.',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: BRColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: BRSpacing.lg),
              
              // Start button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const BigFiveAssessmentScreen(),
                      ),
                    );
                  },
                  child: const Text('Start Assessment'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpectationItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: BRColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: BRColors.success,
            size: 20,
          ),
        ),
        const SizedBox(width: BRSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 16,
                ),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}