// lib/core/router.dart

import 'package:flutter/material.dart';
import '../view/auth/login_view.dart';
import '../view/auth/register_view.dart';
import '../view/home/home_screen.dart';
import '../view/splash_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';

  static Map<String, WidgetBuilder> get routes => {
    splash: (_) => const SplashScreen(),
    login: (_) => const LoginScreen(),
    register: (_) => const RegisterScreen(),
    home: (_) => const HomeScreen(),
  };
}