import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:breakup_recovery/widgets/br_components.dart';
import 'package:breakup_recovery/theme.dart';
import 'package:breakup_recovery/models/big_five_question_model.dart';
import 'package:breakup_recovery/repositories/breakup_recovery_repository.dart';
import 'package:breakup_recovery/screens/big_five_results_screen.dart';

class BigFiveAssessmentScreen extends StatefulWidget {
  const BigFiveAssessmentScreen({super.key});

  @override
  State<BigFiveAssessmentScreen> createState() => _BigFiveAssessmentScreenState();
}

class _BigFiveAssessmentScreenState extends State<BigFiveAssessmentScreen> {
  final BreakupRecoveryRepository _repository = BreakupRecoveryRepository();
  final PageController _pageController = PageController();
  
  List<BigFiveQuestionModel> _questions = [];
  Map<String, int> _answers = {};
  int _currentQuestionIndex = 0;
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final questions = await _repository.getBigFiveQuestions();
      if (questions.isEmpty) {
        // Seed questions if none exist
        await _repository.seedBigFiveQuestions();
        final seededQuestions = await _repository.getBigFiveQuestions();
        setState(() {
          _questions = seededQuestions;
          _isLoading = false;
        });
      } else {
        setState(() {
          _questions = questions;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading questions: $e')),
        );
      }
    }
  }

  void _answerQuestion(int rating) {
    HapticFeedback.lightImpact();
    setState(() {
      _answers[_questions[_currentQuestionIndex].id] = rating;
    });

    // Auto-advance to next question after a brief delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_currentQuestionIndex < _questions.length - 1) {
        _nextQuestion();
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() => _currentQuestionIndex++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() => _currentQuestionIndex--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submitAssessment() async {
    if (_isSubmitting) return;
    
    setState(() => _isSubmitting = true);
    
    try {
      // Calculate scores for each trait
      final scores = _calculateScores();
      
      // Save to Firestore
      await _repository.saveBigFiveProfile(scores, _questions.length);
      
      HapticFeedback.heavyImpact();
      
      // Navigate to results
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => BigFiveResultsScreen(scores: scores),
          ),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving results: $e')),
        );
      }
    }
  }

  Map<String, int> _calculateScores() {
    final traitScores = {'O': 0, 'C': 0, 'E': 0, 'A': 0, 'N': 0};
    
    for (final question in _questions) {
      final answer = _answers[question.id];
      if (answer != null) {
        final score = question.reverse ? (6 - answer) : answer;
        traitScores[question.trait] = (traitScores[question.trait] ?? 0) + score;
      }
    }
    
    return traitScores;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: BRColors.background,
        appBar: const BRAppBar(title: 'Loading Assessment...', showBack: false),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: BRColors.background,
        appBar: const BRAppBar(title: 'Assessment'),
        body: const Center(
          child: Text('No questions available. Please try again later.'),
        ),
      );
    }

    final currentQuestion = _questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _questions.length;
    final isLastQuestion = _currentQuestionIndex == _questions.length - 1;
    final hasAnswer = _answers.containsKey(currentQuestion.id);

    return Scaffold(
      backgroundColor: BRColors.background,
      appBar: BRAppBar(
        title: 'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
        onBack: _currentQuestionIndex > 0 ? _previousQuestion : null,
        showBack: _currentQuestionIndex > 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Container(
              padding: const EdgeInsets.all(BRSpacing.md),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        '${(progress * 100).round()}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: BRColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: BRSpacing.xs),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: BRColors.border,
                    valueColor: const AlwaysStoppedAnimation<Color>(BRColors.primary),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _questions.length,
                onPageChanged: (index) {
                  setState(() => _currentQuestionIndex = index);
                },
                itemBuilder: (context, index) {
                  final question = _questions[index];
                  return Padding(
                    padding: const EdgeInsets.all(BRSpacing.md),
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(BRSpacing.xl),
                            decoration: BoxDecoration(
                              color: BRColors.card,
                              borderRadius: BorderRadius.circular(BRRadius.standard),
                              boxShadow: BRShadows.card,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.help_outline,
                                  color: BRColors.primary,
                                  size: 48,
                                ),
                                const SizedBox(height: BRSpacing.xl),
                                
                                Text(
                                  question.text,
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    height: 1.4,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                
                                const SizedBox(height: BRSpacing.xl),
                                
                                Text(
                                  'How much do you agree?',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: BRSpacing.lg),
                        
                        // Rating scale
                        Container(
                          padding: const EdgeInsets.all(BRSpacing.lg),
                          decoration: BoxDecoration(
                            color: BRColors.card,
                            borderRadius: BorderRadius.circular(BRRadius.standard),
                            boxShadow: BRShadows.card,
                          ),
                          child: Column(
                            children: [
                              // Labels
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Strongly\nDisagree',
                                    style: Theme.of(context).textTheme.bodySmall,
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    'Neutral',
                                    style: Theme.of(context).textTheme.bodySmall,
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    'Strongly\nAgree',
                                    style: Theme.of(context).textTheme.bodySmall,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: BRSpacing.md),
                              
                              // Rating buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: List.generate(5, (index) {
                                  final rating = index + 1;
                                  final isSelected = _answers[question.id] == rating;
                                  
                                  return GestureDetector(
                                    onTap: () => _answerQuestion(rating),
                                    child: Container(
                                      width: 52,
                                      height: 52,
                                      decoration: BoxDecoration(
                                        color: isSelected 
                                            ? BRColors.primary 
                                            : BRColors.background,
                                        border: Border.all(
                                          color: isSelected 
                                              ? BRColors.primary 
                                              : BRColors.border,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(26),
                                      ),
                                      child: Center(
                                        child: Text(
                                          rating.toString(),
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            color: isSelected 
                                                ? Colors.white 
                                                : BRColors.text,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Navigation buttons
            Container(
              padding: const EdgeInsets.all(BRSpacing.md),
              child: Row(
                children: [
                  if (_currentQuestionIndex > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousQuestion,
                        child: const Text('Previous'),
                      ),
                    ),
                  
                  if (_currentQuestionIndex > 0)
                    const SizedBox(width: BRSpacing.md),
                  
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: hasAnswer ? (isLastQuestion ? _submitAssessment : _nextQuestion) : null,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(isLastQuestion ? 'Get Results' : 'Next'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}