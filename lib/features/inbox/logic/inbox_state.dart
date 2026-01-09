part of 'inbox_bloc.dart';

enum InboxStatus { initial, loading, success, failure }

enum InboxTabMode { messages, notifications }

class InboxState extends Equatable {
  final InboxStatus status;
  final InboxTabMode mode;
  final String query;

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

  InboxState copyWith({
    InboxStatus? status,
    InboxTabMode? mode,
    String? query,
    List<ConversationModel>? allConversations,
    List<ConversationModel>? conversations,
    String? error,
  }) {
    return InboxState(
      status: status ?? this.status,
      mode: mode ?? this.mode,
      query: query ?? this.query,
      allConversations: allConversations ?? this.allConversations,
      conversations: conversations ?? this.conversations,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    status,
    mode,
    query,
    allConversations,
    conversations,
    error,
  ];
}
