import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constant/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../widget/custom_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _fadeController  = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _slideController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim  = CurvedAnimation(parent: _fadeController,  curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final vm = context.read<AuthViewModel>();
    final result = await vm.login(
      email: _emailController.text, password: _passwordController.text,
    );
    if (!mounted) return;
    if (result.success) Navigator.pushReplacementNamed(context, AppConstants.routeHome);
  }

  Future<void> _handleGoogleSignIn() async {
    FocusScope.of(context).unfocus();
    final vm = context.read<AuthViewModel>();
    final result = await vm.signInWithGoogle();
    if (!mounted) return;
    if (result.success) Navigator.pushReplacementNamed(context, AppConstants.routeHome);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  // Logo
                  Row(
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: AppColors.primaryGradient,
                              begin: Alignment.topLeft, end: Alignment.bottomRight),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.view_in_ar_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Text('AR Decor',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary, letterSpacing: -0.8)),
                    ],
                  ),
                  const SizedBox(height: 40),
                  const AuthHeader(
                    title: 'Welcome\nback.',
                    subtitle: 'Sign in to continue designing your space.',
                  ),
                  const SizedBox(height: 36),
                  // Form
                  Consumer<AuthViewModel>(
                    builder: (context, vm, _) => Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          if (vm.errorMessage != null) ...[
                            ErrorBanner(message: vm.errorMessage!, onDismiss: vm.clearError),
                            const SizedBox(height: 16),
                          ],
                          AppTextField(
                            controller: _emailController,
                            label: 'Email', hint: 'Enter your email',
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            focusNode: _emailFocus,
                            validator: Validators.validateEmail,
                            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocus),
                            prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textHint, size: 20),
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            controller: _passwordController,
                            label: 'Password', hint: 'Enter your password',
                            obscureText: vm.obscurePassword,
                            textInputAction: TextInputAction.done,
                            focusNode: _passwordFocus,
                            validator: (v) => v == null || v.isEmpty ? 'Password is required' : null,
                            onFieldSubmitted: (_) => _handleLogin(),
                            prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textHint, size: 20),
                            suffixIcon: IconButton(
                              icon: Icon(
                                vm.obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: AppColors.textHint, size: 20,
                              ),
                              onPressed: vm.togglePasswordVisibility,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => Navigator.pushNamed(context, AppConstants.routeForgotPassword),
                              child: const Text('Forgot password?',
                                  style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600)),
                            ),
                          ),
                          const SizedBox(height: 8),
                          PrimaryButton(
                            label: 'Sign In', onPressed: _handleLogin, isLoading: vm.isLoading,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const DividerWithText(text: 'or continue with'),
                  const SizedBox(height: 20),
                  Consumer<AuthViewModel>(
                    builder: (context, vm, _) => GoogleSignInButton(
                      onPressed: _handleGoogleSignIn, isLoading: vm.isLoading,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Register link
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account? ",
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, AppConstants.routeRegister),
                          child: const Text('Create account',
                              style: TextStyle(color: AppColors.accent, fontSize: 14, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}