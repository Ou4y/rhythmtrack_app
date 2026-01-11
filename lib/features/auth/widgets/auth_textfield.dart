import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final TextInputType keyboardType;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.validator,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      keyboardType: keyboardType,
      cursorColor: colorScheme.primary,

      // ✅ FORCE readable input text
      style: theme.textTheme.bodyLarge?.copyWith(
        color: colorScheme.onSurface,
      ),

      decoration: InputDecoration(
        // ✅ Use label, not hint (better UX)
        labelText: hint,
        floatingLabelBehavior: FloatingLabelBehavior.auto,

        // ✅ Respect theme surface color
        filled: true,
        fillColor: colorScheme.surface,

        // ✅ Readable labels
        labelStyle: TextStyle(
          color: colorScheme.onSurface.withOpacity(0.7),
        ),
        floatingLabelStyle: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.w600,
          backgroundColor: colorScheme.surface,
        ),

        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 1.4,
          ),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: colorScheme.error,
          ),
        ),

        suffixIcon: suffixIcon,
      ),
    );
  }
}