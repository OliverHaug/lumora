part of 'chat_bloc.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object?> get props => [];
}

class ChatStarted extends ChatEvent {
  const ChatStarted();
}

class ChatRefreshRequested extends ChatEvent {
  const ChatRefreshRequested();
}

class ChatIncomingMessage extends ChatEvent {
  final MessageModel message;
  const ChatIncomingMessage(this.message);

  @override
  List<Object?> get props => [message];
}

class ChatSendPressed extends ChatEvent {
  final String text;
  const ChatSendPressed(this.text);

  @override
  List<Object?> get props => [text];
}

class ChatLoadOlderRequested extends ChatEvent {
  final int limit;
  const ChatLoadOlderRequested({this.limit = 50});

  @override
  List<Object?> get props => [limit];
}
