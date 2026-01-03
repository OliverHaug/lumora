import 'package:equatable/equatable.dart';
import 'package:xyz/features/inbox/data/models/conversation_model.dart';
import 'inbox_event.dart';

enum InboxStatus { initial, loading, success, failure }

class InboxState extends Equatable {
  final InboxStatus status;
  final InboxTabMode mode;
  final String query;

  final List<ConversationModel> conversations;
  final String? error;

  const InboxState({
    this.status = InboxStatus.initial,
    this.mode = InboxTabMode.messages,
    this.query = '',
    this.conversations = const [],
    this.error,
  });

  InboxState copyWith({
    InboxStatus? status,
    InboxTabMode? mode,
    String? query,
    List<ConversationModel>? conversations,
    String? error,
  }) {
    return InboxState(
      status: status ?? this.status,
      mode: mode ?? this.mode,
      query: query ?? this.query,
      conversations: conversations ?? this.conversations,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, mode, query, conversations, error];
}
