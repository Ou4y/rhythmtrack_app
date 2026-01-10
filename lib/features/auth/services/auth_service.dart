import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      final m = e.message.toLowerCase();

      if (m.contains('email not confirmed')) {
        throw 'Please verify your email first.';
      }

      throw 'Email or password is incorrect.';
    }
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      return await _client.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );
    } on AuthException catch (e) {
      final m = e.message.toLowerCase();

      if (m.contains('user already registered')) {
        throw 'This email is already registered.';
      }

      if (m.contains('password')) {
        throw 'Password is too weak (min 6 characters).';
      }

      throw 'Signup failed. Please try again.';
    }
  }

  Future<void> logout() async {
    await _client.auth.signOut();
  }

  User? get currentUser => _client.auth.currentUser;
}
