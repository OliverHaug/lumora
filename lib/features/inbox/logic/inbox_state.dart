<<<<<<< HEAD
import 'package:equatable/equatable.dart';
import 'package:xyz/features/inbox/data/models/conversation_model.dart';
import 'inbox_event.dart';

enum InboxStatus { initial, loading, success, failure }

=======
part of 'inbox_bloc.dart';

enum InboxStatus { initial, loading, success, failure }

enum InboxTabMode { messages, notifications }

>>>>>>> 94ee73e (feat(inbox,chat): add realtime inbox/chat, caching and UX improvements)
class InboxState extends Equatable {
  final InboxStatus status;
  final InboxTabMode mode;
  final String query;

<<<<<<< HEAD
  final List<ConversationModel> conversations;
  final String? error;

  const InboxState({
    this.status = InboxStatus.initial,
    this.mode = InboxTabMode.messages,
    this.query = '',
    this.conversations = const [],
    this.error,
  });

=======
  final List<ConversationModel> allConversations;

  final List<ConversationModel> conversations;

  final String? error;

  const InboxState({
    required this.status,
    required this.mode,
    required this.query,
    required this.allConversations,
    required this.conversations,
    required this.error,
  });

  const InboxState.initial()
    : status = InboxStatus.initial,
      mode = InboxTabMode.messages,
      query = '',
      allConversations = const [],
      conversations = const [],
      error = null;

>>>>>>> 94ee73e (feat(inbox,chat): add realtime inbox/chat, caching and UX improvements)
  InboxState copyWith({
    InboxStatus? status,
    InboxTabMode? mode,
    String? query,
<<<<<<< HEAD
=======
    List<ConversationModel>? allConversations,
>>>>>>> 94ee73e (feat(inbox,chat): add realtime inbox/chat, caching and UX improvements)
    List<ConversationModel>? conversations,
    String? error,
  }) {
    return InboxState(
      status: status ?? this.status,
      mode: mode ?? this.mode,
      query: query ?? this.query,
<<<<<<< HEAD
=======
      allConversations: allConversations ?? this.allConversations,
>>>>>>> 94ee73e (feat(inbox,chat): add realtime inbox/chat, caching and UX improvements)
      conversations: conversations ?? this.conversations,
      error: error,
    );
  }

  @override
<<<<<<< HEAD
  List<Object?> get props => [status, mode, query, conversations, error];
=======
  List<Object?> get props => [
    status,
    mode,
    query,
    allConversations,
    conversations,
    error,
  ];
>>>>>>> 94ee73e (feat(inbox,chat): add realtime inbox/chat, caching and UX improvements)
}
