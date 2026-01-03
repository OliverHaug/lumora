import 'models/conversation_model.dart';
import 'local/inbox_local_datasource.dart';
import 'remote/inbox_remote_datasource.dart';

class InboxRepository {
  final InboxRemoteDataSource _remote;
  final InboxLocalDataSource _local;

  InboxRepository(this._remote, this._local);

  Future<List<ConversationModel>> loadCachedConversations() {
    return _local.readConversations();
  }

  Future<List<ConversationModel>> syncConversations({int limit = 50}) async {
    final cached = await _local.readConversations();
    final lastSync = await _local.readLastSyncAt();

    final raw = await _remote.fetchConversations(
      limit: limit,
      updatedAfter: lastSync,
    );
    final incoming = raw.map(ConversationModel.fromMap).toList();

    final byId = {for (final c in cached) c.id: c};
    for (final c in incoming) {
      byId[c.id] = c;
    }

    final merged = byId.values.toList()
      ..sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));

    await _local.writeConversations(merged);
    await _local.writeLastSyncAt(DateTime.now());

    return merged;
  }

  Future<List<ConversationModel>> searchLocal(String query) async {
    final q = query.trim().toLowerCase();
    final all = await _local.readConversations();
    if (q.isEmpty) return all;

    return all.where((c) {
      return c.peerUser.name.toLowerCase().contains(q) ||
          c.lastMessageText.toLowerCase().contains(q);
    }).toList();
  }
}
