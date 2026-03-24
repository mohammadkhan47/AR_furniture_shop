import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/models/user_model.dart';
import '../data/models/auth_result.dart';
import '../data/repositories/auth_repo.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthViewModel({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository() {
    _init();
  }

  AuthStatus _status = AuthStatus.initial;
  UserModel? _currentUser;
  String? _errorMessage;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  AuthStatus get status => _status;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  void _init() {
    _authRepository.authStateChanges.listen((User? user) {
      _status = user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
      if (user == null) _currentUser = null;
      notifyListeners();
    });
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<AuthResult> register({
    required String email, required String password, required String fullName,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    final result = await _authRepository.registerWithEmail(
      email: email, password: password, fullName: fullName,
    );
    if (result.success) {
      _currentUser = result.data as UserModel?;
      _status = AuthStatus.authenticated;
    } else {
      _errorMessage = result.message;
      _status = AuthStatus.error;
    }
    _setLoading(false);
    return result;
  }

  Future<AuthResult> login({required String email, required String password}) async {
    _setLoading(true);
    _errorMessage = null;
    final result = await _authRepository.signInWithEmail(email: email, password: password);
    if (result.success) {
      _currentUser = result.data as UserModel?;
      _status = AuthStatus.authenticated;
    } else {
      _errorMessage = result.message;
      _status = AuthStatus.error;
    }
    _setLoading(false);
    return result;
  }

  Future<AuthResult> signInWithGoogle() async {
    _setLoading(true);
    _errorMessage = null;
    final result = await _authRepository.signInWithGoogle();
    if (result.success) {
      _currentUser = result.data as UserModel?;
      _status = AuthStatus.authenticated;
    } else {
      _errorMessage = result.message;
      _status = AuthStatus.error;
    }
    _setLoading(false);
    return result;
  }

  Future<AuthResult> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    _errorMessage = null;
    final result = await _authRepository.sendPasswordResetEmail(email);
    if (!result.success) _errorMessage = result.message;
    _setLoading(false);
    return result;
  }

  Future<void> signOut() async {
    _setLoading(true);
    await _authRepository.signOut();
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    _setLoading(false);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}