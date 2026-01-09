import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lumora/core/providers/di_providers.dart';
import 'package:lumora/features/inbox/logic/inbox_bloc.dart';
import 'package:lumora/features/inbox/presentation/widgets/conversation_tile.dart';
import 'package:lumora/features/inbox/presentation/widgets/inbox_segment_control.dart';
import 'package:lumora/features/settings/data/user_model.dart';

import 'widgets/inbox_search_field.dart';
import 'widgets/notification_tile.dart';

/// ✅ People I follow (für "Neue Konversation")
final followingUsersProvider = FutureProvider<List<UserModel>>((ref) async {
  final circle = ref.watch(circleRepositoryProvider);
  final rows = await circle.fetchFollowing();

  // rows sind Map<String, dynamic> die zu UserModel passen müssen
  return rows.map((m) => UserModel.fromMap(m)).toList();
});

class InboxPage extends ConsumerWidget {
  const InboxPage({super.key});

  void _openNewChatSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xfff4f2f0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => const NewChatSheet(),
    );
  }

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
                // optional
              },
            ),
          ],
        ),

        /// ✅ FAB: neue Konversation starten
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.black,
          child: const Icon(Icons.edit, color: Colors.white),
          onPressed: () => _openNewChatSheet(context),
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
                    InboxSegmentedControl(
                      mode: state.mode,
                      notificationsHasDot: true,
                      onChanged: (m) =>
                          context.read<InboxBloc>().add(InboxTabChanged(m)),
                    ),
                    const SizedBox(height: 12),

                    InboxSearchField(
                      value: state.query,
                      onChanged: (v) =>
                          context.read<InboxBloc>().add(InboxSearchChanged(v)),
                    ),
                    const SizedBox(height: 12),

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
    final items = state.conversations.where((c) {
      final hasAt = c.lastMessageAt != null;
      final hasText = c.lastMessageText.trim().isNotEmpty;

      return hasAt && hasText;
    });

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
              final qp = <String, String>{
                if (c.peerUser.name.trim().isNotEmpty)
                  'peer_name': c.peerUser.name,
                if ((c.peerUser.avatarUrl ?? '').trim().isNotEmpty)
                  'peer_avatar_url': c.peerUser.avatarUrl!,
              };

              final q = qp.isEmpty ? '' : '?${Uri(queryParameters: qp).query}';
              context.go('/inbox/chat/${c.id}$q');
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

/// ✅ BottomSheet: Following auswählen → Conversation erstellen → Chat öffnen
class NewChatSheet extends ConsumerStatefulWidget {
  const NewChatSheet({super.key});

  @override
  ConsumerState<NewChatSheet> createState() => _NewChatSheetState();
}

class _NewChatSheetState extends ConsumerState<NewChatSheet> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final followingAsync = ref.watch(followingUsersProvider);
    final q = _searchCtrl.text.trim().toLowerCase();

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollCtrl) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: .18),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 14),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'New conversation',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                ),
              ),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.black.withValues(alpha: .06),
                  ),
                ),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Search people you follow…',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: followingAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(
                    child: Text(
                      e.toString(),
                      style: TextStyle(
                        color: Colors.black.withValues(alpha: .7),
                      ),
                    ),
                  ),
                  data: (users) {
                    final filtered = users.where((u) {
                      if (q.isEmpty) return true;
                      final name = (u.name).toLowerCase();
                      final role = u.role.toLowerCase();
                      return name.contains(q) || role.contains(q);
                    }).toList();

                    if (filtered.isEmpty) {
                      return Text(
                        'No results.',
                        style: TextStyle(
                          color: Colors.black.withValues(alpha: .6),
                        ),
                      );
                    }

                    return ListView.separated(
                      controller: scrollCtrl,
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: Colors.black.withValues(alpha: .06),
                      ),
                      itemBuilder: (context, i) {
                        final u = filtered[i];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          leading: _AvatarSmall(
                            url: u.avatarUrl,
                            fallbackText: u.name,
                          ),
                          title: Text(
                            u.name,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          subtitle: (u.role.isNotEmpty)
                              ? Text(
                                  u.role,
                                  style: TextStyle(
                                    color: Colors.black.withValues(alpha: .55),
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              : null,
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () async {
                            try {
                              final repo = ref.read(inboxRepositoryProvider);

                              /// ✅ create/get conversation_id
                              final conversationId = await repo
                                  .getOrCreateDirectConnversation(u.id);

                              if (!context.mounted) return;
                              Navigator.of(context).pop();

                              final qp = <String, String>{
                                if (u.name.trim().isNotEmpty)
                                  'peer_name': u.name,
                                if ((u.avatarUrl ?? '').trim().isNotEmpty)
                                  'peer_avatar_url': u.avatarUrl!,
                              };

                              final query = qp.isEmpty
                                  ? ''
                                  : '?${Uri(queryParameters: qp).query}';

                              context.go('/inbox/chat/$conversationId$query');
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AvatarSmall extends StatelessWidget {
  const _AvatarSmall({required this.url, required this.fallbackText});

  final String? url;
  final String fallbackText;

  @override
  Widget build(BuildContext context) {
    final initials = fallbackText.trim().isEmpty
        ? '?'
        : fallbackText
              .trim()
              .split(RegExp(r'\s+'))
              .take(2)
              .map((p) => p.isEmpty ? '' : p[0].toUpperCase())
              .join();

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xffe7d7a5),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black.withValues(alpha: .06)),
      ),
      clipBehavior: Clip.antiAlias,
      child: (url != null && url!.trim().isNotEmpty)
          ? Image.network(
              url!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Center(
                child: Text(
                  initials,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            )
          : Center(
              child: Text(
                initials,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
    );
  }
}
