import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lumora/core/config/app_config.dart';

class SupabaseConfig {
  static Future<void> init() async {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );
  }
}
