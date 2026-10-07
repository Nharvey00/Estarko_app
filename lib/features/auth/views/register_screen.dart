import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../shared/widgets/estar_friendly_error.dart';
import '../providers/auth_provider.dart';

/// Premium iOS-grade Register Screen.
/// Features a layered architectural apartment background with an atmospheric scrim gradient,
/// radial vignette, a floating frosted glass card container (BackdropFilter 18px blur,
/// translucent white surface with hairline border and soft shadow), role selection cards,
/// animated focus inputs, and an edge-to-edge Ruby Red action button.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  String _selectedRole = 'tenant'; // 'tenant' or 'landlord'
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameFocusNode.addListener(() => setState(() {}));
    _emailFocusNode.addListener(() => setState(() {}));
    _passwordFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      EstarFriendlyError.showSnackBar(
        context,
        null,
        customMessage: 'Please fill in your name, email, and password.',
      );
      return;
    }

    if (password.length < 6) {
      EstarFriendlyError.showSnackBar(
        context,
        null,
        customMessage: 'Please choose a password with at least 6 characters.',
      );
      return;
    }

    HapticFeedback.lightImpact();
    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.register(
      email: email,
      password: password,
      name: name,
      role: _selectedRole,
      context: context,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (success) {
      Navigator.popUntil(context, (route) => route.isFirst);
    } else {
      EstarFriendlyError.showSnackBar(
        context,
        authProvider.errorMessage,
      );
    }
  }

  // Layered Architectural Background with Multi-stop Scrim and Vignette
  Widget _buildBackgroundLayer() {
    return Positioned.fill(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Architectural Photography with defensive fallback
          Image.asset(
            'assets/images/apartment_bg.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0B0F19),
                      Color(0xFF1E293B),
                      Color(0xFF0F172A),
                    ],
                  ),
                ),
              );
            },
          ),

          // Atmospheric Multi-Stop Scrim Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF0B0F19).withValues(alpha: 0.45), // Showcase top architecture
                  const Color(0xFF0B0F19).withValues(alpha: 0.85), // Gentle transition
                  const Color(0xFFFAFAFA),                         // Seamless fade to canvas
                ],
                stops: const [0.0, 0.45, 0.85],
              ),
            ),
          ),

          // Radial Vignette for Center Architectural Focus
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.35),
                radius: 1.15,
                colors: [
                  Colors.transparent,
                  const Color(0xFF0B0F19).withValues(alpha: 0.40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back Button & Crest Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Glassmorphic Circular Back Button
            ClipOval(
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                child: Container(
                  width: 44.0,
                  height: 44.0,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.20),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.35),
                      width: 1.0,
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 18.0,
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.maybePop(context);
                    },
                  ),
                ),
              ),
            ),

            // App badge emblem with frosted glass backdrop & ruby glow
            ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                child: Container(
                  width: 44.0,
                  height: 44.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFFB7185),
                        Color(0xFFE11D48),
                        Color(0xFFBE123C),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.35),
                      width: 1.0,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.roofing_rounded,
                      color: Colors.white,
                      size: 24.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20.0),

        // Main Header
        const Text(
          'Join EstarKo',
          style: TextStyle(
            fontSize: 32.0,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.0,
            color: Colors.white,
            height: 1.15,
            shadows: [
              Shadow(
                color: Color(0x66000000),
                blurRadius: 16.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6.0),

        // Subtitle
        const Text(
          'Create an account to start discovering or listing homes.',
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w400,
            color: Color(0xFFE2E8F0),
            height: 1.4,
            shadows: [
              Shadow(
                color: Color(0x44000000),
                blurRadius: 12.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
      ],
    );
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
          HapticFeedback.selectionClick();
          setState(() {
            _selectedRole = role;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFFF1F2) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(18.0),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFE11D48)
                  : const Color(0xFFE2E8F0),
              width: isSelected ? 2.0 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFFE11D48).withValues(alpha: 0.14),
                      blurRadius: 12.0,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 34.0,
                    height: 34.0,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFE11D48)
                          : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Icon(
                      icon,
                      color: isSelected ? Colors.white : const Color(0xFF64748B),
                      size: 18.0,
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFFE11D48),
                      size: 18.0,
                    ),
                ],
              ),
              const SizedBox(height: 12.0),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                  color: isSelected
                      ? const Color(0xFFE11D48)
                      : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2.0),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? const Color(0xFFE11D48).withValues(alpha: 0.8)
                      : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    required FocusNode focusNode,
    required IconData prefixIcon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
  }) {
    final isFocused = focusNode.hasFocus;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.0,
            fontWeight: FontWeight.w700,
            color: isFocused ? const Color(0xFFE11D48) : const Color(0xFF0F172A),
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 8.0),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isFocused ? Colors.white : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(18.0),
            border: Border.all(
              color: isFocused
                  ? const Color(0xFFE11D48)
                  : const Color(0xFFE2E8F0),
              width: isFocused ? 1.8 : 1.2,
            ),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: const Color(0xFFE11D48).withValues(alpha: 0.15),
                      blurRadius: 14.0,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            enabled: enabled,
            obscureText: isPassword && !_isPasswordVisible,
            keyboardType: keyboardType,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 15.5,
              fontWeight: FontWeight.w500,
            ),
            cursorColor: const Color(0xFFE11D48),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 14.5,
              ),
              prefixIcon: Icon(
                prefixIcon,
                color: isFocused
                    ? const Color(0xFFE11D48)
                    : const Color(0xFF94A3B8),
                size: 20.0,
              ),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: const Color(0xFF94A3B8),
                        size: 20.0,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton({required bool isAnyLoading}) {
    return Container(
      width: double.infinity,
      height: 56.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.0),
        gradient: isAnyLoading
            ? const LinearGradient(
                colors: [Color(0xFF9F1239), Color(0xFF881337)],
              )
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF43F5E),
                  Color(0xFFE11D48),
                  Color(0xFFBE123C),
                ],
              ),
        boxShadow: isAnyLoading
            ? []
            : [
                BoxShadow(
                  color: const Color(0xFFE11D48).withValues(alpha: 0.38),
                  blurRadius: 20.0,
                  spreadRadius: 0,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28.0),
          onTap: isAnyLoading ? null : _handleRegister,
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 22.0,
                    height: 22.0,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Create Account',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      SizedBox(width: 8.0),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 20.0,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLink({required bool isAnyLoading}) {
    return Center(
      child: TextButton(
        onPressed: isAnyLoading
            ? null
            : () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
        child: RichText(
          text: const TextSpan(
            text: 'Already have an account? ',
            style: TextStyle(
              color: Color(0xFF475569),
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
            ),
            children: [
              TextSpan(
                text: 'Sign In',
                style: TextStyle(
                  color: Color(0xFFE11D48),
                  fontWeight: FontWeight.w800,
                ),
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
    final bool isAnyLoading = _isLoading || authProvider.isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Stack(
        children: [
          // Layer 1: Layered Architectural Photography Background & Gradient Scrim
          _buildBackgroundLayer(),

          // Layer 2: 100% Keyboard-Safe Scrollable Form Container
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20.0,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8.0),
                    _buildHeader(),
                    const SizedBox(height: 24.0),

                    // Layer 3: Floating Frosted Glass Card Container (BackdropFilter 18px blur)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0F000000),
                            blurRadius: 24.0,
                            spreadRadius: 0,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28.0),
                        child: BackdropFilter(
                          filter: ui.ImageFilter.blur(
                            sigmaX: 18.0,
                            sigmaY: 18.0,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(24.0),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.88),
                              borderRadius: BorderRadius.circular(28.0),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.30),
                                width: 1.0,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Role Switcher Title
                                const Text(
                                  'I AM JOINING AS A...',
                                  style: TextStyle(
                                    fontSize: 11.0,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(height: 12.0),

                                // Role Switcher Cards
                                Row(
                                  children: [
                                    _buildRoleCard(
                                      role: 'tenant',
                                      title: 'Tenant',
                                      subtitle: 'Seek Housing',
                                      icon: Icons.person_rounded,
                                    ),
                                    const SizedBox(width: 12.0),
                                    _buildRoleCard(
                                      role: 'landlord',
                                      title: 'Landlord',
                                      subtitle: 'List Property',
                                      icon: Icons.apartment_rounded,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24.0),

                                // Full Name Input
                                _buildInputField(
                                  label: 'Full Name',
                                  hintText: 'John Doe',
                                  controller: _nameController,
                                  focusNode: _nameFocusNode,
                                  prefixIcon: Icons.badge_outlined,
                                  keyboardType: TextInputType.name,
                                  enabled: !isAnyLoading,
                                ),
                                const SizedBox(height: 20.0),

                                // Email Input
                                _buildInputField(
                                  label: 'Email Address',
                                  hintText: 'name@example.com',
                                  controller: _emailController,
                                  focusNode: _emailFocusNode,
                                  prefixIcon: Icons.alternate_email_rounded,
                                  keyboardType: TextInputType.emailAddress,
                                  enabled: !isAnyLoading,
                                ),
                                const SizedBox(height: 20.0),

                                // Password Input
                                _buildInputField(
                                  label: 'Password',
                                  hintText: 'Min. 6 characters',
                                  controller: _passwordController,
                                  focusNode: _passwordFocusNode,
                                  prefixIcon: Icons.lock_outline_rounded,
                                  isPassword: true,
                                  enabled: !isAnyLoading,
                                ),
                                const SizedBox(height: 28.0),

                                // Massive Edge-to-Edge Ruby Red Button
                                _buildPrimaryButton(isAnyLoading: isAnyLoading),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),

                    // Login Link
                    _buildLoginLink(isAnyLoading: isAnyLoading),
                    const SizedBox(height: 20.0),
                  ]
                      .animate(interval: 80.ms)
                      .fade(duration: 400.ms)
                      .slideY(begin: 0.08, curve: Curves.easeOutQuad),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}