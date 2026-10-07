import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'features/auth/providers/auth_provider.dart';
import 'main.dart';

/// Task 2: Cinematic Flutter Splash Screen for EstarKo.
/// Seamlessly takes over from the native splash screen (same solid #E11D48 background and centered white logo)
/// eliminating the white flash, brings the brand to life with heartbeat scale, glowing radial aura,
/// and Plus Jakarta Sans typography, then cross-fades gracefully into AuthWrapper.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Seamless handoff: Remove the native splash screen as soon as Flutter renders the first frame
    FlutterNativeSplash.remove();
    _startSplashSequence();
  }

  Future<void> _startSplashSequence() async {
    // Cinematic viewing delay for animations to unfold
    await Future.delayed(const Duration(milliseconds: 2200));

    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Ensure AuthProvider has finished its startup verification if needed
    while (authProvider.isInitialLoading && mounted) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    if (!mounted) return;

    // Fluid cinematic cross-fade into the authenticated / login screen
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) {
          return const AuthWrapper();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            ),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE11D48), // Exact matching Ruby Red background
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background ambient radial glow
          Center(
            child: Container(
              width: 260.0,
              height: 260.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(begin: 0.9, end: 1.25, duration: 1400.ms, curve: Curves.easeInOut),
          ),

          // Centered Brand Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Stack with Pulsing Aura and Shimmer
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Glowing aura behind the logo
                    Container(
                      width: 140.0,
                      height: 140.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.30),
                            blurRadius: 36.0,
                            spreadRadius: 8.0,
                          ),
                        ],
                      ),
                    )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scaleXY(begin: 0.85, end: 1.15, duration: 1100.ms, curve: Curves.easeInOut),

                    // Centered EstarKo Logo (Heartbeat scale & shimmer)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(28.0),
                      child: Image.asset(
                        'assets/icon/app_icon.png',
                        width: 110.0,
                        height: 110.0,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 110.0,
                          height: 110.0,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE11D48),
                            borderRadius: BorderRadius.circular(28.0),
                            border: Border.all(color: Colors.white, width: 2.0),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.roofing_rounded,
                              color: Colors.white,
                              size: 56.0,
                            ),
                          ),
                        ),
                      ),
                    )
                        .animate()
                        .scale(
                          begin: const Offset(0.88, 0.88),
                          end: const Offset(1.0, 1.0),
                          duration: 700.ms,
                          curve: Curves.easeOutBack,
                        )
                        .shimmer(
                          delay: 450.ms,
                          duration: 1200.ms,
                          color: Colors.white.withValues(alpha: 0.45),
                        ),
                  ],
                ),

                const SizedBox(height: 28.0),

                // "EstarKo" Brand Typography in Plus Jakarta Sans
                Text(
                  'EstarKo',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 34.0,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.8,
                    color: Colors.white,
                    shadows: const [
                      Shadow(
                        color: Color(0x33000000),
                        blurRadius: 12.0,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 550.ms)
                    .slideY(
                      begin: 0.12,
                      end: 0,
                      delay: 300.ms,
                      duration: 550.ms,
                      curve: Curves.easeOutCubic,
                    ),

                const SizedBox(height: 6.0),

                // Micro uppercase tagline
                Text(
                  'FIND YOUR HAVEN',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.2,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 500.ms, duration: 500.ms)
                    .slideY(
                      begin: 0.12,
                      end: 0,
                      delay: 500.ms,
                      duration: 500.ms,
                      curve: Curves.easeOutCubic,
                    ),
              ],
            ),
          ),

          // Bottom minimal loading spinner
          Positioned(
            bottom: 48.0,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 20.0,
                height: 20.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withValues(alpha: 0.75),
                  ),
                ),
              ),
            )
                .animate()
                .fadeIn(delay: 750.ms, duration: 400.ms),
          ),
        ],
      ),
    );
  }
}
