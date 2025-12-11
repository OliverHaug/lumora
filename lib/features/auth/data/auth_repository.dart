import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _client;
  AuthRepository(this._client);

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) {
    if (email == 'admin') {
      email = 'admin@xyz.local';
    }
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> register(String email, String password) =>
      _client.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: 'myapp://auth-callback',
      );

  Future<void> resetPassword(String email) =>
      _client.auth.resetPasswordForEmail(email);

  Future<void> signOut() => _client.auth.signOut();
}
