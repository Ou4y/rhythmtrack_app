import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/auth_textfield.dart';
import '../widgets/primary_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _hidePassword = true;
  bool _hideConfirm = true;
  bool _isLoading = false;

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await AuthService().signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        username: usernameController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Check your email to verify your account'),
        ),
      );

      Navigator.pop(context); // back to login
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // ✅ theme driven
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: theme.iconTheme,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primary.withOpacity(0.08),
              colorScheme.secondary.withOpacity(0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.cardColor.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.10),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    AuthTextField(
                      controller: usernameController,
                      hint: 'Username',
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Username required' : null,
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      controller: emailController,
                      hint: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) =>
                          v == null || !v.contains('@')
                              ? 'Invalid email'
                              : null,
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      controller: passwordController,
                      hint: 'Password',
                      obscure: _hidePassword,
                      validator: (v) =>
                          v == null || v.length < 6
                              ? 'Password must be at least 6 characters'
                              : null,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _hidePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () =>
                            setState(() => _hidePassword = !_hidePassword),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      controller: confirmPasswordController,
                      hint: 'Confirm Password',
                      obscure: _hideConfirm,
                      validator: (v) =>
                          v != passwordController.text
                              ? 'Passwords do not match'
                              : null,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _hideConfirm
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () =>
                            setState(() => _hideConfirm = !_hideConfirm),
                      ),
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      text: _isLoading ? 'Creating account...' : 'Create Account',
                      onPressed: _isLoading
                          ? null
                          : () {
                              _signup();
                            },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}