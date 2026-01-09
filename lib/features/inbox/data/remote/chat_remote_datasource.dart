import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lumora/features/inbox/data/models/message_model.dart';

class ChatRemoteDataSource {
  final SupabaseClient _client;
  ChatRemoteDataSource(this._client);

  /// ✅ RPC: messages_page (neueste zuerst, DESC)
  Future<List<MessageModel>> fetchPage({
    required String conversationId,
    DateTime? beforeTs,
    int limit = 50,
  }) async {
    final res = await _client.rpc(
      'messages_page',
      params: {
        'p_conversation_id': conversationId,
        'before_ts': beforeTs?.toIso8601String(),
        'limit_count': limit,
      },
    );

    final list = (res as List).cast<Map<String, dynamic>>();
    return list.map(MessageModel.fromMap).toList();
  }

  /// ✅ Nur neue Messages seit letztem lokalen Timestamp laden (Traffic-sparend)
  Future<List<MessageModel>> fetchNewerThan({
    required String conversationId,
    required DateTime afterTs,
    int limit = 200,
  }) async {
    final res = await _client
        .from('messages')
        .select('id, conversation_id, sender_id, body, created_at')
        .eq('conversation_id', conversationId)
        .gt('created_at', afterTs.toIso8601String())
        .order('created_at', ascending: true) // ASC fürs Merge
        .limit(limit);

    final list = (res as List).cast<Map<String, dynamic>>();
    return list.map(MessageModel.fromMap).toList();
  }

  Future<MessageModel> sendMessage({
    required String conversationId,
    required String body,
    String? senderIdOverride,
  }) async {
    final user = _client.auth.currentUser;
    final senderId = senderIdOverride ?? user?.id;
    if (senderId == null) {
      throw Exception('Not authenticated');
    }

    final inserted = await _client
        .from('messages')
        .insert({
          'conversation_id': conversationId,
          'sender_id': senderId,
          'body': body,
        })
        .select('id, conversation_id, sender_id, body, created_at')
        .single();

    return MessageModel.fromMap(inserted);
  }

  Future<void> markConversationRead({required String conversationId}) async {
    await _client.rpc(
      'mark_conversation_read',
      params: {'p_conversation_id': conversationId},
    );
  }
}
