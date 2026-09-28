import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email and password.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(email, password);

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage.isNotEmpty
              ? authProvider.errorMessage
              : 'Login failed. Please verify your credentials.'),
          backgroundColor: const Color(0xFFE11D48),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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

            // Form Content overlapping image fade
            Padding(
              padding: EdgeInsets.only(
                top: imageHeight - 48.0,
                left: AppConstants.defaultPadding,
                right: AppConstants.defaultPadding,
                bottom: 32.0,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main Header
                    const Text(
                      'Welcome to EstarKo',
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
                      'Find verified, safe housing near your campus or workplace.',
                      style: TextStyle(
                        fontSize: 15.0,
                        color: Colors.grey.shade500,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 32.0),

                    // Email Field
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

                    // Password Field
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
                      hintText: 'Enter your password',
                      isPassword: true,
                    ),
                    const SizedBox(height: 32.0),

                    // Login Button
                    EstarButton(
                      text: 'Sign In',
                      isLoading: authProvider.isLoading,
                      onPressed: _handleLogin,
                    ),
                    const SizedBox(height: 20.0),

                    // Navigation to Register
                    Center(
                      child: TextButton(
                        onPressed: () {
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
                              color: Color(0xFF64748B),
                              fontSize: 14.0,
                            ),
                            children: [
                              TextSpan(
                                text: 'Create Account',
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