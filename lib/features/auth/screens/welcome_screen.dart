import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import '../widgets/primary_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFFFF7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),

              // Logo image
              Image.asset(
                'assets/images/welcome_wave.png',
                height: 180, // same height as before
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 28),

              // Title
              Text(
                'RhythmTrack',
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                  color: const Color(0xFF0F172A),
                ),
              ),

              const SizedBox(height: 10),

              // Subtitle text
              Text(
                'Your daily rhythm starts here.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: const Color(0xFF64748B),
                ),
              ),

          const SizedBox(height: 160),

              // Create Account button
              PrimaryButton(
                text: 'Create Account',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SignupScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 14),

              // Login link
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(),
                    ),
                  );
                },
                child: Text(
                  'Already have an account? Log in',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF0284C7),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
