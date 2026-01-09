<<<<<<< HEAD
import 'package:equatable/equatable.dart';

enum InboxTabMode { messages, notifications }
=======
part of 'inbox_bloc.dart';
>>>>>>> 94ee73e (feat(inbox,chat): add realtime inbox/chat, caching and UX improvements)

abstract class InboxEvent extends Equatable {
  const InboxEvent();
  @override
  List<Object?> get props => [];
}

class InboxStarted extends InboxEvent {
  const InboxStarted();
}

<<<<<<< HEAD
=======
class InboxRefreshRequested extends InboxEvent {
  const InboxRefreshRequested();
}

>>>>>>> 94ee73e (feat(inbox,chat): add realtime inbox/chat, caching and UX improvements)
class InboxTabChanged extends InboxEvent {
  final InboxTabMode mode;
  const InboxTabChanged(this.mode);

  @override
  List<Object?> get props => [mode];
}

class InboxSearchChanged extends InboxEvent {
  final String query;
  const InboxSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}
<<<<<<< HEAD

class InboxRefreshRequested extends InboxEvent {
  const InboxRefreshRequested();
}
=======
>>>>>>> 94ee73e (feat(inbox,chat): add realtime inbox/chat, caching and UX improvements)
