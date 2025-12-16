import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;


  Future<void> login({
    required String email,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

 
  Future<void> signUp({
  required String email,
  required String password,
  required String username,
}) async {
  await _client.auth.signUp(
    email: email,
    password: password,
    data: {
      'username': username,
    },
  );
}



  Future<void> logout() async {
    await _client.auth.signOut();
  }



  User? get currentUser => _client.auth.currentUser;
}
