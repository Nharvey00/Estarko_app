import 'package:flutter/material.dart';
import '../../tenant/views/tenant_main_screen.dart';
import '../../listings/views/seller_dashboard_screen.dart';
import '../../verification/views/seller_upload_screen.dart';
import '../../verification/views/admin_dashboard.dart';

/// Screen rendered for Tenants: full interactive Map & discovery dashboard
class MapDashboardScreen extends StatelessWidget {
  const MapDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TenantMainScreen();
  }
}

/// Screen rendered for Verified Landlords: property and listing management
class LandlordDashboardScreen extends StatelessWidget {
  const LandlordDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SellerDashboardScreen();
  }
}

/// Screen rendered for Unverified Landlords: government ID upload & verification status
class AccountVerificationScreen extends StatelessWidget {
  final dynamic verificationService;
  const AccountVerificationScreen({super.key, this.verificationService});

  @override
  Widget build(BuildContext context) {
    return SellerUploadScreen(verificationService: verificationService);
  }
}

/// Screen rendered for Admins: identity document review and verification approval queue
class AdminReviewDashboardScreen extends StatelessWidget {
  const AdminReviewDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminDashboard();
  }
}
