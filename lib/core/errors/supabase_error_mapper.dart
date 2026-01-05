import 'package:supabase_flutter/supabase_flutter.dart';
import 'failure.dart';

Failure mapSupabaseError(Object err) {
  // Auth
  if (err is AuthException) {
    return Failure(err.message, code: err.statusCode);
  }

  // Database / Postgrest
  if (err is PostgrestException) {
    return Failure(err.message, code: err.code);
  }

  // Storage etc.
  if (err is StorageException) {
    return Failure(err.message, code: err.statusCode);
  }

  // Fallback
  return Failure(err.toString());
}
