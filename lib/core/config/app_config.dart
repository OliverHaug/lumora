import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // Prefer --dart-define for CI/Prod/Web
  static const supabaseUrlDefine = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonDefine = String.fromEnvironment('SUPABASE_ANON');

  static String? get supabaseUrl {
    if (supabaseUrlDefine.isNotEmpty) return supabaseUrlDefine;

    try {
      return dotenv.env['SUPABASE_URL'];
    } catch (_) {
      return null;
    }
  }

  static String? get supabaseAnonKey {
    if (supabaseAnonDefine.isNotEmpty) return supabaseAnonDefine;
    try {
      return dotenv.env['SUPABASE_ANON'];
    } catch (_) {
      return null;
    }
  }

  static bool get isDebug => kDebugMode;
}
