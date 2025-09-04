import 'package:firebase_auth/firebase_auth.dart';
import 'package:breakup_recovery/models/user_model.dart';
import 'package:breakup_recovery/models/plan_model.dart';
import 'package:breakup_recovery/models/plan_step_model.dart';
import 'package:breakup_recovery/models/chat_message_model.dart';
import 'package:breakup_recovery/models/journal_entry_model.dart';
import 'package:breakup_recovery/models/big_five_question_model.dart';
import 'package:breakup_recovery/models/big_five_profile_model.dart';
import 'package:breakup_recovery/models/resource_model.dart';
import 'package:breakup_recovery/services/firestore_service.dart';

/// Repository implementing business logic for the Breakup Recovery app
/// Follows repository pattern to abstract Firestore operations
class BreakupRecoveryRepository {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // Authentication helpers
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  bool get isAuthenticated => _auth.currentUser != null;

  // User operations
  Future<UserModel?> getCurrentUser() async {
    final userId = currentUserId;
    if (userId == null) return null;
    return await _firestoreService.getUser(userId);
  }

  /// Initialize a new user with default settings and create their first recovery plan
  Future<UserModel> initializeNewUser() async {
    final userId = currentUserId;
    if (userId == null) throw Exception('User not authenticated');

    // Check if user already exists
    final existingUser = await _firestoreService.getUser(userId);
    if (existingUser != null) return existingUser;

    // Create new user document with required fields
    final newUser = UserModel(
      uid: userId,
      displayName: _auth.currentUser?.displayName ?? 'Recovery Warrior',
      locale: 'en',
      isPremium: false,
      activePlanId: null, // Will be set after creating plan
      traits: [],
    );
    
    await _firestoreService.createOrUpdateUser(userId, newUser);

    // Create the initial recovery plan
    final planId = await seedPlan(userId);
    
    // Update user with the active plan ID
    final updatedUser = newUser.copyWith(activePlanId: planId);
    await _firestoreService.createOrUpdateUser(userId, updatedUser);

    return updatedUser;
  }

  /// Seed the initial recovery plan with 7 steps (6-7 are premium)
  Future<String> seedPlan(String userId) async {
    const planId = 'plan_01';
    
    // Create plan document
    await _firestoreService.createPlanWithId(userId, planId);
    
    // Define the 7 recovery plan steps
    final planSteps = [
      PlanStepModel(
        index: 0,
        title: 'Understanding Your Emotions',
        isPremium: false,
        completed: false,
        createdAt: DateTime.now(),
      ),
      PlanStepModel(
        index: 1,
        title: 'Building a Support Network',
        isPremium: false,
        completed: false,
        createdAt: DateTime.now(),
      ),
      PlanStepModel(
        index: 2,
        title: 'Developing Self-Care Routines',
        isPremium: false,
        completed: false,
        createdAt: DateTime.now(),
      ),
      PlanStepModel(
        index: 3,
        title: 'Processing Grief and Loss',
        isPremium: false,
        completed: false,
        createdAt: DateTime.now(),
      ),
      PlanStepModel(
        index: 4,
        title: 'Rediscovering Your Identity',
        isPremium: false,
        completed: false,
        createdAt: DateTime.now(),
      ),
      PlanStepModel(
        index: 5,
        title: 'Advanced Emotional Regulation',
        isPremium: true, // Premium step
        completed: false,
        createdAt: DateTime.now(),
      ),
      PlanStepModel(
        index: 6,
        title: 'Future Relationship Planning',
        isPremium: true, // Premium step
        completed: false,
        createdAt: DateTime.now(),
      ),
    ];

    // Create all plan steps
    for (final step in planSteps) {
      await _firestoreService.createPlanStep(userId, planId, step);
    }

    return planId;
  }

  Future<void> updateUserProfile(UserModel user) async {
    final userId = currentUserId;
    if (userId == null) return;
    await _firestoreService.createOrUpdateUser(userId, user);
  }

  // Plan operations
  Future<String?> createRecoveryPlan() async {
    final userId = currentUserId;
    if (userId == null) return null;
    
    try {
      final planId = await _firestoreService.createPlan(userId);
      return planId;
    } catch (e) {
      throw Exception('Failed to create recovery plan: $e');
    }
  }

  Stream<List<PlanStepModel>> getPlanSteps([String? planId]) {
    final userId = currentUserId;
    if (userId == null) return Stream.value([]);
    
    // If no planId provided, get from user's active plan
    if (planId == null) {
      return getCurrentUser().asStream().asyncExpand((user) {
        if (user?.activePlanId != null) {
          return _firestoreService.getPlanSteps(userId, user!.activePlanId!);
        }
        return Stream.value(<PlanStepModel>[]);
      });
    }
    
    return _firestoreService.getPlanSteps(userId, planId);
  }

  Future<void> completePlanStep(int stepIndex, bool completed, [String? planId]) async {
    final userId = currentUserId;
    if (userId == null) return;

    if (planId == null) {
      final user = await getCurrentUser();
      planId = user?.activePlanId;
    }

    if (planId != null) {
      // Update the step completion status
      await _firestoreService.updatePlanStep(userId, planId, stepIndex, completed);
      
      // Update the plan's completedStepIds
      await _updatePlanCompletionStatus(userId, planId, stepIndex, completed);
    }
  }

  Future<void> _updatePlanCompletionStatus(String userId, String planId, int stepIndex, bool completed) async {
    final plan = await _firestoreService.getPlan(userId, planId);
    if (plan == null) return;

    final currentCompletedIds = List<int>.from(plan.completedStepIds);
    
    if (completed && !currentCompletedIds.contains(stepIndex)) {
      currentCompletedIds.add(stepIndex);
    } else if (!completed && currentCompletedIds.contains(stepIndex)) {
      currentCompletedIds.remove(stepIndex);
    }

    final updatedPlan = plan.copyWith(completedStepIds: currentCompletedIds);
    await _firestoreService.updatePlan(userId, planId, updatedPlan);
  }

  Future<PlanModel?> getCurrentPlan() async {
    final userId = currentUserId;
    if (userId == null) return null;

    final user = await getCurrentUser();
    if (user?.activePlanId == null) return null;

    return await _firestoreService.getPlan(userId, user!.activePlanId!);
  }

  // Journal operations
  Future<String?> createJournalEntry(String title, String body, Mood mood) async {
    final userId = currentUserId;
    if (userId == null) return null;

    try {
      final entry = JournalEntryModel(
        id: '', // Will be set by Firestore
        title: title,
        body: body,
        mood: mood,
        createdAt: DateTime.now(),
      );
      return await _firestoreService.createJournalEntry(userId, entry);
    } catch (e) {
      throw Exception('Failed to create journal entry: $e');
    }
  }

  Stream<List<JournalEntryModel>> getJournalEntries() {
    final userId = currentUserId;
    if (userId == null) return Stream.value([]);
    return _firestoreService.getJournalEntries(userId);
  }

  Future<void> updateJournalEntry(JournalEntryModel entry) async {
    final userId = currentUserId;
    if (userId == null) return;
    await _firestoreService.updateJournalEntry(userId, entry);
  }

  Future<void> deleteJournalEntry(String entryId) async {
    final userId = currentUserId;
    if (userId == null) return;
    await _firestoreService.deleteJournalEntry(userId, entryId);
  }

  // Chat operations
  Future<String?> sendChatMessage(String message, [String? threadId]) async {
    final userId = currentUserId;
    if (userId == null) return null;

    try {
      // Use default thread if none provided
      threadId ??= 'default';
      
      final chatMessage = ChatMessageModel(
        id: '', // Will be set by Firestore
        role: MessageRole.user,
        text: message,
        createdAt: DateTime.now(),
      );
      
      await _firestoreService.sendChatMessage(userId, threadId, chatMessage);
      
      // Simulate coach response (in real app, this would call AI service)
      await _simulateCoachResponse(userId, threadId, message);
      
      return threadId;
    } catch (e) {
      throw Exception('Failed to send chat message: $e');
    }
  }

  Stream<List<ChatMessageModel>> getChatMessages([String? threadId]) {
    final userId = currentUserId;
    if (userId == null) return Stream.value([]);
    
    threadId ??= 'default';
    return _firestoreService.getChatMessages(userId, threadId);
  }

  // Helper method to simulate coach responses
  Future<void> _simulateCoachResponse(String userId, String threadId, String userMessage) async {
    // Simple response logic - in production, this would call an AI service
    await Future.delayed(const Duration(seconds: 2));
    
    String response = _getCoachResponse(userMessage);
    
    final coachMessage = ChatMessageModel(
      id: '', // Will be set by Firestore
      role: MessageRole.coach,
      text: response,
      createdAt: DateTime.now(),
    );
    
    await _firestoreService.sendChatMessage(userId, threadId, coachMessage);
  }

  String _getCoachResponse(String userMessage) {
    final message = userMessage.toLowerCase();
    
    if (message.contains('sad') || message.contains('hurt')) {
      return "I understand you're going through a difficult time. It's completely normal to feel sad after a breakup. Remember that healing takes time, and it's important to be gentle with yourself.";
    } else if (message.contains('angry') || message.contains('mad')) {
      return "Anger is a natural part of the healing process. Try channeling that energy into something positive like exercise, creative activities, or journaling about your feelings.";
    } else if (message.contains('lonely')) {
      return "Loneliness after a breakup is very common. Consider reaching out to friends or family, or try engaging in activities you enjoy. You're not alone in this journey.";
    } else if (message.contains('better') || message.contains('good')) {
      return "I'm glad to hear you're feeling better! That's a positive sign of your healing progress. Keep focusing on self-care and the activities that bring you joy.";
    } else {
      return "Thank you for sharing that with me. Remember that every step forward, no matter how small, is progress. How are you taking care of yourself today?";
    }
  }

  // Big Five Assessment operations
  Future<List<BigFiveQuestionModel>> getBigFiveQuestions() async {
    return await _firestoreService.getBigFiveQuestions();
  }

  Future<String?> saveBigFiveProfile(Map<String, int> scores, int itemCount) async {
    final userId = currentUserId;
    if (userId == null) return null;

    try {
      final profile = BigFiveProfileModel(
        id: '', // Will be set by Firestore
        scores: scores,
        createdAt: DateTime.now(),
        itemCount: itemCount,
      );
      
      final profileId = await _firestoreService.saveBigFiveProfile(userId, profile);
      
      // Update user traits with top 2 personality traits
      final user = await getCurrentUser();
      if (user != null) {
        final updatedProfile = profile.copyWith();
        final topTraits = updatedProfile.getTopTraits();
        final updatedUser = user.copyWith(traits: topTraits);
        await _firestoreService.createOrUpdateUser(userId, updatedUser);
      }
      
      return profileId;
    } catch (e) {
      throw Exception('Failed to save Big Five profile: $e');
    }
  }

  Future<BigFiveProfileModel?> getLatestBigFiveProfile() async {
    final userId = currentUserId;
    if (userId == null) return null;
    return await _firestoreService.getLatestBigFiveProfile(userId);
  }

  // Library/Resources operations
  Future<List<ResourceModel>> getResources({String? type, List<String>? tags}) async {
    return await _firestoreService.getResources(type: type, tags: tags);
  }

  Future<List<ResourceModel>> getRecommendedResources() async {
    final user = await getCurrentUser();
    List<String>? userTraits;
    
    if (user?.traits.isNotEmpty == true) {
      // Use user's personality traits to filter resources
      userTraits = user!.traits;
    }
    
    return await _firestoreService.getRecommendedResources(userTraits);
  }

  Future<ResourceModel?> getResource(String resourceId) async {
    return await _firestoreService.getResource(resourceId);
  }

  /// Seed Big Five questions data - call this once to initialize the database
  Future<void> seedBigFiveQuestions() async {
    final questions = [
      // Openness (O)
      BigFiveQuestionModel(id: 'q1', trait: 'O', text: 'I have a vivid imagination.', reverse: false, order: 1),
      BigFiveQuestionModel(id: 'q2', trait: 'O', text: 'I enjoy hearing new ideas.', reverse: false, order: 5),
      BigFiveQuestionModel(id: 'q3', trait: 'O', text: 'I prefer routine over variety.', reverse: true, order: 9),
      BigFiveQuestionModel(id: 'q4', trait: 'O', text: 'I am interested in many different kinds of things.', reverse: false, order: 13),
      
      // Conscientiousness (C)
      BigFiveQuestionModel(id: 'q5', trait: 'C', text: 'I am always prepared.', reverse: false, order: 2),
      BigFiveQuestionModel(id: 'q6', trait: 'C', text: 'I pay attention to details.', reverse: false, order: 6),
      BigFiveQuestionModel(id: 'q7', trait: 'C', text: 'I often leave things to the last minute.', reverse: true, order: 10),
      BigFiveQuestionModel(id: 'q8', trait: 'C', text: 'I like to have everything in its proper place.', reverse: false, order: 14),
      
      // Extraversion (E)
      BigFiveQuestionModel(id: 'q9', trait: 'E', text: 'I am the life of the party.', reverse: false, order: 3),
      BigFiveQuestionModel(id: 'q10', trait: 'E', text: 'I enjoy being the center of attention.', reverse: false, order: 7),
      BigFiveQuestionModel(id: 'q11', trait: 'E', text: 'I prefer to keep to myself.', reverse: true, order: 11),
      BigFiveQuestionModel(id: 'q12', trait: 'E', text: 'I make friends easily.', reverse: false, order: 15),
      
      // Agreeableness (A)  
      BigFiveQuestionModel(id: 'q13', trait: 'A', text: 'I sympathize with others\' feelings.', reverse: false, order: 4),
      BigFiveQuestionModel(id: 'q14', trait: 'A', text: 'I am interested in other people.', reverse: false, order: 8),
      BigFiveQuestionModel(id: 'q15', trait: 'A', text: 'I am not really interested in others.', reverse: true, order: 12),
      BigFiveQuestionModel(id: 'q16', trait: 'A', text: 'I trust what people say.', reverse: false, order: 16),
      
      // Neuroticism (N)
      BigFiveQuestionModel(id: 'q17', trait: 'N', text: 'I get stressed out easily.', reverse: false, order: 17),
      BigFiveQuestionModel(id: 'q18', trait: 'N', text: 'I worry about things.', reverse: false, order: 18),
      BigFiveQuestionModel(id: 'q19', trait: 'N', text: 'I am relaxed most of the time.', reverse: true, order: 19),
      BigFiveQuestionModel(id: 'q20', trait: 'N', text: 'I seldom feel blue.', reverse: true, order: 20),
    ];
    
    await _firestoreService.seedBigFiveQuestions(questions);
  }

  /// Seed resources data - call this once to initialize the database
  Future<void> seedResources() async {
    final resources = [
      ResourceModel(
        id: 'r1', 
        type: 'meditation',
        title: 'Healing Heart Meditation', 
        summary: 'A gentle meditation to heal emotional wounds and find inner peace',
        imageUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400',
        url: '#', 
        duration: '15 min',
        tags: ['Low N', 'High A'],
        premium: false, 
        createdAt: DateTime.now(),
      ),
      ResourceModel(
        id: 'r2',
        type: 'audio',
        title: 'Moving Forward: Self-Compassion Talk',
        summary: 'Learn to be kind to yourself during difficult transitions',
        imageUrl: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400',
        url: '#',
        duration: '22 min',
        tags: ['High N', 'Low E'],
        premium: false,
        createdAt: DateTime.now(),
      ),
      ResourceModel(
        id: 'r3',
        type: 'article',
        title: 'Understanding Your Attachment Style',
        summary: 'Discover how your attachment style affects your relationships',
        imageUrl: 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=400',
        url: '#',
        duration: '8 min read',
        tags: ['High O', 'Low A'],
        premium: true,
        createdAt: DateTime.now(),
      ),
      ResourceModel(
        id: 'r4',
        type: 'exercise',
        title: 'Energy Release Workout',
        summary: 'Physical exercises to release emotional tension and boost mood',
        imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
        url: '#',
        duration: '30 min',
        tags: ['High E', 'High C'],
        premium: false,
        createdAt: DateTime.now(),
      ),
      ResourceModel(
        id: 'r5',
        type: 'meditation',
        title: 'Self-Love Visualization',
        summary: 'A powerful visualization to reconnect with your self-worth',
        imageUrl: 'https://images.unsplash.com/photo-1552196563-55cd4e45efb3?w=400',
        url: '#',
        duration: '20 min',
        tags: ['Low A', 'High N'],
        premium: true,
        createdAt: DateTime.now(),
      ),
      ResourceModel(
        id: 'r6',
        type: 'article',
        title: 'Building Emotional Resilience',
        summary: 'Evidence-based strategies for bouncing back from setbacks',
        imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
        url: '#',
        duration: '12 min read',
        tags: ['High C', 'Low N'],
        premium: false,
        createdAt: DateTime.now(),
      ),
      ResourceModel(
        id: 'r7',
        type: 'audio',
        title: 'Sleep Stories for Healing',
        summary: 'Calming bedtime stories to help you rest and recover',
        imageUrl: 'https://images.unsplash.com/photo-1541781774459-bb2af2f05b55?w=400',
        url: '#',
        duration: '45 min',
        tags: ['High N', 'Low E'],
        premium: true,
        createdAt: DateTime.now(),
      ),
      ResourceModel(
        id: 'r8',
        type: 'exercise',
        title: 'Confidence Building Activities',
        summary: 'Daily practices to rebuild your self-confidence and esteem',
        imageUrl: 'https://images.unsplash.com/photo-1551698618-1dfe5d97d256?w=400',
        url: '#',
        duration: '15 min daily',
        tags: ['Low E', 'High C'],
        premium: false,
        createdAt: DateTime.now(),
      ),
    ];
    
    await _firestoreService.seedResources(resources);
  }

}