import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/inbox_repository.dart';
import '../data/models/conversation_model.dart';

part 'inbox_event.dart';
part 'inbox_state.dart';

class InboxBloc extends Bloc<InboxEvent, InboxState> {
  final InboxRepository _repo;

  InboxBloc(this._repo) : super(const InboxState.initial()) {
    on<InboxStarted>(_onStarted);
    on<InboxRefreshRequested>(_onRefresh);
    on<InboxTabChanged>(_onTabChanged);
    on<InboxSearchChanged>(_onSearchChanged);
  }

  int _compareLastMessageAtDesc(ConversationModel a, ConversationModel b) {
    final ad = a.lastMessageAt; // DateTime?
    final bd = b.lastMessageAt; // DateTime?

    if (ad == null && bd == null) return 0;
    if (ad == null) return 1;
    if (bd == null) return -1;

    return bd.compareTo(ad);
  }

  Future<void> _onStarted(InboxStarted event, Emitter<InboxState> emit) async {
    emit(state.copyWith(status: InboxStatus.loading, error: null));

    try {
      // 1) Cache sofort anzeigen
      final cached = await _repo.loadCachedConversations();
      final cachedFiltered = _applyQuery(cached, state.query);

      emit(
        state.copyWith(
          status: InboxStatus.success,
          allConversations: cached,
          conversations: cachedFiltered,
        ),
      );

      // 2) Server Sync
      final fresh = await _repo.syncConversations(limit: 50);
      final freshFiltered = _applyQuery(fresh, state.query);

      emit(
        state.copyWith(
          status: InboxStatus.success,
          allConversations: fresh,
          conversations: freshFiltered,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: InboxStatus.failure, error: e.toString()));
    }
  }

  Future<void> _onRefresh(
    InboxRefreshRequested event,
    Emitter<InboxState> emit,
  ) async {
    try {
      final fresh = await _repo.syncConversations(limit: 50);
      final filtered = _applyQuery(fresh, state.query);

      emit(
        state.copyWith(
          status: InboxStatus.success,
          allConversations: fresh,
          conversations: filtered,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: InboxStatus.failure, error: e.toString()));
    }
  }

  void _onTabChanged(InboxTabChanged event, Emitter<InboxState> emit) {
    emit(state.copyWith(mode: event.mode));
  }

  void _onSearchChanged(InboxSearchChanged event, Emitter<InboxState> emit) {
    final q = event.query;
    final filtered = _applyQuery(state.allConversations, q);
    emit(state.copyWith(query: q, conversations: filtered));
  }

  List<ConversationModel> _applyQuery(List<ConversationModel> items, String q) {
    final query = q.trim().toLowerCase();

    // Sort-Helper
    List<ConversationModel> sorted(List<ConversationModel> xs) {
      final out = [...xs]..sort(_compareLastMessageAtDesc);
      return out;
    }

    if (query.isEmpty) {
      return sorted(items);
    }

    final filtered = items.where((c) {
      final name = c.peerUser.name.toLowerCase();
      final last = c.lastMessageText.toLowerCase();
      return name.contains(query) || last.contains(query);
    }).toList();

    return sorted(filtered);
  }
}
