// lib/core/router.dart

import 'package:arshopapp/view/auth/forgot_view.dart';
import 'package:flutter/material.dart';
import '../view/auth/login_view.dart';
import '../view/auth/register_view.dart';
import '../view/home/home_screen.dart';
import '../view/splash_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';

  static Map<String, WidgetBuilder> get routes => {
    splash: (_) => const SplashScreen(),
    login: (_) => const LoginScreen(),
    register: (_) => const RegisterScreen(),
    forgotPassword : (_) => const ForgotPasswordScreen(),
    home: (_) => const HomeScreen(),
  };
}