import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:breakup_recovery/models/plan_model.dart';
import 'package:breakup_recovery/models/plan_step_model.dart';
import 'package:breakup_recovery/models/chat_message_model.dart';
import 'package:breakup_recovery/models/journal_entry_model.dart';
import 'package:breakup_recovery/models/user_model.dart';
import 'package:breakup_recovery/models/big_five_question_model.dart';
import 'package:breakup_recovery/models/big_five_profile_model.dart';
import 'package:breakup_recovery/models/resource_model.dart';
import 'package:breakup_recovery/firestore/firestore_data_schema.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Plan operations
  Future<String> createPlan(String userId) async {
    final planRef = FirestoreSchema.userPlans(userId).doc();
    final plan = PlanModel(id: planRef.id, createdAt: DateTime.now());
    await planRef.set(plan.toJson());
    
    // Update user's activePlanId
    await FirestoreSchema.userDoc(userId).update({
      FirestoreSchema.userActivePlanId: planRef.id
    });
    
    // Create default plan steps
    await _createDefaultPlanSteps(userId, planRef.id);
    
    return planRef.id;
  }

  Future<String> createPlanWithId(String userId, String planId) async {
    final planRef = FirestoreSchema.userPlans(userId).doc(planId);
    final plan = PlanModel(id: planId, createdAt: DateTime.now());
    await planRef.set(plan.toJson());
    return planId;
  }

  Future<void> createPlanStep(String userId, String planId, PlanStepModel step) async {
    final stepRef = FirestoreSchema.planSteps(userId, planId).doc(step.index.toString());
    await stepRef.set(step.toJson());
  }

  Future<PlanModel?> getPlan(String userId, String planId) async {
    final doc = await FirestoreSchema.userPlans(userId).doc(planId).get();
    if (doc.exists && doc.data() != null) {
      return PlanModel.fromJson(planId, doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> updatePlan(String userId, String planId, PlanModel plan) async {
    await FirestoreSchema.userPlans(userId).doc(planId).update(plan.toJson());
  }

  Future<void> _createDefaultPlanSteps(String userId, String planId) async {
    final steps = [
      'Accept and acknowledge your feelings',
      'Remove reminders and triggers',
      'Focus on self-care and well-being',
      'Reconnect with friends and family',
      'Explore new hobbies and interests',
      'Practice mindfulness and meditation',
      'Set goals for your future self',
    ];

    final batch = _firestore.batch();
    for (int i = 0; i < steps.length; i++) {
      final stepRef = FirestoreSchema.planSteps(userId, planId).doc(i.toString());

      final step = PlanStepModel(
        title: steps[i],
        index: i,
        isPremium: i >= 5,
        completed: false,
        createdAt: DateTime.now(),
      );

      batch.set(stepRef, step.toJson());
    }
    await batch.commit();
  }

  Stream<List<PlanStepModel>> getPlanSteps(String userId, String planId) {
    return FirestoreSchema.planSteps(userId, planId)
        .orderBy(FirestoreSchema.stepIndex)
        .limit(50)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => PlanStepModel.fromJson(doc.data() as Map<String, dynamic>)).toList());
  }

  Future<void> updatePlanStep(String userId, String planId, int stepIndex, bool completed, {String? note}) async {
    final updateData = <String, dynamic>{FirestoreSchema.stepCompleted: completed};
    if (note != null) {
      updateData['note'] = note;
    }
    await FirestoreSchema.planStepDoc(userId, planId, stepIndex.toString())
        .update(updateData);
  }

  Future<void> updatePlanStepNote(String userId, String planId, int stepIndex, String note) async {
    await FirestoreSchema.planStepDoc(userId, planId, stepIndex.toString())
        .update({'note': note});
  }

  // Journal operations
  Future<String> createJournalEntry(String userId, JournalEntryModel entry) async {
    final entryRef = FirestoreSchema.userJournals(userId).doc();
    final entryWithId = JournalEntryModel(
      id: entryRef.id,
      title: entry.title,
      body: entry.body,
      mood: entry.mood,
      createdAt: entry.createdAt,
    );
    await entryRef.set(entryWithId.toJson());
    return entryRef.id;
  }

  Stream<List<JournalEntryModel>> getJournalEntries(String userId) {
    return FirestoreSchema.userJournals(userId)
        .orderBy(FirestoreSchema.journalCreatedAt, descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => JournalEntryModel.fromJson(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }

  Future<void> updateJournalEntry(String userId, JournalEntryModel entry) async {
    await FirestoreSchema.journalDoc(userId, entry.id).update(entry.toJson());
  }

  Future<void> deleteJournalEntry(String userId, String entryId) async {
    await FirestoreSchema.journalDoc(userId, entryId).delete();
  }

  // Chat operations
  Future<String> sendChatMessage(String userId, String threadId, ChatMessageModel message) async {
    final messageRef = FirestoreSchema.chatMessages(userId, threadId).doc();

    final messageWithId = ChatMessageModel(
      id: messageRef.id,
      role: message.role,
      text: message.text,
      createdAt: message.createdAt,
    );

    await messageRef.set(messageWithId.toJson());
    return messageRef.id;
  }

  Stream<List<ChatMessageModel>> getChatMessages(String userId, String threadId) {
    return FirestoreSchema.chatMessages(userId, threadId)
        .orderBy(FirestoreSchema.messageCreatedAt)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessageModel.fromJson(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }

  // User operations
  Future<UserModel?> getUser(String userId) async {
    final doc = await FirestoreSchema.userDoc(userId).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromJson(userId, doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> createOrUpdateUser(String userId, UserModel user) async {
    await FirestoreSchema.userDoc(userId).set(user.toJson(), SetOptions(merge: true));
  }

  // Big Five Assessment operations
  Future<List<BigFiveQuestionModel>> getBigFiveQuestions() async {
    final snapshot = await FirestoreSchema.bigFiveQuestions()
        .orderBy('order')
        .get();
    
    return snapshot.docs
        .map((doc) => BigFiveQuestionModel.fromJson(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> seedBigFiveQuestions(List<BigFiveQuestionModel> questions) async {
    final batch = _firestore.batch();
    
    for (final question in questions) {
      final questionRef = FirestoreSchema.bigFiveQuestionDoc(question.id);
      batch.set(questionRef, question.toJson());
    }
    
    await batch.commit();
  }

  Future<String> saveBigFiveProfile(String userId, BigFiveProfileModel profile) async {
    final profileRef = FirestoreSchema.userBigFiveProfiles(userId).doc();
    final profileWithId = BigFiveProfileModel(
      id: profileRef.id,
      scores: profile.scores,
      createdAt: profile.createdAt,
      itemCount: profile.itemCount,
    );
    
    await profileRef.set(profileWithId.toJson());
    return profileRef.id;
  }

  Future<BigFiveProfileModel?> getLatestBigFiveProfile(String userId) async {
    final snapshot = await FirestoreSchema.userBigFiveProfiles(userId)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();
    
    if (snapshot.docs.isEmpty) return null;
    
    final doc = snapshot.docs.first;
    return BigFiveProfileModel.fromJson(doc.id, doc.data() as Map<String, dynamic>);
  }

  // Resources/Library operations
  Future<List<ResourceModel>> getResources({String? type, List<String>? tags}) async {
    Query query = FirestoreSchema.resources().orderBy('createdAt', descending: true);
    
    if (type != null) {
      query = query.where('type', isEqualTo: type);
    }
    
    final snapshot = await query.limit(50).get();
    
    List<ResourceModel> resources = snapshot.docs
        .map((doc) => ResourceModel.fromJson(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
    
    // Filter by tags if provided
    if (tags != null && tags.isNotEmpty) {
      resources = resources.where((resource) {
        return tags.any((tag) => resource.tags.contains(tag));
      }).toList();
    }
    
    return resources;
  }

  Future<List<ResourceModel>> getRecommendedResources(List<String>? userTraits) async {
    if (userTraits == null || userTraits.isEmpty) {
      // Return general resources if no traits available
      return await getResources();
    }
    
    final snapshot = await FirestoreSchema.resources()
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();
    
    List<ResourceModel> allResources = snapshot.docs
        .map((doc) => ResourceModel.fromJson(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
    
    // Filter resources that match user traits
    List<ResourceModel> matchingResources = allResources.where((resource) {
      return userTraits.any((trait) => resource.tags.contains(trait));
    }).toList();
    
    // If we have matches, return them, otherwise return general resources
    return matchingResources.isNotEmpty ? matchingResources.take(10).toList() : allResources.take(10).toList();
  }

  Future<ResourceModel?> getResource(String resourceId) async {
    final doc = await FirestoreSchema.resourceDoc(resourceId).get();
    if (doc.exists && doc.data() != null) {
      return ResourceModel.fromJson(doc.id, doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> seedResources(List<ResourceModel> resources) async {
    final batch = _firestore.batch();
    
    for (final resource in resources) {
      final resourceRef = FirestoreSchema.resourceDoc(resource.id);
      batch.set(resourceRef, resource.toJson());
    }
    
    await batch.commit();
  }
}