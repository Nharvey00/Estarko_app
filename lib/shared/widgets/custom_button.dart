import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Premium button adhering strictly to the EstarKo UI/UX design system.
///
/// Features:
/// - Stadium border (fully rounded pill).
/// - Instant tap feedback with haptic response.
/// - Integrated high-performance loading state with zero layout shift.
/// - Soft glowing diffused shadow for primary actions (#E11D48).
/// - Support for Outlined and Filled variants with optional icons.
class EstarButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final double height;
  final double width;
  final double? fontSize;
  final bool enableHaptics;

  const EstarButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isOutlined = false,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.height = 56.0,
    this.width = double.infinity,
    this.fontSize,
    this.enableHaptics = true,
  });

  void _handleTap() {
    if (isLoading || onPressed == null) return;
    if (enableHaptics) {
      HapticFeedback.lightImpact();
    }
    onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    const primaryRuby = Color(0xFFE11D48);
    final effectiveBg = backgroundColor ??
        (isOutlined ? Colors.white : primaryRuby);
    final effectiveFg = foregroundColor ??
        (isOutlined ? const Color(0xFF111827) : Colors.white);
    final effectiveBorder = borderColor ??
        (isOutlined ? const Color(0xFFE2E8F0) : Colors.transparent);

    final bool isEnabled = onPressed != null && !isLoading;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height / 2),
        boxShadow: (!isOutlined && isEnabled)
            ? [
                BoxShadow(
                  color: primaryRuby.withValues(alpha: 0.25),
                  blurRadius: 16.0,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Material(
        color: isEnabled
            ? effectiveBg
            : (isOutlined ? Colors.white : const Color(0xFFCBD5E1)),
        shape: StadiumBorder(
          side: isOutlined
              ? BorderSide(
                  color: isEnabled
                      ? effectiveBorder
                      : const Color(0xFFE2E8F0),
                  width: 1.2,
                )
              : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: isEnabled ? _handleTap : null,
          splashColor: isOutlined
              ? primaryRuby.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.2),
          highlightColor: isOutlined
              ? primaryRuby.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: isLoading
                  ? SizedBox(
                      key: const ValueKey('button_loading'),
                      width: 24.0,
                      height: 24.0,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isOutlined ? primaryRuby : Colors.white,
                        ),
                      ),
                    )
                  : Row(
                      key: const ValueKey('button_content'),
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          icon!,
                          const SizedBox(width: 8.0),
                        ],
                        Flexible(
                          child: Text(
                            text,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: fontSize ?? 15.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                              color: isEnabled
                                  ? effectiveFg
                                  : (isOutlined
                                      ? const Color(0xFF94A3B8)
                                      : Colors.white),
                            ),
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
}
