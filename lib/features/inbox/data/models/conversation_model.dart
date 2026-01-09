import 'package:xyz/features/settings/data/user_model.dart';

class ConversationModel {
  final String id;
  final UserModel peerUser;

  final String lastMessageText;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final bool isOnline;

  const ConversationModel({
    required this.id,
    required this.peerUser,
    required this.lastMessageText,
    required this.lastMessageAt,
    required this.unreadCount,
    this.isOnline = false,
  });

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    final parsed = DateTime.tryParse(v.toString());
    return parsed;
  }

  static int _parseInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  static String _parseString(dynamic v) {
    if (v == null) return '';
    return v.toString();
  }

  factory ConversationModel.fromMap(Map<String, dynamic> m) {
    final peerId = _parseString(m['peer_id']);
    final peerName = _parseString(m['peer_name']);
    final peerAvatarUrl = m['peer_avatar_url']?.toString();
    final peerRole = _parseString(m['peer_role']);
    final conversationId = _parseString(m['conversation_id']);

    final user = UserModel.fromMap({
      'id': peerId,
      'name': peerName.isEmpty ? 'Unknown' : peerName,
      'avatar_url': peerAvatarUrl,
      'avatar_path': null,
      'bio': null,
      'role': peerRole.isEmpty ? 'user' : peerRole,
      'headline': null,
      'created_at': null,
    });

    return ConversationModel(
      id: conversationId,
      peerUser: user,
      lastMessageText: _parseString(m['last_message']),
      lastMessageAt: _parseDate(m['last_message_at']),
      unreadCount: _parseInt(m['unread_count']),
    );
  }

  Map<String, dynamic> toMap() => {
    'conversation_id': id,
    'peer_id': peerUser.id,
    'peer_name': peerUser.name,
    'peer_avatar_url': peerUser.avatarUrl,
    'peer_role': peerUser.role,
    'last_message': lastMessageText,
    'last_message_at': lastMessageAt?.toIso8601String(),
    'unread_count': unreadCount,
  };

  ConversationModel copyWith({
    UserModel? peerUser,
    String? lastMessageText,
    DateTime? lastMessageAt,
    int? unreadCount,
  }) {
    return ConversationModel(
      id: id,
      peerUser: peerUser ?? this.peerUser,
      lastMessageText: lastMessageText ?? this.lastMessageText,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
