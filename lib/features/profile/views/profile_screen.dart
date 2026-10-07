import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/estar_friendly_error.dart';
import '../../auth/providers/auth_provider.dart';
import '../../favorites/providers/favorite_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isDeleting = false;

  void _showPrivacyPolicyModal() {
    HapticFeedback.lightImpact();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          height: MediaQuery.of(sheetContext).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
            boxShadow: [
              BoxShadow(
                color: Color(0x1F000000),
                blurRadius: 28.0,
                offset: Offset(0, -6),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12.0, bottom: 8.0),
                    width: 44.0,
                    height: 4.0,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Privacy Policy',
                        style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: Color(0xFF111827),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Color(0xFF94A3B8),
                          size: 22.0,
                        ),
                        onPressed: () => Navigator.pop(sheetContext),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Color(0xFFF1F5F9), height: 1.0),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Last updated: October 2026',
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        _buildLegalSection(
                          title: '1. Information We Collect',
                          body:
                              'EstarKo collects personal information you provide when registering, including your full name, email address, and account role (Tenant or Landlord). For landlords, we moderate government-issued identification for verification. When searching for properties, approximate location data may be processed to display boarding houses near your campus or workplace.',
                        ),
                        _buildLegalSection(
                          title: '2. How We Use Information',
                          body:
                              'We use your data solely to connect tenants with verified landlords, manage viewing schedules and inquiries, maintain platform integrity, and deliver account security notifications.',
                        ),
                        _buildLegalSection(
                          title: '3. Data Security & Storage',
                          body:
                              'All account data and chat inquiries are encrypted in transit and stored securely on Google Cloud infrastructure. Sensitive API keys and credentials are strictly isolated from client binaries.',
                        ),
                        _buildLegalSection(
                          title: '4. Account Deletion & User Rights',
                          body:
                              'In compliance with Google Play and Apple App Store standards, you retain full ownership of your data and may permanently delete your account and associated records at any time using the "Delete Account" button on your profile screen.',
                        ),
                        _buildLegalSection(
                          title: '5. Contact Support',
                          body:
                              'If you have questions regarding your data privacy or rights under the Philippine Data Privacy Act of 2012, contact our team at privacy@estarko.com.',
                        ),
                        const SizedBox(height: 20.0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTermsOfServiceModal() {
    HapticFeedback.lightImpact();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          height: MediaQuery.of(sheetContext).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12.0, bottom: 8.0),
                    width: 44.0,
                    height: 4.0,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Terms of Service',
                        style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: Color(0xFF111827),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Color(0xFF94A3B8),
                          size: 22.0,
                        ),
                        onPressed: () => Navigator.pop(sheetContext),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Color(0xFFF1F5F9), height: 1.0),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLegalSection(
                          title: 'Community Guidelines',
                          body:
                              'All listings on EstarKo must represent genuine boarding houses, dormitories, or student rooms with accurate rental pricing and authentic photos.',
                        ),
                        _buildLegalSection(
                          title: 'Verification Moderation',
                          body:
                              'Landlord accounts undergo document moderation prior to publishing listings. Misrepresentation of property status or rental conditions will result in account suspension.',
                        ),
                        _buildLegalSection(
                          title: 'Viewing Inquiries',
                          body:
                              'Tenants may submit up to 3 viewing inquiries daily to encourage responsible scheduling and protect landlords from spam.',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegalSection({
    required String title,
    required String body,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 6.0),
          Text(
            body,
            style: const TextStyle(
              fontSize: 13.5,
              color: Color(0xFF4B5563),
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDeleteAccount() async {
    HapticFeedback.mediumImpact();

    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: Colors.white,
          title: const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFE11D48),
                size: 26.0,
              ),
              SizedBox(width: 10.0),
              Text(
                'Delete Account?',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          content: const Text(
            'Are you sure you want to permanently delete your account? All your profile information, inquiries, and saved preferences will be erased. This action cannot be undone.',
            style: TextStyle(
              fontSize: 14.0,
              color: Color(0xFF4B5563),
              height: 1.5,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: const Text(
                      'Keep Account',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      backgroundColor: const Color(0xFFE11D48),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    onPressed: () => Navigator.pop(dialogContext, true),
                    child: const Text(
                      'Delete',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (confirmDelete != true || !mounted) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final favoriteProvider =
          Provider.of<FavoriteProvider>(context, listen: false);

      final success = await authProvider.deleteAccount();

      if (success) {
        favoriteProvider.clearFavorites();
        if (mounted) {
          EstarFriendlyError.showSuccessSnackBar(
            context,
            'Your account has been deleted successfully.',
          );
        }
      } else {
        if (mounted) {
          EstarFriendlyError.showSnackBar(
            context,
            authProvider.errorMessage.isNotEmpty
                ? authProvider.errorMessage
                : 'Unable to delete account right now. Please try again.',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        EstarFriendlyError.showSnackBar(
          context,
          EstarFriendlyError.mask(e),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Icon(
              icon,
              size: 20.0,
              color: const Color(0xFFE11D48),
            ),
          ),
          const SizedBox(width: 14.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20.0,
                color: const Color(0xFF64748B),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 15.0,
                color: Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    final displayName = user?.name.isNotEmpty == true ? user!.name : 'Tenant';
    final email = user?.email.isNotEmpty == true ? user!.email : 'No email';
    final role = user?.role.isNotEmpty == true ? user!.role : 'tenant';

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 120.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Massive Header
              const Text(
                'Your Profile',
                style: TextStyle(
                  fontSize: 34.0,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.0,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 6.0),
              Text(
                'Manage your account details and preferences.',
                style: TextStyle(
                  fontSize: 15.0,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 28.0),

              // Profile Card with Avatar
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 20.0,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Avatar Circle
                    Container(
                      width: 80.0,
                      height: 80.0,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1F2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFFFE4E6),
                          width: 2.0,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          displayName.isNotEmpty
                              ? displayName[0].toUpperCase()
                              : 'T',
                          style: const TextStyle(
                            fontSize: 32.0,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFE11D48),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // Name
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: Color(0xFF111827),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4.0),

                    // Email
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14.0),

                    // Role Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14.0,
                        vertical: 6.0,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1F2),
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(
                          color: const Color(0xFFE11D48).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        role.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFE11D48),
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20.0),

              // Account Details Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 20.0,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Account Details',
                      style: TextStyle(
                        fontSize: 17.0,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    const Divider(color: Color(0xFFF1F5F9), height: 1.0),
                    const SizedBox(height: 6.0),
                    _buildInfoTile(
                      icon: Icons.person_outline_rounded,
                      label: 'Full Name',
                      value: displayName,
                    ),
                    const Divider(color: Color(0xFFF1F5F9), height: 1.0),
                    _buildInfoTile(
                      icon: Icons.mail_outline_rounded,
                      label: 'Email Address',
                      value: email,
                    ),
                    const Divider(color: Color(0xFFF1F5F9), height: 1.0),
                    _buildInfoTile(
                      icon: Icons.shield_outlined,
                      label: 'Account Role',
                      value: role.toUpperCase(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20.0),

              // Legal & Compliance Card (Rule 5: Store-Ready Compliance)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 20.0,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Legal & Information',
                      style: TextStyle(
                        fontSize: 17.0,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    const Divider(color: Color(0xFFF1F5F9), height: 1.0),
                    _buildLinkTile(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      onTap: _showPrivacyPolicyModal,
                    ),
                    const Divider(color: Color(0xFFF1F5F9), height: 1.0),
                    _buildLinkTile(
                      icon: Icons.article_outlined,
                      title: 'Terms of Service',
                      onTap: _showTermsOfServiceModal,
                    ),
                    const Divider(color: Color(0xFFF1F5F9), height: 1.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 4.0,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            size: 20.0,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 12.0),
                          const Expanded(
                            child: Text(
                              'App Version',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ),
                          Text(
                            'v1.0.0 (Store Release)',
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28.0),

              // Sign Out Button
              SizedBox(
                height: 54.0,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF1F5F9),
                    foregroundColor: const Color(0xFF475569),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Provider.of<FavoriteProvider>(context, listen: false)
                        .clearFavorites();
                    Provider.of<AuthProvider>(context, listen: false)
                        .logout(context: context);
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout_rounded, size: 20.0),
                      SizedBox(width: 8.0),
                      Text(
                        'Sign Out',
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14.0),

              // Delete Account Button (Rule 5: Red Text Button for Store-Ready Compliance)
              Center(
                child: TextButton.icon(
                  onPressed: _isDeleting ? null : _handleDeleteAccount,
                  icon: _isDeleting
                      ? const SizedBox(
                          width: 16.0,
                          height: 16.0,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFFE11D48),
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.delete_outline_rounded,
                          size: 18.0,
                          color: Color(0xFFE11D48),
                        ),
                  label: Text(
                    _isDeleting ? 'Deleting Account...' : 'Delete Account',
                    style: const TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFE11D48),
                    ),
                  ),
                ),
              ),
            ]
                .animate(interval: 50.ms)
                .fade(duration: 400.ms)
                .slideY(begin: 0.05, curve: Curves.easeOutQuad),
          ),
        ),
      ),
    );
  }
}
