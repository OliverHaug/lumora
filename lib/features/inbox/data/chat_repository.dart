import 'package:lumora/features/inbox/data/models/message_model.dart';
import 'package:lumora/features/inbox/data/remote/chat_local_datasource.dart';
import 'package:lumora/features/inbox/data/remote/chat_remote_datasource.dart';

class ChatRepository {
  final ChatRemoteDataSource _remote;
  final ChatLocalDataSource _local;

  ChatRepository(this._remote, this._local);

  Future<List<MessageModel>> loadCached(String conversationId) {
    return _local.readMessages(conversationId);
  }

  /// ✅ WhatsApp-like:
  /// - erst Cache
  /// - dann nur neue Messages seit latest_ts
  /// - wenn noch nie gecached: initial page (messages_page)
  Future<List<MessageModel>> syncLatest(
    String conversationId, {
    int initialLimit = 50,
  }) async {
    final cached = await _local.readMessages(conversationId);
    final latestTs = await _local.readLatestTs(conversationId);

    List<MessageModel> incoming;

    if (latestTs == null) {
      // 처음: initial page
      incoming = await _remote.fetchPage(
        conversationId: conversationId,
        beforeTs: null,
        limit: initialLimit,
      );
    } else {
      // nur neue seit latestTs
      incoming = await _remote.fetchNewerThan(
        conversationId: conversationId,
        afterTs: latestTs,
      );
    }

    final merged = _mergeUniqueDesc(cached, incoming);
    await _local.writeMessages(conversationId, merged);
    return merged;
  }

  /// ✅ Ältere Nachrichten holen (Scroll nach oben)
  Future<List<MessageModel>> fetchOlder(
    String conversationId, {
    int limit = 50,
  }) async {
    final cached = await _local.readMessages(conversationId);
    if (cached.isEmpty) {
      // fallback: initial
      final initial = await _remote.fetchPage(
        conversationId: conversationId,
        beforeTs: null,
        limit: limit,
      );
      await _local.writeMessages(conversationId, initial);
      return initial;
    }

    final oldest = cached.last.createdAt; // DESC → last = oldest
    final older = await _remote.fetchPage(
      conversationId: conversationId,
      beforeTs: oldest,
      limit: limit,
    );

    final merged = _mergeUniqueDesc(cached, older);
    await _local.writeMessages(conversationId, merged);
    return merged;
  }

  Future<MessageModel> sendMessage({
    required String conversationId,
    required String body,
    String? senderIdOverride,
  }) async {
    final msg = await _remote.sendMessage(
      conversationId: conversationId,
      body: body,
      senderIdOverride: senderIdOverride,
    );

    final cached = await _local.readMessages(conversationId);
    final merged = _mergeUniqueDesc(cached, [msg]);
    await _local.writeMessages(conversationId, merged);

    return msg;
  }

  Future<void> markRead(String conversationId) {
    return _remote.markConversationRead(conversationId: conversationId);
  }

  List<MessageModel> _mergeUniqueDesc(
    List<MessageModel> a,
    List<MessageModel> b,
  ) {
    final byId = <String, MessageModel>{};

    for (final m in a) {
      byId[m.id] = m;
    }
    for (final m in b) {
      byId[m.id] = m;
    }

    final merged = byId.values.toList()
      ..sort((x, y) => y.createdAt.compareTo(x.createdAt)); // DESC
    return merged;
  }
}
