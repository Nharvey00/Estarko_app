import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'tenant'; // 'tenant' or 'seller'

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.register(
      email: email,
      password: password,
      name: name,
      role: _selectedRole,
    );

    if (!mounted) return;

    if (success) {
      // Pop back to root so AuthWrapper displays the authenticated dashboard
      Navigator.popUntil(context, (route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage.isNotEmpty
              ? authProvider.errorMessage
              : 'Registration failed. Please try again.'),
          backgroundColor: const Color(0xFFE11D48),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildRoleCard({
    required String role,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedRole == role;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedRole = role;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutQuad,
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
                blurRadius: isSelected ? 14.0 : 8.0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: AspectRatio(
            aspectRatio: 1.0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AnimatedScale(
                    scale: isSelected ? 1.15 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutQuad,
                    child: Container(
                      width: 44.0,
                      height: 44.0,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFE11D48)
                            : const Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF64748B),
                        size: 22.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? const Color(0xFFE11D48)
                          : const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.0,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final size = MediaQuery.of(context).size;
    final imageHeight = size.height * 0.38;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // Architectural Photo with gradient fade
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: imageHeight,
              child: ShaderMask(
                shaderCallback: (rect) {
                  return const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black,
                      Colors.black,
                      Colors.transparent,
                    ],
                    stops: [0.0, 0.5, 1.0],
                  ).createShader(rect);
                },
                blendMode: BlendMode.dstIn,
                child: CachedNetworkImage(
                  imageUrl:
                      'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?q=80&w=800',
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey.shade200,
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey.shade200,
                    child: const Icon(
                      Icons.home_work_outlined,
                      color: Colors.grey,
                      size: 48.0,
                    ),
                  ),
                ),
              ),
            ),

            // Back Button
            Positioned(
              top: MediaQuery.of(context).padding.top + 8.0,
              left: 16.0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8.0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_outlined,
                    color: Color(0xFF111827),
                    size: 20.0,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),

            // Form Content overlapping image fade
            Padding(
              padding: EdgeInsets.only(
                top: imageHeight - 48.0,
                left: AppConstants.defaultPadding,
                right: AppConstants.defaultPadding,
                bottom: 40.0,
              ),
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main Header
                    const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 36.0,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.5,
                        color: Color(0xFF111827),
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 8.0),

                    // Subtitle
                    Text(
                      'Join EstarKo to explore or list student and worker housing.',
                      style: TextStyle(
                        fontSize: 15.0,
                        color: Colors.grey.shade500,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28.0),

                    // Role Selection Cards
                    const Text(
                      'I am joining as a...',
                      style: TextStyle(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    Row(
                      children: [
                        _buildRoleCard(
                          role: 'tenant',
                          title: 'Tenant',
                          subtitle: 'Seek Housing',
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(width: 14.0),
                        _buildRoleCard(
                          role: 'seller',
                          title: 'Seller',
                          subtitle: 'List Property',
                          icon: Icons.roofing_outlined,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24.0),

                    // Full Name
                    const Text(
                      'Full Name',
                      style: TextStyle(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    EstarTextField(
                      controller: _nameController,
                      hintText: 'John Doe',
                      keyboardType: TextInputType.name,
                    ),
                    const SizedBox(height: 20.0),

                    // Email
                    const Text(
                      'Email Address',
                      style: TextStyle(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    EstarTextField(
                      controller: _emailController,
                      hintText: 'name@example.com',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20.0),

                    // Password
                    const Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    EstarTextField(
                      controller: _passwordController,
                      hintText: 'Create a password (min. 6 characters)',
                      isPassword: true,
                    ),
                    const SizedBox(height: 32.0),

                    // Register Button
                    EstarButton(
                      text: 'Create Account',
                      isLoading: authProvider.isLoading,
                      onPressed: _handleRegister,
                    ),
                    const SizedBox(height: 20.0),

                    // Navigation to Login
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: RichText(
                          text: const TextSpan(
                            text: 'Already have an account? ',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 14.0,
                            ),
                            children: [
                              TextSpan(
                                text: 'Sign In',
                                style: TextStyle(
                                  color: Color(0xFFE11D48),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
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
          ],
        ),
      ),
    );
  }
}