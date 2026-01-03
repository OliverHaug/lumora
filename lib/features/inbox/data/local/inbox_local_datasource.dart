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
  }
}
