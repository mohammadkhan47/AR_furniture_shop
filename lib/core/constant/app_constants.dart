class AppConstants {
  static const String appName = 'AR Decor';
  static const String appTagline = 'Visualize before you buy';

  static const String usersCollection = 'users';
  static const String productsCollection = 'products';
  static const String ordersCollection = 'orders';
  static const String reviewsCollection = 'reviews';

  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyUserId = 'user_id';
  static const String keyUserEmail = 'user_email';
  static const String keyUserName = 'user_name';
  static const String keyOnboardingDone = 'onboarding_done';

  static const int minPasswordLength = 8;
  static const int maxNameLength = 50;

  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNetwork = 'No internet connection. Please check your network.';
  static const String errorInvalidEmail = 'Please enter a valid email address.';
  static const String errorWeakPassword = 'Password must be at least 8 characters.';
  static const String errorPasswordMismatch = 'Passwords do not match.';
  static const String errorEmptyField = 'This field cannot be empty.';

  static const String successRegistration = 'Account created successfully! Welcome aboard.';
  static const String successPasswordReset = 'Password reset email sent. Check your inbox.';
  static const String successProfileUpdate = 'Profile updated successfully.';

  static const String routeSplash = '/';
  static const String routeOnboarding = '/onboarding';
  static const String routeLogin = '/login';
  static const String routeRegister = '/register';
  static const String routeForgotPassword = '/forgot-password';
  static const String routeHome = '/home';
  static const String routeProfile = '/profile';
  static const String routeProductDetail = '/product-detail';
  static const String routeCart = '/cart';
  static const String routeAR = '/ar-view';
}