part of 'chat_bloc.dart';

enum ChatStatus { initial, loading, success, failure }

class ChatState extends Equatable {
  final ChatStatus status;
  final List<MessageModel> messages;
  final UserModel? peerUser;
  final String conversationId;

  final bool sending;
  final String? error;

  // Pagination
  final bool loadingOlder;
  final bool hasMoreOlder;

  const ChatState({
    required this.conversationId,
    this.status = ChatStatus.initial,
    this.messages = const [],
    this.peerUser,
    this.sending = false,
    this.error,
    this.loadingOlder = false,
    this.hasMoreOlder = true,
  });

  String get title => peerUser?.name ?? 'Chat';

  ChatState copyWith({
    ChatStatus? status,
    List<MessageModel>? messages,
    UserModel? peerUser,
    bool? sending,
    String? error,
    bool? loadingOlder,
    bool? hasMoreOlder,
  }) {
    return ChatState(
      conversationId: conversationId,
      status: status ?? this.status,
      messages: messages ?? this.messages,
      peerUser: peerUser ?? this.peerUser,
      sending: sending ?? this.sending,
      error: error,
      loadingOlder: loadingOlder ?? this.loadingOlder,
      hasMoreOlder: hasMoreOlder ?? this.hasMoreOlder,
    );
  }

  @override
  List<Object?> get props => [
    conversationId,
    status,
    messages,
    peerUser,
    sending,
    error,
    loadingOlder,
    hasMoreOlder,
  ];
}
