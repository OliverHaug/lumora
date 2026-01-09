// lib/features/inbox/logic/chat/chat_bloc.dart
import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:xyz/features/inbox/data/chat_repository.dart';
import 'package:xyz/features/inbox/data/models/message_model.dart';
import 'package:xyz/features/settings/data/user_model.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _repo;
  final SupabaseClient _client;
  final String conversationId;

  RealtimeChannel? _channel;
  StreamSubscription<AuthState>? _authSub;

  ChatBloc({
    required ChatRepository repo,
    required SupabaseClient client,
    required this.conversationId,
  }) : _repo = repo,
       _client = client,
       super(ChatState(conversationId: conversationId)) {
    on<ChatStarted>(_onStarted);
    on<ChatRefreshRequested>(_onRefresh);
    on<ChatIncomingMessage>(_onIncoming);
    on<ChatSendPressed>(_onSend);
    on<ChatLoadOlderRequested>(_onLoadOlder);

    _setupRealtime();

    // ✅ Nicht auf tokenRefreshed reagieren – das ist zu oft
    _authSub = _client.auth.onAuthStateChange.listen((data) {
      final e = data.event;

      if (e == AuthChangeEvent.signedOut) {
        _channel?.unsubscribe();
        _channel = null;
        return;
      }

      if (e == AuthChangeEvent.signedIn) {
        _setupRealtime();
      }
    });
  }

  Future<void> _onStarted(ChatStarted e, Emitter<ChatState> emit) async {
    emit(state.copyWith(status: ChatStatus.loading, error: null));

    try {
      // 1) Cache sofort
      final cached = await _repo.loadCached(conversationId);
      emit(state.copyWith(status: ChatStatus.success, messages: cached));

      // 2) Nur neue / initial page
      final merged = await _repo.syncLatest(conversationId, initialLimit: 80);
      emit(state.copyWith(status: ChatStatus.success, messages: merged));

      await _repo.markRead(conversationId);
    } catch (err) {
      emit(state.copyWith(status: ChatStatus.failure, error: err.toString()));
    }
  }

  Future<void> _onRefresh(
    ChatRefreshRequested e,
    Emitter<ChatState> emit,
  ) async {
    try {
      final merged = await _repo.syncLatest(conversationId, initialLimit: 80);
      emit(state.copyWith(status: ChatStatus.success, messages: merged));
    } catch (err) {
      emit(state.copyWith(status: ChatStatus.failure, error: err.toString()));
    }
  }

  Future<void> _onLoadOlder(
    ChatLoadOlderRequested e,
    Emitter<ChatState> emit,
  ) async {
    if (state.loadingOlder || !state.hasMoreOlder) return;

    emit(state.copyWith(loadingOlder: true, error: null));

    try {
      final beforeCount = state.messages.length;

      final merged = await _repo.fetchOlder(conversationId, limit: e.limit);

      final afterCount = merged.length;
      final gotAny = afterCount > beforeCount;

      emit(
        state.copyWith(
          status: ChatStatus.success,
          messages: merged,
          loadingOlder: false,
          hasMoreOlder: gotAny,
        ),
      );
    } catch (err) {
      emit(
        state.copyWith(
          loadingOlder: false,
          status: ChatStatus.failure,
          error: err.toString(),
        ),
      );
    }
  }

  void _onIncoming(ChatIncomingMessage e, Emitter<ChatState> emit) {
    final incoming = e.message;

    if (incoming.conversationId != conversationId) return;
    if (state.messages.any((m) => m.id == incoming.id)) return;

    final next = [incoming, ...state.messages]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    emit(state.copyWith(status: ChatStatus.success, messages: next));
  }

  Future<void> _onSend(ChatSendPressed e, Emitter<ChatState> emit) async {
    final text = e.text.trim();
    if (text.isEmpty) return;

    emit(state.copyWith(sending: true, error: null));

    try {
      final sent = await _repo.sendMessage(
        conversationId: conversationId,
        body: text,
      );

      final next = [sent, ...state.messages]
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      emit(
        state.copyWith(
          sending: false,
          status: ChatStatus.success,
          messages: next,
        ),
      );
    } catch (err) {
      emit(
        state.copyWith(
          sending: false,
          status: ChatStatus.failure,
          error: err.toString(),
        ),
      );
    }
  }

  void _setupRealtime() {
    _channel?.unsubscribe();
    _channel = null;

    final ch = _client.channel('chat-$conversationId');

    ch.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'messages',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'conversation_id',
        value: conversationId,
      ),
      callback: (payload) {
        final rowDyn = payload.newRecord;
        final row = Map<String, dynamic>.from(rowDyn);

        final msg = MessageModel.fromMap(row);
        add(ChatIncomingMessage(msg));
      },
    );

    ch.subscribe();
    _channel = ch;
  }

  @override
  Future<void> close() async {
    _authSub?.cancel();
    _channel?.unsubscribe();
    return super.close();
  }
}
