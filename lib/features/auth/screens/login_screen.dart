import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final bool obscure;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.obscure = false,
    this.validator,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      validator: validator,
      cursorColor: colorScheme.primary,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        // ✅ REAL LABEL
        labelText: hint,

        // ❗ REQUIRED for filled white fields
        floatingLabelBehavior: FloatingLabelBehavior.auto,

        // Field background (your UI)
        filled: true,
        fillColor: Colors.white,

        // ✅ KEY FIX: readable floating label
        floatingLabelStyle: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.w600,
          backgroundColor: Colors.white, // <-- THIS fixes invisibility
        ),

        labelStyle: TextStyle(
          color: colorScheme.onSurface.withOpacity(0.6),
        ),

        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 1.4,
          ),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: colorScheme.error,
          ),
        ),

        suffixIcon: suffixIcon,
      ),
    );
  }
}