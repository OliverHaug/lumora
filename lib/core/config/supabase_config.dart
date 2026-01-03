import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:xyz/core/config/app_config.dart';

class SupabaseConfig {
  static Future<void> init() async {
    final url = AppConfig.supabaseUrl;
    final anonKey = AppConfig.supabaseAnonKey;

    if (url == null || anonKey == null) {
      throw Exception(
        'Missing SUPABASE_URL or SUPABASE_ANON. '
        'Provide via --dart-define or local .env',
      );
    }

    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
        autoRefreshToken: true,
        detectSessionInUri: true,
      ),
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
