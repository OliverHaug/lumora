import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xyz/features/inbox/data/inbox_repository.dart';
import 'inbox_event.dart';
import 'inbox_state.dart';

class InboxBloc extends Bloc<InboxEvent, InboxState> {
  final InboxRepository _repo;

  InboxBloc(this._repo) : super(const InboxState()) {
    on<InboxStarted>(_onStarted);
    on<InboxSearchChanged>(_onSearchChanged);
    on<InboxRefreshRequested>(_onRefresh);
    on<InboxTabChanged>(_onTabChanged);
  }

  Future<void> _onStarted(InboxStarted e, Emitter<InboxState> emit) async {
    final cached = await _repo.loadCachedConversations();
    emit(state.copyWith(status: InboxStatus.success, conversations: cached));

    try {
      final merged = await _repo.syncConversations(limit: 50);
      emit(state.copyWith(status: InboxStatus.success, conversations: merged));
    } catch (err) {
      emit(state.copyWith(error: err.toString()));
    }
  }

  Future<void> _onRefresh(
    InboxRefreshRequested e,
    Emitter<InboxState> emit,
  ) async {
    emit(state.copyWith(status: InboxStatus.loading, error: null));
    try {
      final merged = await _repo.syncConversations(limit: 50);
      emit(state.copyWith(status: InboxStatus.success, conversations: merged));
    } catch (err) {
      emit(state.copyWith(status: InboxStatus.failure, error: err.toString()));
    }
  }

  Future<void> _onSearchChanged(
    InboxSearchChanged e,
    Emitter<InboxState> emit,
  ) async {
    emit(state.copyWith(query: e.query));

    final filtered = await _repo.searchLocal(e.query);
    emit(state.copyWith(conversations: filtered));
  }

  void _onTabChanged(InboxTabChanged e, Emitter<InboxState> emit) {
    emit(state.copyWith(mode: e.mode));
  }
}
