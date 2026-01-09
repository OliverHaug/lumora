part of 'inbox_bloc.dart';

abstract class InboxEvent extends Equatable {
  const InboxEvent();
  @override
  List<Object?> get props => [];
}

class InboxStarted extends InboxEvent {
  const InboxStarted();
}

class InboxRefreshRequested extends InboxEvent {
  const InboxRefreshRequested();
}

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
