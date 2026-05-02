import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constant/app_constants.dart';
import '../models/user_model.dart';
import '../models/auth_result.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<AuthResult> registerWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user!;
      await user.updateDisplayName(fullName.trim());
      await user.sendEmailVerification();
      final userModel = UserModel(
        uid: user.uid,
        email: email.trim(),
        fullName: fullName.trim(),
        isEmailVerified: false,
        authProvider: 'email',
        createdAt: DateTime.now(),
      );
      await _saveUserToFirestore(userModel);
      return AuthResult.success(
          message: AppConstants.successRegistration, data: userModel);
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code} - ${e.message}'); // ← ADD THIS
      return AuthResult.failure(_handleFirebaseAuthError(e));
    } catch (e) {
      print('Unknown error: $e'); // ← ADD THIS
      return AuthResult.failure(AppConstants.errorGeneric);
    }
  }

  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user!;

      // Try to get from Firestore, if fails just use Firebase Auth data
      try {
        final userModel = await _getUserFromFirestore(user.uid);
        if (userModel != null) {
          return AuthResult.success(data: userModel);
        }
      } catch (e) {
        print('Firestore fetch failed, using auth data: $e');
      }

      // Fallback — use Firebase Auth user data directly
      final userModel = UserModel(
        uid: user.uid,
        email: user.email ?? '',
        fullName: user.displayName ?? '',
        isEmailVerified: user.emailVerified,
        authProvider: 'email',
        createdAt: DateTime.now(),
      );
      return AuthResult.success(data: userModel);

    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      return AuthResult.failure(_handleFirebaseAuthError(e));
    } catch (e) {
      print('Login Error: $e');
      return AuthResult.failure(AppConstants.errorGeneric);
    }
  }
  Future<AuthResult> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return AuthResult.failure('Sign-in cancelled by user.');
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        return AuthResult.failure('Could not get tokens from Google.');
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
      await _auth.signInWithCredential(credential);
      final user = userCredential.user!;

      // Check if new or existing user
      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

      if (isNewUser) {
        // New user — save to Firestore
        final userModel = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          fullName: user.displayName ?? 'User',
          photoUrl: user.photoURL,
          isEmailVerified: true,
          authProvider: 'google',
          createdAt: DateTime.now(),
        );
        await _saveUserToFirestore(userModel);
        return AuthResult.success(data: userModel);
      } else {
        // Existing user — fetch from Firestore
        final existingUser = await _getUserFromFirestore(user.uid);
        if (existingUser != null) {
          return AuthResult.success(data: existingUser);
        }
        // Firestore doc missing — recreate it
        final userModel = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          fullName: user.displayName ?? 'User',
          photoUrl: user.photoURL,
          isEmailVerified: true,
          authProvider: 'google',
          createdAt: DateTime.now(),
        );
        await _saveUserToFirestore(userModel);
        return AuthResult.success(data: userModel);
      }

    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      return AuthResult.failure(_handleFirebaseAuthError(e));
    } catch (e) {
      print('Google Sign-In Error: $e');
      return AuthResult.failure('Google sign-in failed: $e');
    }
  }

  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return AuthResult.success(message: AppConstants.successPasswordReset);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_handleFirebaseAuthError(e));
    } catch (e) {
      return AuthResult.failure(AppConstants.errorGeneric);
    }
  }

  Future<AuthResult> signOut() async {
    try {
      await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
      return AuthResult.success();
    } catch (e) {
      return AuthResult.failure(AppConstants.errorGeneric);
    }
  }

  Future<void> _saveUserToFirestore(UserModel user) async {
    await _firestore.collection(AppConstants.usersCollection).doc(user.uid).set(user.toFirestore());
  }

  Future<UserModel?> _getUserFromFirestore(String uid) async {
    final doc = await _firestore.collection(AppConstants.usersCollection).doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  String _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':      return 'No account found with this email address.';
      case 'wrong-password':      return 'Incorrect password. Please try again.';
      case 'email-already-in-use': return 'An account already exists with this email.';
      case 'invalid-email':       return 'Please enter a valid email address.';
      case 'weak-password':       return 'Password is too weak. Use at least 8 characters.';
      case 'user-disabled':       return 'This account has been disabled.';
      case 'too-many-requests':   return 'Too many attempts. Please try again later.';
      case 'network-request-failed': return AppConstants.errorNetwork;
      case 'invalid-credential':  return 'Invalid credentials. Please check and try again.';
      default: return e.message ?? AppConstants.errorGeneric;
    }
  }
}