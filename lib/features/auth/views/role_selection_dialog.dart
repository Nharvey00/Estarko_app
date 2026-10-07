import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../shared/widgets/custom_button.dart';

/// Modal dialog presented to new Google Sign-In users to select their role.
/// Returns 'tenant', 'landlord', or null if dismissed.
class RoleSelectionDialog extends StatefulWidget {
  const RoleSelectionDialog({super.key});

  /// Helper method to display the dialog
  static Future<String?> show(
    BuildContext context, {
    bool barrierDismissible = false,
  }) {
    return showDialog<String>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => const RoleSelectionDialog(),
    );
  }

  @override
  State<RoleSelectionDialog> createState() => _RoleSelectionDialogState();
}

class _RoleSelectionDialogState extends State<RoleSelectionDialog> {
  String _selectedRole = 'tenant';

  Widget _buildRoleCard({
    required String role,
    required String title,
    required String description,
    required IconData icon,
  }) {
    final isSelected = _selectedRole == role;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutQuad,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFE11D48).withValues(alpha: 0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFE11D48)
                : const Color(0xFFE2E8F0),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFFE11D48).withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: isSelected ? 12.0 : 6.0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48.0,
              height: 48.0,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFE11D48)
                    : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
                size: 24.0,
              ),
            ),
            const SizedBox(width: 14.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? const Color(0xFFE11D48)
                          : const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.grey.shade600,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8.0),
            Container(
              width: 22.0,
              height: 22.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFE11D48)
                      : const Color(0xFFCBD5E1),
                  width: 2.0,
                ),
                color: isSelected
                    ? const Color(0xFFE11D48)
                    : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 14.0,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        // When system back button is pressed without confirming, dialog pops with null
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 30.0,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row with Title and Dismiss/Close icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Are you a Tenant or a Landlord?',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF64748B), size: 22.0),
                    onPressed: () => Navigator.of(context).pop(null),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 20.0,
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              Text(
                'Select your account type to personalize your experience on EstarKo.',
                style: TextStyle(
                  fontSize: 13.5,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20.0),

              // Option 1: Tenant
              _buildRoleCard(
                role: 'tenant',
                title: 'Tenant',
                description: 'Find, explore, and view student & worker boarding houses.',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 12.0),

              // Option 2: Landlord
              _buildRoleCard(
                role: 'landlord',
                title: 'Landlord',
                description: 'List boarding rooms, manage inquiries, and schedule viewings.',
                icon: Icons.roofing_outlined,
              ),
              const SizedBox(height: 24.0),

              // Confirm Button
              EstarButton(
                text: 'Continue as ${_selectedRole == 'tenant' ? 'Tenant' : 'Landlord'}',
                onPressed: () {
                  Navigator.of(context).pop(_selectedRole);
                },
              ),
              const SizedBox(height: 8.0),

              // Cancel action
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
            .animate()
            .fade(duration: 250.ms)
            .scale(begin: const Offset(0.95, 0.95), curve: Curves.easeOutQuad),
      ),
    ),
  );
}
}
