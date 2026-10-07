import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../shared/widgets/estar_friendly_error.dart';
import '../providers/auth_provider.dart';
import 'register_screen.dart';

/// Premium iOS-grade Login Screen.
/// Features a layered architectural apartment background with an atmospheric scrim gradient,
/// radial vignette, a floating frosted glass card container (BackdropFilter 18px blur,
/// translucent white surface with hairline border and soft shadow), focus-animated inputs,
/// and an edge-to-edge Ruby Red (#E11D48) CTA button.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() => setState(() {}));
    _passwordFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (_isLoading || _isGoogleLoading || authProvider.isLoading) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      EstarFriendlyError.showSnackBar(
        context,
        null,
        customMessage: 'Please enter your email and password to sign in.',
      );
      return;
    }

    HapticFeedback.lightImpact();
    setState(() {
      _isLoading = true;
    });

    final success = await authProvider.login(email, password, context: context);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (!success) {
      EstarFriendlyError.showSnackBar(
        context,
        authProvider.errorMessage,
      );
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (_isLoading || _isGoogleLoading || authProvider.isLoading) return;

    HapticFeedback.lightImpact();
    setState(() {
      _isLoading = true;
      _isGoogleLoading = true;
    });

    final success = await authProvider.loginWithGoogle(context);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _isGoogleLoading = false;
    });

    if (!success && authProvider.errorMessage.isNotEmpty) {
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

  Widget _buildBrandHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // App badge emblem with frosted glass backdrop & ruby glow
        ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
            child: Container(
              width: 58.0,
              height: 58.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
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
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE11D48).withValues(alpha: 0.40),
                    blurRadius: 22.0,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.roofing_rounded,
                  color: Colors.white,
                  size: 32.0,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24.0),

        // Main Header
        const Text(
          'Welcome to EstarKo',
          style: TextStyle(
            fontSize: 34.0,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.2,
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
        const SizedBox(height: 8.0),

        // Subtitle
        const Text(
          'Find verified, safe housing near your campus or workplace.',
          style: TextStyle(
            fontSize: 15.0,
            fontWeight: FontWeight.w400,
            color: Color(0xFFE2E8F0),
            height: 1.45,
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
          onTap: isAnyLoading ? null : _handleLogin,
          child: Center(
            child: (_isLoading && !_isGoogleLoading)
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
                        'Sign In',
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

  Widget _buildOrDivider() {
    return const Row(
      children: [
        Expanded(
          child: Divider(
            color: Color(0xFFE2E8F0),
            thickness: 1.0,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'OR',
            style: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: Color(0xFF94A3B8),
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: Color(0xFFE2E8F0),
            thickness: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleButton({required bool isAnyLoading}) {
    return SizedBox(
      height: 54.0,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: isAnyLoading ? null : _handleGoogleSignIn,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF0F172A),
          side: const BorderSide(
            color: Color(0xFFE2E8F0),
            width: 1.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28.0),
          ),
          elevation: 0,
        ),
        child: _isGoogleLoading
            ? const SizedBox(
                width: 22.0,
                height: 22.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE11D48)),
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.g_mobiledata,
                    size: 32.0,
                    color: Color(0xFF0F172A),
                  ),
                  SizedBox(width: 8.0),
                  Text(
                    'Continue with Google',
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildRegisterLink({required bool isAnyLoading}) {
    return Center(
      child: TextButton(
        onPressed: isAnyLoading
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegisterScreen(),
                  ),
                );
              },
        child: RichText(
          text: const TextSpan(
            text: "Don't have an account? ",
            style: TextStyle(
              color: Color(0xFF475569),
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
            ),
            children: [
              TextSpan(
                text: 'Create Account',
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
                    const SizedBox(height: 12.0),

                    // Header & Crest
                    _buildBrandHeader(),
                    const SizedBox(height: 32.0),

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
                                  hintText: 'Enter your password',
                                  controller: _passwordController,
                                  focusNode: _passwordFocusNode,
                                  prefixIcon: Icons.lock_outline_rounded,
                                  isPassword: true,
                                  enabled: !isAnyLoading,
                                ),
                                const SizedBox(height: 28.0),

                                // Massive Edge-to-Edge Ruby Red Button
                                _buildPrimaryButton(isAnyLoading: isAnyLoading),
                                const SizedBox(height: 20.0),

                                // OR Divider
                                _buildOrDivider(),
                                const SizedBox(height: 20.0),

                                // Continue with Google Button
                                _buildGoogleButton(isAnyLoading: isAnyLoading),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24.0),

                    // Register Link
                    _buildRegisterLink(isAnyLoading: isAnyLoading),
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