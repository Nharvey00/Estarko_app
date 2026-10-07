import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Reusable keyboard-safe sticky bottom bar component adhering to the EstarKo UI/UX design system.
///
/// Features iOS-grade glassmorphism (BackdropFilter), ultra-soft diffused top shadow,
/// and safe anchoring above navigation bars and keyboards so primary CTAs are never obscured.
class EstarStickyBottomBar extends StatelessWidget {
  /// The primary button or action widget(s) to render in the sticky bar.
  final Widget child;

  /// Optional padding around the child. Defaults to 24 horizontal and 12 vertical.
  final EdgeInsetsGeometry padding;

  /// Background color of the bar. Defaults to translucent white for frosted glass.
  final Color? backgroundColor;

  /// Whether to display a subtle diffused top shadow separating the bar from scrolling content.
  final bool showShadow;

  /// Optional top widget, such as terms text, total price, or helper hints.
  final Widget? topWidget;

  /// Whether to apply glassmorphic backdrop blur. Defaults to true.
  final bool isGlass;

  const EstarStickyBottomBar({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
    this.backgroundColor,
    this.showShadow = true,
    this.topWidget,
    this.isGlass = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBgColor = backgroundColor ??
        (isGlass
            ? Colors.white.withValues(alpha: 0.88)
            : Colors.white);

    Widget content = Container(
      decoration: BoxDecoration(
        color: effectiveBgColor,
        boxShadow: showShadow
            ? const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 24.0,
                  offset: Offset(0, -6),
                ),
              ]
            : null,
        border: Border(
          top: BorderSide(
            color: isGlass
                ? Colors.white.withValues(alpha: 0.70)
                : const Color(0xFFF1F5F9),
            width: 1.0,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        left: true,
        right: true,
        bottom: true,
        child: Padding(
          padding: padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (topWidget != null) ...[
                topWidget!,
                const SizedBox(height: 10.0),
              ],
              child,
            ],
          ),
        ),
      ),
    );

    if (isGlass) {
      return ClipRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
          child: content,
        ),
      );
    }

    return content;
  }
}
