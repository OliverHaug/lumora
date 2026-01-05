import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final sessionProvider = StreamProvider<Session?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.onAuthStateChange.map((event) => event.session);
});

final currentSessionProvider = Provider<Session?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.currentSession;
});
