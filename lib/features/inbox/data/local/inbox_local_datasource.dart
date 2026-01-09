import 'package:hive_flutter/hive_flutter.dart';
import '../models/conversation_model.dart';

class InboxLocalDataSource {
  static const _convBox = 'inbox_conversations';
  static const _metaBox = 'inbox_meta';

  Future<Box> _open(String name) async => Hive.openBox(name);

  int _compareLastMessageAtDesc(ConversationModel a, ConversationModel b) {
    final ad = a.lastMessageAt;
    final bd = b.lastMessageAt;

    if (ad == null && bd == null) return 0;

    return bd.compareTo(ad); // DESC
  }

  Future<List<ConversationModel>> readConversations() async {
    final box = await _open(_convBox);
    final raw = (box.get('items') as List?) ?? [];

    final items = raw
        .cast<Map>()
        .map((e) => ConversationModel.fromMap(e.cast<String, dynamic>()))
        .toList();

    items.sort(_compareLastMessageAtDesc);
    return items;
  }

  Future<void> writeConversations(List<ConversationModel> items) async {
    final box = await _open(_convBox);
    await box.put('items', items.map((c) => c.toMap()).toList());
  }

  Future<DateTime?> readLastSyncAt() async {
    final box = await _open(_metaBox);
    final v = box.get('last_sync_at');
    if (v == null) return null;
    return DateTime.tryParse(v as String);
  }

  Future<void> writeLastSyncAt(DateTime t) async {
    final box = await _open(_metaBox);
    await box.put('last_sync_at', t.toIso8601String());
  }
}
