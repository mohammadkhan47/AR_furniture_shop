import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constant/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../widget/custom_widget.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleSendReset() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final vm = context.read<AuthViewModel>();
    final result = await vm.sendPasswordResetEmail(_emailController.text);
    if (!mounted) return;
    if (result.success) setState(() => _emailSent = true);
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: _emailSent ? _buildSuccessView() : _buildFormView(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Column(
      key: const ValueKey('form'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.lock_reset_rounded, color: AppColors.primary, size: 32),
        ),
        const SizedBox(height: 24),
        const AuthHeader(
          title: 'Forgot\npassword?',
          subtitle: 'Enter your email and we\'ll send you a reset link.',
        ),
        const SizedBox(height: 40),
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
                  label: 'Email', hint: 'Enter your registered email',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  validator: Validators.validateEmail,
                  onFieldSubmitted: (_) => _handleSendReset(),
                  prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textHint, size: 20),
                ),
                const SizedBox(height: 28),
                PrimaryButton(label: 'Send Reset Link', onPressed: _handleSendReset, isLoading: vm.isLoading),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: TextButton.icon(
            onPressed: () => Navigator.pushReplacementNamed(context, AppConstants.routeLogin),
            icon: const Icon(Icons.arrow_back_rounded, size: 16),
            label: const Text('Back to Sign In'),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessView() {
    return Column(
      key: const ValueKey('success'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 60),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.elasticOut,
          builder: (context, value, child) => Transform.scale(scale: value, child: child),
          child: Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.mark_email_read_outlined, color: AppColors.success, size: 50),
          ),
        ),
        const SizedBox(height: 32),
        const Text('Check your email',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800,
                color: AppColors.textPrimary, letterSpacing: -1)),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'We sent a password reset link to\n${_emailController.text}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, color: AppColors.textSecondary, height: 1.6),
          ),
        ),
        const SizedBox(height: 48),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface, borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: AppColors.textHint, size: 20),
              const SizedBox(width: 12),
              const Expanded(
                child: Text("Didn't receive it? Check your spam folder or",
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4)),
              ),
              GestureDetector(
                onTap: _handleSendReset,
                child: const Text('resend.',
                    style: TextStyle(fontSize: 13, color: AppColors.accent, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        PrimaryButton(
          label: 'Back to Sign In',
          onPressed: () => Navigator.pushReplacementNamed(context, AppConstants.routeLogin),
        ),
      ],
    );
  }
}