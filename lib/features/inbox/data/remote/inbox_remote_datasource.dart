import 'package:supabase_flutter/supabase_flutter.dart';

class InboxRemoteDataSource {
  final SupabaseClient _client;
  InboxRemoteDataSource(this._client);

<<<<<<< HEAD
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
=======
  /// RPC: get_conversations(limit_count, updated_after)
  /// Muss List<Map> zurückgeben.
  Future<List<Map<String, dynamic>>> fetchConversations({
    required int limit,
  }) async {
    final res = await _client.rpc(
      'inbox_conversations',
      params: {'limit_count': limit},
>>>>>>> 94ee73e (feat(inbox,chat): add realtime inbox/chat, caching and UX improvements)
    );

    return (res as List).cast<Map<String, dynamic>>();
  }
<<<<<<< HEAD
=======

  /// Global unread count (inbox badge)
  Future<int> fetchUnreadTotal() async {
    final user = _client.auth.currentUser;
    if (user == null) return 0;

    final res = await _client.rpc('inbox_unread_total');
    if (res is int) return res;

    return int.tryParse(res.toString()) ?? 0;
  }

  Future<String> getOrCreateDirectConversation({required String peerId}) async {
    final res = await _client.rpc(
      'get_or_create_direct_conversation',
      params: {'peer_id': peerId},
    );

    if (res is String) return res;

    return res.toString();
  }
>>>>>>> 94ee73e (feat(inbox,chat): add realtime inbox/chat, caching and UX improvements)
}
