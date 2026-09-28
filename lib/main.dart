import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/views/login_screen.dart';
import 'features/verification/providers/verification_provider.dart';
import 'features/verification/views/admin_dashboard.dart';
import 'features/verification/views/seller_upload_screen.dart';
import 'features/listings/views/seller_dashboard_screen.dart';
import 'features/tenant/views/tenant_main_screen.dart';
import 'features/inquiries/providers/inquiry_provider.dart';
import 'features/favorites/providers/favorite_provider.dart';

import 'shared/widgets/skeleton_loader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    // Show EstarSkeleton loader while session is being verified
    if (authProvider.isLoading) {
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

    // If currentUser.role == 'admin', return AdminDashboard()
    if (user.role == 'admin') {
      return const AdminDashboard();
    }

    // If currentUser.role == 'seller'
    if (user.role == 'seller') {
      // If currentUser.isVerified == false, return SellerUploadScreen()
      if (!user.isVerified) {
        return const SellerUploadScreen();
      }
      return const SellerDashboardScreen();
    }

    // If currentUser.role == 'tenant'
    if (user.role == 'tenant') {
      return const TenantMainScreen();
    }

    return const LoginScreen();
  }
}