import 'package:flutter/material.dart';

/// Production iOS-grade styled text field adhering to the EstarKo UI/UX design system.
///
/// Features clean rounded borders, smooth active focus state with Ruby Red accent,
/// disabled states, and clean typography.
class EstarTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool? enabled;
  final int? maxLines;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const EstarTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.enabled,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final isFieldEnabled = enabled ?? true;

    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      validator: validator,
      enabled: enabled,
      maxLines: isPassword ? 1 : maxLines,
      style: TextStyle(
        fontSize: 15.0,
        fontWeight: FontWeight.w500,
        color: isFieldEnabled
            ? const Color(0xFF0F172A)
            : const Color(0xFF94A3B8),
      ),
      cursorColor: const Color(0xFFE11D48),
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        hintStyle: const TextStyle(
          color: Color(0xFF94A3B8),
          fontSize: 14.5,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: isFieldEnabled
            ? const Color(0xFFF8FAFC)
            : const Color(0xFFF1F5F9),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18.0,
          vertical: 16.0,
        ),
        border: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color(0xFFE2E8F0),
            width: 1.2,
          ),
          borderRadius: BorderRadius.circular(16.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color(0xFFE2E8F0),
            width: 1.2,
          ),
          borderRadius: BorderRadius.circular(16.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color(0xFFE11D48),
            width: 1.8,
          ),
          borderRadius: BorderRadius.circular(16.0),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color(0xFFE2E8F0),
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(16.0),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color(0xFFE11D48),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(16.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color(0xFFE11D48),
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
    );
  }
}
