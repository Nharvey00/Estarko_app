import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/theme.dart';
import 'splash_screen.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/views/login_screen.dart';
import 'features/verification/providers/verification_provider.dart';
import 'features/inquiries/providers/inquiry_provider.dart';
import 'features/favorites/providers/favorite_provider.dart';

import 'shared/widgets/skeleton_loader.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Environment file (.env) load warning: $e');
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => VerificationProvider()),
        ChangeNotifierProvider(create: (_) => InquiryProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
      ],
      child: const EstarKoApp(),
    ),
  );
}

class EstarKoApp extends StatelessWidget {
  const EstarKoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EstarKo',
      theme: appTheme,
      home: const SplashScreen(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    // Show EstarSkeleton loader while initial startup session is being verified
    if (authProvider.isInitialLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFFAFAFA),
        body: Center(
          child: EstarSkeleton(
            width: 100.0,
            height: 100.0,
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
        ),
      );
    }

    // If currentUser == null, return LoginScreen()
    if (user == null) {
      return const LoginScreen();
    }

    // Strict centralized routing based on user role and verification status
    return authProvider.getDestinationScreen(user);
  }
}