import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'core/constant/app_constants.dart';
import 'firebase_options.dart'; // ← ADD THIS
import 'core/theme/app_theme.dart';
import 'core/utils/app_router.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/product_viewmodel.dart';
import 'viewmodels/cart_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // ← ADD THIS
  );

  runApp(const ARDecorApp());
}

class ARDecorApp extends StatelessWidget {
  const ARDecorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthViewModel>(create: (_) => AuthViewModel()),
        ChangeNotifierProvider<ProductViewModel>(create: (_) => ProductViewModel()),
        ChangeNotifierProvider<CartViewModel>(create: (_) => CartViewModel()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppConstants.routeSplash,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}