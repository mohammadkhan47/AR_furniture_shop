import 'package:flutter/material.dart';

import '../../view/auth/forgot_password_screen.dart';
import '../../view/auth/login_screen.dart';
import '../../view/auth/register_screen.dart';
import '../../view/auth/splash_screen.dart';
import '../../view/product/product_detail_screen.dart';
import '../constant/app_constants.dart';
import '../../view/home/home_screen.dart';
import '../../view/cart/cart_screen.dart';


class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppConstants.routeSplash:
        return _buildRoute(const SplashScreen(), settings);
      case AppConstants.routeLogin:
        return _buildRoute(const LoginScreen(), settings);
      case AppConstants.routeRegister:
        return _buildRoute(const RegisterScreen(), settings);
      case AppConstants.routeForgotPassword:
        return _buildRoute(const ForgotPasswordScreen(), settings);
      case AppConstants.routeHome:
        return _buildRoute(const HomeScreen(), settings);
      case AppConstants.routeProductDetail:
        return _buildRoute(const ProductDetailScreen(), settings);
      case AppConstants.routeCart:
        return _buildRoute(const CartScreen(), settings);
      default:
        return _buildRoute(
          Scaffold(body: Center(child: Text('No route defined for ${settings.name}'))),
          settings,
        );
    }
  }

  static PageRoute _buildRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 250),
    );
  }
}