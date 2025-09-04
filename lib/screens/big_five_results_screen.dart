import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:breakup_recovery/widgets/br_components.dart';
import 'package:breakup_recovery/theme.dart';

class BigFiveResultsScreen extends StatelessWidget {
  final Map<String, int> scores;

  const BigFiveResultsScreen({
    super.key,
    required this.scores,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BRColors.background,
      appBar: const BRAppBar(
        title: 'Your Personality Profile',
        showBack: false,
      ),
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
                      
                      // Congratulations header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(BRSpacing.lg),
                        decoration: BoxDecoration(
                          color: BRColors.card,
                          borderRadius: BorderRadius.circular(BRRadius.standard),
                          boxShadow: BRShadows.card,
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: BRColors.success.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(32),
                              ),
                              child: const Icon(
                                Icons.celebration,
                                color: BRColors.success,
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: BRSpacing.md),
                            Text(
                              'Profile Complete!',
                              style: Theme.of(context).textTheme.headlineSmall,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: BRSpacing.xs),
                            Text(
                              'Here\'s your personality breakdown based on the Big Five model.',
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: BRSpacing.xl),
                      
                      Text(
                        'Your Traits',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: BRSpacing.md),
                      
                      // Trait scores
                      _buildTraitCard(
                        context,
                        'Openness',
                        'O',
                        scores['O'] ?? 0,
                        'How open you are to new experiences and ideas',
                        Icons.lightbulb_outline,
                        Colors.purple,
                      ),
                      const SizedBox(height: BRSpacing.md),
                      
                      _buildTraitCard(
                        context,
                        'Conscientiousness',
                        'C',
                        scores['C'] ?? 0,
                        'How organized and self-disciplined you are',
                        Icons.check_circle_outline,
                        Colors.blue,
                      ),
                      const SizedBox(height: BRSpacing.md),
                      
                      _buildTraitCard(
                        context,
                        'Extraversion',
                        'E',
                        scores['E'] ?? 0,
                        'How outgoing and energetic you are',
                        Icons.people_outline,
                        Colors.orange,
                      ),
                      const SizedBox(height: BRSpacing.md),
                      
                      _buildTraitCard(
                        context,
                        'Agreeableness',
                        'A',
                        scores['A'] ?? 0,
                        'How cooperative and trusting you are',
                        Icons.favorite_outline,
                        Colors.green,
                      ),
                      const SizedBox(height: BRSpacing.md),
                      
                      _buildTraitCard(
                        context,
                        'Neuroticism',
                        'N',
                        scores['N'] ?? 0,
                        'How sensitive you are to stress',
                        Icons.psychology_outlined,
                        Colors.red,
                      ),
                      
                      const SizedBox(height: BRSpacing.xl),
                      
                      // What's next section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(BRSpacing.lg),
                        decoration: BoxDecoration(
                          color: BRColors.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(BRRadius.standard),
                          border: Border.all(
                            color: BRColors.primary.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                  'What\'s Next?',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: BRColors.primary,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: BRSpacing.sm),
                            Text(
                              'Your recovery plan is now personalized based on your personality traits. You\'ll see custom recommendations in your Library and targeted resources throughout the app.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: BRColors.primary,
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
              
              // Continue button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text('Continue to Plan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTraitCard(
    BuildContext context,
    String traitName,
    String traitCode,
    int score,
    String description,
    IconData icon,
    Color color,
  ) {
    final percentage = (score / 20 * 100).round();
    final level = score >= 12 ? 'High' : score >= 8 ? 'Medium' : 'Low';
    
    return Container(
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: BRSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      traitName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '$level ($percentage%)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: BRSpacing.md),
          
          // Progress bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: BRColors.border,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: score / 20,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: BRSpacing.sm),
          
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}