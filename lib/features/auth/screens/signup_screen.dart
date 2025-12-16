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

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await AuthService().signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        username: usernameController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Check your email to verify account')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
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
    return Scaffold(
      backgroundColor: const Color(0xFFEFFFF7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      v == null || !v.contains('@') ? 'Invalid email' : null,
                ),

                const SizedBox(height: 16),

                AuthTextField(
                  controller: passwordController,
                  hint: 'Password',
                  obscure: _hidePassword,
                  validator: (v) =>
                      v == null || v.length < 6 ? 'Weak password' : null,
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
                  text: 'Create Account',
                  onPressed: _signup,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
