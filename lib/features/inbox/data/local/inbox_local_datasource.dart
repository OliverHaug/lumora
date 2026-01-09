<<<<<<< HEAD
import 'dart:convert';
import 'package:hive/hive.dart';
import '../models/conversation_model.dart';
import 'inbox_storage_keys.dart';

class InboxLocalDataSource {
  Future<Box> _open() async => Hive.openBox(InboxStorageKeys.box);

  Future<List<ConversationModel>> readConversations() async {
    final box = await _open();
    final raw = box.get(InboxStorageKeys.conversations) as String?;
    if (raw == null || raw.isEmpty) return const [];

    final decoded = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return decoded.map(ConversationModel.fromMap).toList();
  }

  Future<void> writeConversations(List<ConversationModel> items) async {
    final box = await _open();
    final raw = jsonEncode(items.map((e) => e.toMap()).toList());
    await box.put(InboxStorageKeys.conversations, raw);
  }

  Future<DateTime?> readLastSyncAt() async {
    final box = await _open();
    final raw = box.get(InboxStorageKeys.lastSyncAt) as String?;
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> writeLastSyncAt(DateTime dt) async {
    final box = await _open();
    await box.put(InboxStorageKeys.lastSyncAt, dt.toIso8601String());
=======
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
    if (ad == null) return 1; // null nach unten
    if (bd == null) return -1;

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
>>>>>>> 94ee73e (feat(inbox,chat): add realtime inbox/chat, caching and UX improvements)
  }
}
