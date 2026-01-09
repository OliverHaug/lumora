import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:xyz/core/errors/result.dart';
import 'package:xyz/core/errors/supabase_error_mapper.dart';

class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  Stream<AuthState> authStateChanges() => _client.auth.onAuthStateChange;

  User? get currentUser => _client.auth.currentUser;

  Future<Result<void>> signIn({
    required String email,
    required String password,
  }) async {
    switch (email) {
      case 'admin':
        email = 'admin@xyz.local';
        break;
      case 'jennifer':
        email = 'jennifer.admin@xyz.de';
        break;
      case 'oliver':
        email = 'oliver.admin@xyz.de';
        break;
    }

    try {
      await _client.auth.signInWithPassword(email: email, password: password);
      return const Success(null);
    } catch (e) {
      return Error(mapSupabaseError(e));
    }
  }

  Future<Result<void>> signUp({
    required String email,
    required String password,
  }) async {
    try {
      await _client.auth.signUp(email: email, password: password);
      return const Success(null);
    } catch (e) {
      return Error(mapSupabaseError(e));
    }
  }

  Future<Result<void>> signOut() async {
    try {
      await _client.auth.signOut();
      return const Success(null);
    } catch (e) {
      return Error(mapSupabaseError(e));
    }
  }
}
