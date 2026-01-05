import 'package:flutter/foundation.dart';

class AppConfig {
  static const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  static const _supabaseAnon = String.fromEnvironment('SUPABASE_ANON');

  static String get supabaseUrl {
    if (_supabaseUrl.isEmpty) {
      throw const MissingConfigException('SUPABASE_URL');
    }
    return _supabaseUrl;
  }

  static String get supabaseAnonKey {
    if (_supabaseAnon.isEmpty) {
      throw const MissingConfigException('SUPABASE_ANON');
    }
    return _supabaseAnon;
  }

  static bool get isDebug => kDebugMode;
}

class MissingConfigException implements Exception {
  final String key;
  const MissingConfigException(this.key);

  @override
  String toString() =>
      'Missing required compile-time config: $key '
      '(provide via --dart-define=$key=...)';
}
