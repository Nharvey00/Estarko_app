import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../favorites/providers/favorite_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
          padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 32.0),
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
              const SizedBox(height: 32.0),

              // Massive, full-width, soft grey Sign Out button
              SizedBox(
                height: 56.0,
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
                    Provider.of<FavoriteProvider>(context, listen: false)
                        .clearFavorites();
                    Provider.of<AuthProvider>(context, listen: false).logout();
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout_rounded, size: 20.0),
                      SizedBox(width: 8.0),
                      Text(
                        'Sign Out',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]
                .animate(interval: 100.ms)
                .fade(duration: 400.ms)
                .slideY(begin: 0.1, curve: Curves.easeOutQuad),
          ),
        ),
      ),
    );
  }
}
