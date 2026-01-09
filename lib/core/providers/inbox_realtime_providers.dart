// lib/core/providers/inbox_realtime_providers.dart
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:xyz/core/providers/di_providers.dart';
import 'package:xyz/core/providers/inbox_ui_signal_provider.dart';

final inboxUnreadTotalProvider =
    AsyncNotifierProvider<InboxUnreadTotalNotifier, int>(
      InboxUnreadTotalNotifier.new,
    );

class InboxUnreadTotalNotifier extends AsyncNotifier<int> {
  RealtimeChannel? _channel;
  StreamSubscription<AuthState>? _authSub;

  Timer? _syncDebounce;
  String? _currentUserId;

  @override
  Future<int> build() async {
    ref.keepAlive();

    final client = ref.watch(supabaseClientProvider);

    ref.onDispose(() {
      _authSub?.cancel();
      _syncDebounce?.cancel();
      _syncDebounce = null;
      _unsubscribeRealtime();
    });

    // Rebuild nur bei sign in / sign out
    _authSub?.cancel();
    _authSub = client.auth.onAuthStateChange.listen((data) {
      final e = data.event;
      if (e == AuthChangeEvent.signedIn || e == AuthChangeEvent.signedOut) {
        ref.invalidateSelf();
      }
    });

    final user = client.auth.currentUser;
    if (user == null) {
      _currentUserId = null;
      _unsubscribeRealtime();
      return 0;
    }

    // initial count
    final remote = ref.read(inboxRemoteDataSourceProvider);
    final initial = await remote.fetchUnreadTotal();

    // realtime
    _ensureRealtime(client, user.id);

    return initial;
  }

  void _ensureRealtime(SupabaseClient client, String userId) {
    if (_currentUserId == userId && _channel != null) return;

    _unsubscribeRealtime();
    _currentUserId = userId;

    final ch = client.channel('inbox-events-$userId');

    // INSERT -> unread +1
    ch.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'inbox_events',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'user_id',
        value: userId,
      ),
      callback: (_) {
        final current = state.maybeWhen(data: (v) => v, orElse: () => 0);
        state = AsyncData(current + 1);

        // ✅ Inbox-Liste/UI soll refreshen
        ref.read(inboxUiTickProvider.notifier).state++;

        // optional: debounce sync conversations
        _syncDebounce?.cancel();
        _syncDebounce = Timer(const Duration(milliseconds: 400), () {
          ref.read(inboxRepositoryProvider).syncConversations(limit: 50);
        });
      },
    );

    // UPDATE -> wenn read_at gesetzt wurde, unread -1
    ch.onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: 'inbox_events',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'user_id',
        value: userId,
      ),
      callback: (payload) async {
        final oldRow = payload.oldRecord;
        final newRow = payload.newRecord;

        // Dank replica identity full sollten old/new zuverlässig sein.
        if (oldRow.isEmpty || newRow.isEmpty) {
          await refreshFromServer();
          ref.read(inboxUiTickProvider.notifier).state++;
          return;
        }

        final oldReadAt = oldRow['read_at'];
        final newReadAt = newRow['read_at'];

        // null -> nicht-null => gelesen => -1
        if (oldReadAt == null && newReadAt != null) {
          final current = state.maybeWhen(data: (v) => v, orElse: () => 0);
          final next = current - 1;
          state = AsyncData(next < 0 ? 0 : next);

          // ✅ Inbox-Liste/UI refreshen
          ref.read(inboxUiTickProvider.notifier).state++;
        }
      },
    );

    ch.subscribe();
    _channel = ch;
  }

  Future<void> refreshFromServer() async {
    final remote = ref.read(inboxRemoteDataSourceProvider);
    final next = await remote.fetchUnreadTotal();
    state = AsyncData(next);
  }

  void _unsubscribeRealtime() {
    final ch = _channel;
    _channel = null;
    if (ch != null) {
      ch.unsubscribe();
    }
  }
}
