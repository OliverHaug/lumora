import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:lumora/features/inbox/data/models/message_model.dart';

class ChatLocalDataSource {
  static const _boxName = 'inbox_cache';

  Future<Box> _open() async => Hive.openBox(_boxName);

  String _keyMsgs(String conversationId) => 'chat_messages_$conversationId';
  String _keyLatestTs(String conversationId) =>
      'chat_latest_ts_$conversationId';
  String _keyOldestTs(String conversationId) =>
      'chat_oldest_ts_$conversationId';

  Future<List<MessageModel>> readMessages(String conversationId) async {
    final box = await _open();
    final raw = box.get(_keyMsgs(conversationId)) as String?;
    if (raw == null || raw.isEmpty) return const [];

    final decoded = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    final list = decoded.map(MessageModel.fromMap).toList();

    // Wir arbeiten überall DESC (neueste oben)
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<void> writeMessages(
    String conversationId,
    List<MessageModel> items,
  ) async {
    final box = await _open();

    // Immer DESC
    final sorted = [...items]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final raw = jsonEncode(sorted.map((e) => e.toMap()).toList());
    await box.put(_keyMsgs(conversationId), raw);

    if (sorted.isNotEmpty) {
      final latest = sorted.first.createdAt; // DESC → first = newest
      final oldest = sorted.last.createdAt; // DESC → last = oldest

      await box.put(_keyLatestTs(conversationId), latest.toIso8601String());
      await box.put(_keyOldestTs(conversationId), oldest.toIso8601String());
    }
  }

  Future<DateTime?> readLatestTs(String conversationId) async {
    final box = await _open();
    final raw = box.get(_keyLatestTs(conversationId)) as String?;
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  Future<DateTime?> readOldestTs(String conversationId) async {
    final box = await _open();
    final raw = box.get(_keyOldestTs(conversationId)) as String?;
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }
}
