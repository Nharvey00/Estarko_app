import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Item definition for the floating iOS-style navigation dock
class EstarDockItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const EstarDockItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

/// Floating, pill-shaped navigation dock inspired by iOS island and Dribbble designs.
/// Features glassmorphism (backdrop blur), dual diffused shadows, and sleek Ruby Red active indicators.
class EstarFloatingNavDock extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<EstarDockItem> items;

  const EstarFloatingNavDock({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380.0),
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40.0),
          boxShadow: [
            // Deep ambient shadow
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 30.0,
              spreadRadius: 0,
              offset: const Offset(0, 10),
            ),
            // Soft Ruby glow
            BoxShadow(
              color: const Color(0xFFE11D48).withValues(alpha: 0.10),
              blurRadius: 20.0,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40.0),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 24.0, sigmaY: 24.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(40.0),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.65),
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(items.length, (index) {
                  final item = items[index];
                  final isSelected = currentIndex == index;

                  return _buildDockTab(
                    item: item,
                    isSelected: isSelected,
                    onTap: () {
                      if (!isSelected) {
                        HapticFeedback.selectionClick();
                        onTap(index);
                      }
                    },
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDockTab({
    required EstarDockItem item,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFE11D48).withValues(alpha: 0.10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(28.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 200),
              scale: isSelected ? 1.08 : 1.0,
              curve: Curves.easeOutBack,
              child: Icon(
                isSelected ? item.activeIcon : item.icon,
                size: 22.0,
                color: isSelected
                    ? const Color(0xFFE11D48)
                    : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 3.0),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 11.0,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                letterSpacing: -0.2,
                color: isSelected
                    ? const Color(0xFFE11D48)
                    : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 2.0),
            // Sleek Ruby dot indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 4.0 : 0.0,
              height: isSelected ? 4.0 : 0.0,
              decoration: const BoxDecoration(
                color: Color(0xFFE11D48),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
