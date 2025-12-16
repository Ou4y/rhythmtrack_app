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
    final response = await _client.auth.signUp(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null) {
      throw Exception('User not created');
    }

    
    await _client.from('profiles').insert({
      'id': user.id,
      'email': email,
      'username': username,
    });
  }


  Future<void> logout() async {
    await _client.auth.signOut();
  }



  User? get currentUser => _client.auth.currentUser;
}
