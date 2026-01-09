import 'package:equatable/equatable.dart';
<<<<<<< HEAD
=======
import 'package:supabase_flutter/supabase_flutter.dart';
>>>>>>> 94ee73e (feat(inbox,chat): add realtime inbox/chat, caching and UX improvements)

class MessageModel extends Equatable {
  final String id;
  final String conversationId;
  final String senderId;
<<<<<<< HEAD
  final String text;
=======
  final String body;
>>>>>>> 94ee73e (feat(inbox,chat): add realtime inbox/chat, caching and UX improvements)
  final DateTime createdAt;

  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
<<<<<<< HEAD
    required this.text,
    required this.createdAt,
  });

=======
    required this.body,
    required this.createdAt,
  });

  /// 🔑 WhatsApp-style helper
  bool get isMine {
    final myId = Supabase.instance.client.auth.currentUser?.id;
    return myId != null && myId == senderId;
  }

>>>>>>> 94ee73e (feat(inbox,chat): add realtime inbox/chat, caching and UX improvements)
  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] as String,
      conversationId: map['conversation_id'] as String,
      senderId: map['sender_id'] as String,
<<<<<<< HEAD
      text: (map['text'] as String?) ?? '',
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'conversation_id': conversationId,
    'sender_id': senderId,
    'text': text,
    'created_at': createdAt.toIso8601String(),
  };

  @override
  List<Object?> get props => [id, conversationId, senderId, text, createdAt];
=======
      body: map['body'] as String,
      createdAt: DateTime.parse(map['created_at']),
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'body': body,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, conversationId, senderId, body, createdAt];
>>>>>>> 94ee73e (feat(inbox,chat): add realtime inbox/chat, caching and UX improvements)
}
