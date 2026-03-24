import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constant/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../widget/custom_widget.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController     = TextEditingController();
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController  = TextEditingController();
  final _nameFocus     = FocusNode();
  final _emailFocus    = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus  = FocusNode();
  bool _acceptTerms = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose(); _emailController.dispose();
    _passwordController.dispose(); _confirmController.dispose();
    _nameFocus.dispose(); _emailFocus.dispose();
    _passwordFocus.dispose(); _confirmFocus.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Terms & Conditions to continue.'),
          backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    FocusScope.of(context).unfocus();
    final vm = context.read<AuthViewModel>();
    final result = await vm.register(
      email: _emailController.text,
      password: _passwordController.text,
      fullName: _nameController.text,
    );
    if (!mounted) return;
    if (result.success) _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(32),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.mark_email_read_outlined, color: AppColors.success, size: 36),
            ),
            const SizedBox(height: 20),
            const Text('Verify your email',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            const Text(
              'We\'ve sent a verification link to your email. Please verify to continue.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 28),
            PrimaryButton(
              label: 'Go to Login',
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, AppConstants.routeLogin);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const AuthHeader(
                  title: 'Create\naccount.',
                  subtitle: 'Start your AR home design journey today.',
                ),
                const SizedBox(height: 36),
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
                          controller: _nameController,
                          label: 'Full Name', hint: 'Enter your full name',
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                          focusNode: _nameFocus,
                          validator: Validators.validateName,
                          onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_emailFocus),
                          prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.textHint, size: 20),
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _emailController,
                          label: 'Email', hint: 'Enter your email address',
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
                          label: 'Password', hint: 'Create a strong password',
                          obscureText: vm.obscurePassword,
                          textInputAction: TextInputAction.next,
                          focusNode: _passwordFocus,
                          validator: Validators.validatePassword,
                          onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_confirmFocus),
                          prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textHint, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              vm.obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: AppColors.textHint, size: 20,
                            ),
                            onPressed: vm.togglePasswordVisibility,
                          ),
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _confirmController,
                          label: 'Confirm Password', hint: 'Re-enter your password',
                          obscureText: vm.obscureConfirmPassword,
                          textInputAction: TextInputAction.done,
                          focusNode: _confirmFocus,
                          validator: (v) => Validators.validateConfirmPassword(v, _passwordController.text),
                          onFieldSubmitted: (_) => _handleRegister(),
                          prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textHint, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              vm.obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: AppColors.textHint, size: 20,
                            ),
                            onPressed: vm.toggleConfirmPasswordVisibility,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Password hint box
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Password must contain:',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                              const SizedBox(height: 8),
                              ...['At least 8 characters', 'One uppercase letter', 'One number'].map(
                                    (t) => Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.check_circle_outline_rounded, color: AppColors.textHint, size: 14),
                                      const SizedBox(width: 8),
                                      Text(t, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Terms checkbox
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 24, height: 24,
                              child: Checkbox(
                                value: _acceptTerms,
                                onChanged: (v) => setState(() => _acceptTerms = v ?? false),
                                activeColor: AppColors.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _acceptTerms = !_acceptTerms),
                                child: RichText(
                                  text: const TextSpan(
                                    text: 'I agree to the ',
                                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                    children: [
                                      TextSpan(text: 'Terms of Service',
                                          style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600)),
                                      TextSpan(text: ' and '),
                                      TextSpan(text: 'Privacy Policy',
                                          style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        PrimaryButton(
                          label: 'Create Account', onPressed: _handleRegister, isLoading: vm.isLoading,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account? ',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacementNamed(context, AppConstants.routeLogin),
                        child: const Text('Sign in',
                            style: TextStyle(color: AppColors.accent, fontSize: 14, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}