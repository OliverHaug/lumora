import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xyz/core/providers/di_providers.dart';
import 'package:xyz/features/inbox/logic/inbox_bloc.dart';
import 'package:xyz/features/inbox/logic/inbox_event.dart';
import 'package:xyz/features/inbox/logic/inbox_state.dart';
import 'package:xyz/features/inbox/presentation/widgets/inbox_segment_control.dart';
import 'widgets/conversation_tile.dart';
import 'widgets/inbox_search_field.dart';
import 'widgets/notification_tile.dart';

class InboxPage extends ConsumerWidget {
  const InboxPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bloc = ref.watch(inboxBlocProvider);

    if (bloc.state.status == InboxStatus.initial) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!bloc.isClosed) bloc.add(const InboxStarted());
      });
    }

    return BlocProvider.value(
      value: bloc,
      child: Scaffold(
        backgroundColor: const Color(0xfff4f2f0),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xfff4f2f0),
          title: const Text(
            'Inbox',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                // optional: settings / filter
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.black,
          child: const Icon(Icons.edit, color: Colors.white),
          onPressed: () {
            // TODO: compose new chat
            // z.B. context.go('/inbox/new_chat');
          },
        ),
        body: SafeArea(
          child: BlocBuilder<InboxBloc, InboxState>(
            builder: (context, state) {
              return RefreshIndicator(
                onRefresh: () async => context.read<InboxBloc>().add(
                  const InboxRefreshRequested(),
                ),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                  children: [
                    // Segmented control
                    InboxSegmentedControl(
                      mode: state.mode,
                      notificationsHasDot: true, // optional später dynamisch
                      onChanged: (m) =>
                          context.read<InboxBloc>().add(InboxTabChanged(m)),
                    ),
                    const SizedBox(height: 12),

                    // Search
                    InboxSearchField(
                      value: state.query,
                      onChanged: (v) =>
                          context.read<InboxBloc>().add(InboxSearchChanged(v)),
                    ),
                    const SizedBox(height: 12),

                    // Content
                    if (state.status == InboxStatus.loading) ...[
                      const SizedBox(height: 24),
                      const Center(child: CircularProgressIndicator()),
                    ] else if (state.status == InboxStatus.failure) ...[
                      const SizedBox(height: 16),
                      Text(
                        state.error ?? 'Something went wrong.',
                        style: TextStyle(
                          color: Colors.black.withValues(alpha: .7),
                        ),
                      ),
                    ] else ...[
                      if (state.mode == InboxTabMode.messages)
                        _MessagesList(state: state)
                      else
                        const _NotificationsList(),
                    ],

                    const SizedBox(height: 18),
                    Center(
                      child: Text(
                        'END OF MESSAGES',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.6,
                          color: Colors.black.withValues(alpha: .35),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MessagesList extends StatelessWidget {
  final InboxState state;
  const _MessagesList({required this.state});

  @override
  Widget build(BuildContext context) {
    final items = state.conversations;

    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 18),
        child: Text(
          'No conversations yet.',
          style: TextStyle(color: Colors.black.withValues(alpha: .65)),
        ),
      );
    }

    return Column(
      children: [
        ...items.map(
          (c) => ConversationTile(
            conversation: c,
            onTap: () {
              // TODO: open chat detail
              // context.go('/inbox/chat', arguments: c.id);
            },
          ),
        ),
      ],
    );
  }
}

class _NotificationsList extends StatelessWidget {
  const _NotificationsList();

  @override
  Widget build(BuildContext context) {
    // TODO: hier später NotificationsBloc + DB
    final mock = [
      (
        title: 'Dr. Green',
        subtitle: 'Your next session is confirmed for…',
        time: 'Yesterday',
      ),
      (
        title: 'Mindfulness Bot',
        subtitle: 'How are you feeling right now?',
        time: 'Tue',
      ),
    ];

    return Column(
      children: mock
          .map(
            (n) => NotificationTile(
              title: n.title,
              subtitle: n.subtitle,
              timeText: n.time,
              onTap: () {},
            ),
          )
          .toList(),
    );
  }
}
