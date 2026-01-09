import 'local/inbox_local_datasource.dart';
import 'models/conversation_model.dart';
import 'remote/inbox_remote_datasource.dart';

class InboxRepository {
  final InboxRemoteDataSource _remote;
  final InboxLocalDataSource _local;

  InboxRepository(this._remote, this._local);

  int _compareLastMessageAtDesc(ConversationModel a, ConversationModel b) {
    final ad = a.lastMessageAt;
    final bd = b.lastMessageAt;

    if (ad == null && bd == null) return 0;
    if (ad == null) return 1;
    if (bd == null) return -1;

    return bd.compareTo(ad);
  }

  Future<List<ConversationModel>> loadCachedConversations() {
    return _local.readConversations();
  }

  Future<List<ConversationModel>> syncConversations({int limit = 50}) async {
    final cached = await _local.readConversations();
    final raw = await _remote.fetchConversations(limit: limit);

    final incoming = raw.map(ConversationModel.fromMap).toList();

    // merge by id (incoming überschreibt cached)
    final byId = {for (final c in cached) c.id: c};
    for (final c in incoming) {
      byId[c.id] = c;
    }

    final merged = byId.values.toList()..sort(_compareLastMessageAtDesc);

    await _local.writeConversations(merged);
    await _local.writeLastSyncAt(DateTime.now());

    return merged;
  }

  Future<List<ConversationModel>> searchLocal(String query) async {
    final q = query.trim().toLowerCase();
    final all = await _local.readConversations();
    if (q.isEmpty) return all;

    final filtered = all.where((c) {
      return c.peerUser.name.toLowerCase().contains(q) ||
          c.lastMessageText.toLowerCase().contains(q);
    }).toList();

    filtered.sort(_compareLastMessageAtDesc);
    return filtered;
  }

  Future<String> getOrCreateDirectConnversation(String peerId) {
    return _remote.getOrCreateDirectConversation(peerId: peerId);
  }
}
