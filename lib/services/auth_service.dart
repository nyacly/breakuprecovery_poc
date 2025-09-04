import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:breakup_recovery/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential?> signInAnonymously() async {
    try {
      final credential = await _auth.signInAnonymously();
      if (credential.user != null) {
        await _createUserDocument(credential.user!);
      }
      return credential;
    } catch (e) {
      throw Exception('Failed to sign in anonymously: $e');
    }
  }

  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  Future<UserCredential?> createUserWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      if (credential.user != null) {
        await _createUserDocument(credential.user!);
      }
      return credential;
    } catch (e) {
      throw Exception('Failed to create account: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> _createUserDocument(User user) async {
    final userDoc = _firestore.collection('users').doc(user.uid);
    final doc = await userDoc.get();
    
    if (!doc.exists) {
      final userModel = UserModel(
        uid: user.uid,
        displayName: user.displayName ?? 'Anonymous User',
        locale: 'en',
        traits: [],
      );
      await userDoc.set(userModel.toJson());
    }
  }

  Future<UserModel?> getCurrentUserModel() async {
    final user = currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (doc.exists) {
      return UserModel.fromJson(user.uid, doc.data()!);
    }
    return null;
  }

  Future<void> updateUserModel(UserModel userModel) async {
    if (currentUser == null) return;
    await _firestore.collection('users').doc(userModel.uid).update(userModel.toJson());
  }
}