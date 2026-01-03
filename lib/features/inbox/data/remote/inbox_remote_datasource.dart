import 'package:supabase_flutter/supabase_flutter.dart';

class InboxRemoteDataSource {
  final SupabaseClient _client;
  InboxRemoteDataSource(this._client);

  Future<List<Map<String, dynamic>>> fetchConversations({
    required int limit,
    DateTime? updatedAfter,
  }) async {
    final res = await _client.rpc(
      'get_conversations',
      params: {
        'limit_count': limit,
        'updated_after': updatedAfter?.toIso8601String(),
      },
    );

    return (res as List).cast<Map<String, dynamic>>();
  }
}
