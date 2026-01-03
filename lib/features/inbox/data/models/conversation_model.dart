import 'package:equatable/equatable.dart';
import 'package:xyz/features/settings/data/user_model.dart';

class ConversationModel extends Equatable {
  final String id;

  final UserModel peerUser;

  final String lastMessageText;
  final DateTime lastMessageAt;

  final int unreadCount;

  final bool isOnline;

  const ConversationModel({
    required this.id,
    required this.peerUser,
    required this.lastMessageText,
    required this.lastMessageAt,
    this.unreadCount = 0,
    this.isOnline = false,
  });

  factory ConversationModel.fromMap(Map<String, dynamic> map) {
    return ConversationModel(
      id: map['id'] as String,
      peerUser: UserModel.fromMap(map['peer_user'] as Map<String, dynamic>),
      lastMessageText: (map['last_message_text'] as String?) ?? '',
      lastMessageAt: DateTime.parse(map['last_message_at'] as String),
      unreadCount: (map['unread_count'] as int?) ?? 0,
      isOnline: (map['is_online'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'peer_user': {
      'id': peerUser.id,
      'name': peerUser.name,
      'avatar_url': peerUser.avatarUrl,
      'bio': peerUser.bio,
      'role': peerUser.role,
      'created_at': peerUser.createdAt?.toIso8601String(),
    },
    'last_message_text': lastMessageText,
    'last_message_at': lastMessageAt.toIso8601String(),
    'unread_count': unreadCount,
    'is_online': isOnline,
  };

  @override
  List<Object?> get props => [
    id,
    peerUser,
    lastMessageText,
    lastMessageAt,
    unreadCount,
    isOnline,
  ];
}
