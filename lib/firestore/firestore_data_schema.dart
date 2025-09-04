import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore Data Schema for Breakup Recovery App
/// 
/// Data Structure:
/// • users/{uid}
/// • users/{uid}/plans/{planId} 
/// • users/{uid}/plans/{planId}/planSteps/{index:int}
/// • users/{uid}/chatThreads/{threadId}/chatMessages/{id}
/// • users/{uid}/journals/{entryId}
/// • users/{uid}/bigFiveProfiles/{profileId}
/// • bigFiveQuestions/{id}
/// • resources/{id}

class FirestoreSchema {
  // Collection paths
  static const String usersCollection = 'users';
  static const String plansSubcollection = 'plans';
  static const String planStepsSubcollection = 'planSteps';
  static const String chatThreadsSubcollection = 'chatThreads';
  static const String chatMessagesSubcollection = 'chatMessages';
  static const String journalsSubcollection = 'journals';
  static const String bigFiveProfilesSubcollection = 'bigFiveProfiles';
  static const String bigFiveQuestionsCollection = 'bigFiveQuestions';
  static const String resourcesCollection = 'resources';

  // Document field names
  static const String userDisplayName = 'displayName';
  static const String userLocale = 'locale';
  static const String userTraits = 'traits';
  static const String userActivePlanId = 'activePlanId';
  static const String userCreatedAt = 'createdAt';

  static const String planCreatedAt = 'createdAt';
  static const String planTitle = 'title';
  static const String planDescription = 'description';
  static const String planIsActive = 'isActive';

  static const String stepTitle = 'title';
  static const String stepIndex = 'index';
  static const String stepIsPremium = 'isPremium';
  static const String stepCompleted = 'completed';
  static const String stepCreatedAt = 'createdAt';
  static const String stepDescription = 'description';

  static const String messageRole = 'role';
  static const String messageText = 'text';
  static const String messageCreatedAt = 'createdAt';

  static const String journalTitle = 'title';
  static const String journalBody = 'body';
  static const String journalMood = 'mood';
  static const String journalCreatedAt = 'createdAt';

  // Helper methods for document references
  static DocumentReference userDoc(String userId) {
    return FirebaseFirestore.instance
        .collection(usersCollection)
        .doc(userId);
  }

  static CollectionReference userPlans(String userId) {
    return userDoc(userId).collection(plansSubcollection);
  }

  static DocumentReference planDoc(String userId, String planId) {
    return userPlans(userId).doc(planId);
  }

  static CollectionReference planSteps(String userId, String planId) {
    return planDoc(userId, planId).collection(planStepsSubcollection);
  }

  static DocumentReference planStepDoc(String userId, String planId, String stepId) {
    return planSteps(userId, planId).doc(stepId);
  }

  static CollectionReference userChatThreads(String userId) {
    return userDoc(userId).collection(chatThreadsSubcollection);
  }

  static DocumentReference chatThreadDoc(String userId, String threadId) {
    return userChatThreads(userId).doc(threadId);
  }

  static CollectionReference chatMessages(String userId, String threadId) {
    return chatThreadDoc(userId, threadId).collection(chatMessagesSubcollection);
  }

  static DocumentReference chatMessageDoc(String userId, String threadId, String messageId) {
    return chatMessages(userId, threadId).doc(messageId);
  }

  static CollectionReference userJournals(String userId) {
    return userDoc(userId).collection(journalsSubcollection);
  }

  static DocumentReference journalDoc(String userId, String entryId) {
    return userJournals(userId).doc(entryId);
  }

  static CollectionReference userBigFiveProfiles(String userId) {
    return userDoc(userId).collection(bigFiveProfilesSubcollection);
  }

  static DocumentReference bigFiveProfileDoc(String userId, String profileId) {
    return userBigFiveProfiles(userId).doc(profileId);
  }

  static CollectionReference bigFiveQuestions() {
    return FirebaseFirestore.instance.collection(bigFiveQuestionsCollection);
  }

  static DocumentReference bigFiveQuestionDoc(String questionId) {
    return bigFiveQuestions().doc(questionId);
  }

  static CollectionReference resources() {
    return FirebaseFirestore.instance.collection(resourcesCollection);
  }

  static DocumentReference resourceDoc(String resourceId) {
    return resources().doc(resourceId);
  }

  // Default values and timestamp helper
  static Map<String, dynamic> getServerTimestamp() {
    return {'TIMESTAMP': FieldValue.serverTimestamp()};
  }
}