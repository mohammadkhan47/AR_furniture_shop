// lib/repositories/auth_repository.dart
//
// The repository is the ONLY place that talks to Firebase.
// ViewModels call the repository — never Firebase directly.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/usermodel.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

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

  // ── Google Sign-In ───────────────────────────────────────────────
  Future<UserModel> signInWithGoogle() async {
    // Trigger the Google sign-in flow
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      // User cancelled the sign-in dialog
      throw FirebaseAuthException(
        code: 'sign-in-cancelled',
        message: 'Google sign-in was cancelled.',
      );
    }

    // Get auth tokens
    final googleAuth = await googleUser.authentication;

    // Create Firebase credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in to Firebase
    final userCredential = await _auth.signInWithCredential(credential);
    final firebaseUser = userCredential.user!;

    // Check if this is a new user — if so, save their profile
    final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

    if (isNewUser) {
      final userModel = UserModel(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName,
        photoUrl: firebaseUser.photoURL,
        createdAt: DateTime.now(),
      );
      await _firestore
          .collection('users')
          .doc(userModel.uid)
          .set(userModel.toMap());
      return userModel;
    }

    // Existing user — fetch their Firestore profile
    final doc =
    await _firestore.collection('users').doc(firebaseUser.uid).get();

    if (doc.exists) return UserModel.fromMap(doc.data()!);

    // Fallback: build from Firebase user data
    return UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
      createdAt: DateTime.now(),
    );
  }

  // ── Logout (also disconnects Google session) ─────────────────────
  Future<void> logout() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }
}