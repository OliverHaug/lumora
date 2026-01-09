<<<<<<< HEAD
import 'models/conversation_model.dart';
import 'local/inbox_local_datasource.dart';
=======
import 'local/inbox_local_datasource.dart';
import 'models/conversation_model.dart';
>>>>>>> 94ee73e (feat(inbox,chat): add realtime inbox/chat, caching and UX improvements)
import 'remote/inbox_remote_datasource.dart';

class InboxRepository {
  final InboxRemoteDataSource _remote;
  final InboxLocalDataSource _local;

  InboxRepository(this._remote, this._local);

<<<<<<< HEAD
=======
  int _compareLastMessageAtDesc(ConversationModel a, ConversationModel b) {
    final ad = a.lastMessageAt;
    final bd = b.lastMessageAt;

    if (ad == null && bd == null) return 0;
    if (ad == null) return 1;
    if (bd == null) return -1;

    return bd.compareTo(ad);
  }

>>>>>>> 94ee73e (feat(inbox,chat): add realtime inbox/chat, caching and UX improvements)
  Future<List<ConversationModel>> loadCachedConversations() {
    return _local.readConversations();
  }

  Future<List<ConversationModel>> syncConversations({int limit = 50}) async {
    final cached = await _local.readConversations();
<<<<<<< HEAD
    final lastSync = await _local.readLastSyncAt();

    final raw = await _remote.fetchConversations(
      limit: limit,
      updatedAfter: lastSync,
    );
    final incoming = raw.map(ConversationModel.fromMap).toList();

=======
    final raw = await _remote.fetchConversations(limit: limit);

    final incoming = raw.map(ConversationModel.fromMap).toList();

    // merge by id (incoming überschreibt cached)
>>>>>>> 94ee73e (feat(inbox,chat): add realtime inbox/chat, caching and UX improvements)
    final byId = {for (final c in cached) c.id: c};
    for (final c in incoming) {
      byId[c.id] = c;
    }

<<<<<<< HEAD
    final merged = byId.values.toList()
      ..sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
=======
    final merged = byId.values.toList()..sort(_compareLastMessageAtDesc);
>>>>>>> 94ee73e (feat(inbox,chat): add realtime inbox/chat, caching and UX improvements)

    await _local.writeConversations(merged);
    await _local.writeLastSyncAt(DateTime.now());

    return merged;
  }

  Future<List<ConversationModel>> searchLocal(String query) async {
    final q = query.trim().toLowerCase();
    final all = await _local.readConversations();
    if (q.isEmpty) return all;

<<<<<<< HEAD
    return all.where((c) {
      return c.peerUser.name.toLowerCase().contains(q) ||
          c.lastMessageText.toLowerCase().contains(q);
    }).toList();
=======
    final filtered = all.where((c) {
      return c.peerUser.name.toLowerCase().contains(q) ||
          c.lastMessageText.toLowerCase().contains(q);
    }).toList();

    filtered.sort(_compareLastMessageAtDesc);
    return filtered;
  }

  Future<String> getOrCreateDirectConnversation(String peerId) {
    return _remote.getOrCreateDirectConversation(peerId: peerId);
>>>>>>> 94ee73e (feat(inbox,chat): add realtime inbox/chat, caching and UX improvements)
  }
}
