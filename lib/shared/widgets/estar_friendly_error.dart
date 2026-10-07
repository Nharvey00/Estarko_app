import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'custom_button.dart';

/// Production UX utility for polite, friendly error masking and graceful states.
class EstarFriendlyError {
  /// Converts raw Firebase/Firestore/network exceptions into warm, human-friendly strings.
  /// Never exposes raw stack traces, [cloud_firestore] tags, or cryptic codes to the user.
  static String mask(dynamic error) {
    if (error == null) return 'Something went wrong. Please try again.';

    // If already a clean, friendly string (e.g. from validation), return as-is
    if (error is String &&
        !error.toLowerCase().contains('exception') &&
        !error.toLowerCase().contains('error:') &&
        !error.contains('[')) {
      return error;
    }

    final errorStr = error.toString().toLowerCase();

    // Network & connectivity errors
    if (error is SocketException ||
        errorStr.contains('socketexception') ||
        errorStr.contains('network') ||
        errorStr.contains('connection') ||
        errorStr.contains('unavailable') ||
        errorStr.contains('offline') ||
        errorStr.contains('clientexception')) {
      return "We couldn't connect right now. Please check your internet connection.";
    }

    // Permission & Firestore rules
    if (errorStr.contains('permission-denied') ||
        errorStr.contains('insufficient-permission')) {
      return "You don't have permission to access this right now.";
    }

    // Firebase Auth errors
    if (errorStr.contains('user-not-found') ||
        errorStr.contains('wrong-password') ||
        errorStr.contains('invalid-credential')) {
      return 'Incorrect email or password. Please verify your credentials.';
    }

    if (errorStr.contains('email-already-in-use')) {
      return 'An account with this email address already exists.';
    }

    if (errorStr.contains('weak-password')) {
      return 'Please choose a stronger password with at least 6 characters.';
    }

    if (errorStr.contains('too-many-requests')) {
      return 'Too many attempts. Please wait a few moments and try again.';
    }

    if (errorStr.contains('requires-recent-login')) {
      return 'For your security, please sign in again before proceeding.';
    }

    if (errorStr.contains('not-found') || errorStr.contains('does not exist')) {
      return 'The requested information could not be found.';
    }

    // Default polite fallback
    return 'We were unable to complete your request. Please try again in a moment.';
  }

  /// Displays a standardized floating snackbar with polite error message
  static void showSnackBar(
    BuildContext context,
    dynamic error, {
    String? customMessage,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final message = customMessage ?? mask(error);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.info_outline_rounded,
              color: Colors.white,
              size: 20.0,
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFE11D48),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.0),
        ),
        margin: const EdgeInsets.all(16.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        action: (actionLabel != null && onAction != null)
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }

  /// Displays a standardized floating snackbar with polite success message
  static void showSuccessSnackBar(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 20.0,
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.0),
        ),
        margin: const EdgeInsets.all(16.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      ),
    );
  }
}

/// Reusable illustrated error state view with polite copy and retry CTA.
class EstarErrorView extends StatelessWidget {
  final dynamic error;
  final String? title;
  final String? message;
  final VoidCallback? onRetry;
  final String retryText;

  const EstarErrorView({
    super.key,
    this.error,
    this.title,
    this.message,
    this.onRetry,
    this.retryText = 'Try Again',
  });

  @override
  Widget build(BuildContext context) {
    final effectiveMessage = message ?? EstarFriendlyError.mask(error);
    final effectiveTitle = title ?? 'Unable to Load';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Soft glowing circular icon badge
            Container(
              width: 80.0,
              height: 80.0,
              decoration: BoxDecoration(
                color: const Color(0xFFE11D48).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                color: Color(0xFFE11D48),
                size: 38.0,
              ),
            ),
            const SizedBox(height: 20.0),

            // Friendly Title
            Text(
              effectiveTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8.0),

            // Friendly polite message
            Text(
              effectiveMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),

            if (onRetry != null) ...[
              const SizedBox(height: 24.0),
              SizedBox(
                width: 180.0,
                child: EstarButton(
                  text: retryText,
                  height: 48.0,
                  onPressed: onRetry,
                ),
              ),
            ],
          ],
        )
            .animate()
            .fade(duration: 350.ms)
            .slideY(begin: 0.08, curve: Curves.easeOutQuad),
      ),
    );
  }
}

/// Reusable illustrated empty state view for empty lists or zero-search results.
class EstarEmptyStateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onAction;

  const EstarEmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80.0,
              height: 80.0,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: const Color(0xFF64748B),
                size: 36.0,
              ),
            ),
            const SizedBox(height: 20.0),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.grey.shade500,
                height: 1.4,
              ),
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 24.0),
              SizedBox(
                width: 200.0,
                child: EstarButton(
                  text: actionText!,
                  height: 48.0,
                  onPressed: onAction,
                ),
              ),
            ],
          ],
        )
            .animate()
            .fade(duration: 350.ms)
            .slideY(begin: 0.08, curve: Curves.easeOutQuad),
      ),
    );
  }
}
