// lib/repositories/auth_repository.dart
//
// The repository is the ONLY place that talks to Firebase.
// ViewModels call the repository — never Firebase directly.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/usermodel.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── Stream: listen to auth state changes app-wide ──────────────
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── Current Firebase user ───────────────────────────────────────
  User? get currentUser => _auth.currentUser;

  // ── Register with email & password ─────────────────────────────
  Future<UserModel> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await credential.user!.updateDisplayName(displayName);

    final userModel = UserModel(
      uid: credential.user!.uid,
      email: email,
      displayName: displayName,
      createdAt: DateTime.now(),
    );

    // Save user profile to Firestore
    await _firestore
        .collection('users')
        .doc(userModel.uid)
        .set(userModel.toMap());

    return userModel;
  }

  // ── Login with email & password ─────────────────────────────────
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final doc = await _firestore
        .collection('users')
        .doc(credential.user!.uid)
        .get();

    if (!doc.exists) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'User profile not found.',
      );
    }

    return UserModel.fromMap(doc.data()!);
  }

  // ── Logout ──────────────────────────────────────────────────────
  Future<void> logout() async {
    await _auth.signOut();
  }

  // ── Password reset email ────────────────────────────────────────
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // ── Fetch saved user profile from Firestore ─────────────────────
  Future<UserModel?> fetchUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!);
  }
}