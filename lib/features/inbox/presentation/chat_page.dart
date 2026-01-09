// lib/features/inbox/presentation/chat_page.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:xyz/core/providers/di_providers.dart';
import 'package:xyz/core/providers/inbox_realtime_providers.dart';
import 'package:xyz/core/providers/inbox_ui_signal_provider.dart';
import 'package:xyz/core/theme/app_colors.dart';

import 'package:xyz/features/inbox/logic/chat/chat_bloc.dart';
import 'package:xyz/features/inbox/data/chat_repository.dart';
import 'package:xyz/features/inbox/data/inbox_repository.dart';
import 'package:xyz/features/inbox/data/models/conversation_model.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({
    super.key,
    required this.conversationId,
    this.peerName,
    this.peerAvatarUrl,
    this.peerSubtitle,
  });

  /// ✅ NUR ID über Route übergeben (reload-sicher)
  final String conversationId;

  /// Optional: wenn du es beim Navigieren schon hast
  final String? peerName;
  final String? peerAvatarUrl;

  /// z.B. "online", "zuletzt online …"
  final String? peerSubtitle;

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _textCtrl = TextEditingController();
  final _focusNode = FocusNode();
  final _scrollCtrl = ScrollController();

  late final ChatBloc _bloc;

  bool _started = false;
  Timer? _markReadDebounce;

  // ✅ Header Daten (werden aus Inbox Cache / Sync geladen)
  String? _peerName;
  String? _peerAvatarUrl;
  String? _peerSubtitle;

  @override
  void initState() {
    super.initState();

    _peerName = widget.peerName;
    _peerAvatarUrl = widget.peerAvatarUrl;
    _peerSubtitle = widget.peerSubtitle;

    _bloc = ChatBloc(
      repo: _createChatRepo(),
      client: ref.read(supabaseClientProvider),
      conversationId: widget.conversationId,
    );

    // Peer Daten nachladen (wenn nicht per Route übergeben)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      if (_peerName == null || _peerName!.trim().isEmpty) {
        await _loadPeerFromInbox();
      }

      if (!_started) {
        _started = true;
        _bloc.add(const ChatStarted());

        // Badge einmal korrekt ziehen
        ref.read(inboxUnreadTotalProvider.notifier).refreshFromServer();
        ref.read(inboxUiTickProvider.notifier).state++;
      }
    });
  }

  ChatRepository _createChatRepo() {
    final remote = ref.read(chatRemoteDataSourceProvider);
    final local = ref.read(chatLocalDataSourceProvider);
    return ChatRepository(remote, local);
  }

  InboxRepository _inboxRepo() => ref.read(inboxRepositoryProvider);

  /// ✅ lädt Peer aus Inbox Cache; wenn nicht vorhanden -> sync und erneut suchen
  Future<void> _loadPeerFromInbox() async {
    try {
      // 1) Cache
      final cached = await _inboxRepo().loadCachedConversations();
      final hit = _findConversation(cached, widget.conversationId);
      if (hit != null) {
        if (!mounted) return;
        setState(() {
          _peerName = hit.peerUser.name;
          _peerAvatarUrl = hit.peerUser.avatarUrl;
        });
        return;
      }

      // 2) Fallback: einmal sync
      final fresh = await _inboxRepo().syncConversations(limit: 50);
      final hit2 = _findConversation(fresh, widget.conversationId);
      if (hit2 != null) {
        if (!mounted) return;
        setState(() {
          _peerName = hit2.peerUser.name;
          _peerAvatarUrl = hit2.peerUser.avatarUrl;
        });
      }
    } catch (_) {
      // bewusst leise: Header zeigt dann Fallback
    }
  }

  ConversationModel? _findConversation(
    List<ConversationModel> list,
    String conversationId,
  ) {
    for (final c in list) {
      if (c.id == conversationId) return c;
    }
    return null;
  }

  @override
  void dispose() {
    _markReadDebounce?.cancel();
    _textCtrl.dispose();
    _focusNode.dispose();
    _scrollCtrl.dispose();
    _bloc.close();
    super.dispose();
  }

  void _send() {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;

    _bloc.add(ChatSendPressed(text));
    _textCtrl.clear();
    _focusNode.requestFocus();
    unawaited(_scrollToBottom());
  }

  Future<void> _scrollToBottom() async {
    if (!_scrollCtrl.hasClients) return;
    await Future<void>.delayed(const Duration(milliseconds: 60));
    if (!_scrollCtrl.hasClients) return;

    // reverse:true -> bottom = offset 0
    _scrollCtrl.animateTo(
      0,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  void _scheduleMarkReadAndRefresh() {
    _markReadDebounce?.cancel();
    _markReadDebounce = Timer(const Duration(milliseconds: 250), () async {
      try {
        await _createChatRepo().markRead(widget.conversationId);

        // Badge / Inbox UI sofort aktualisieren
        await ref.read(inboxUnreadTotalProvider.notifier).refreshFromServer();
        ref.read(inboxUiTickProvider.notifier).state++;
      } catch (_) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = (_peerName != null && _peerName!.trim().isNotEmpty)
        ? _peerName!.trim()
        : 'Chat';

    final subtitle = (_peerSubtitle != null && _peerSubtitle!.trim().isNotEmpty)
        ? _peerSubtitle!.trim()
        : null;

    return BlocProvider.value(
      value: _bloc,
      child: BlocListener<ChatBloc, ChatState>(
        listenWhen: (prev, next) =>
            prev.messages.length != next.messages.length,
        listener: (context, state) async {
          // neueste Message sichtbar
          await _scrollToBottom();

          // sofort read setzen
          if (state.messages.isNotEmpty) {
            _scheduleMarkReadAndRefresh();
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xfff4f2f0),
          appBar: AppBar(
            elevation: 0,
            backgroundColor: const Color(0xfff4f2f0),
            foregroundColor: Colors.black,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            titleSpacing: 0,
            title: Row(
              children: [
                _Avatar(url: _peerAvatarUrl, fallbackText: title),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      if (subtitle != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black.withValues(alpha: .55),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: BlocBuilder<ChatBloc, ChatState>(
                    builder: (context, state) {
                      if (state.status == ChatStatus.loading &&
                          state.messages.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state.status == ChatStatus.failure) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            state.error ?? 'Something went wrong.',
                            style: TextStyle(
                              color: Colors.black.withValues(alpha: .75),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }

                      final items = state.messages;

                      if (items.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'No messages yet.',
                            style: TextStyle(
                              color: Colors.black.withValues(alpha: .65),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        controller: _scrollCtrl,
                        reverse: true,
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                        itemCount: items.length,
                        itemBuilder: (context, i) {
                          final m = items[i];
                          final isMe = m.isMine;

                          // Gruppierung: Abstand, wenn Sender wechselt
                          final prev = (i + 1 < items.length)
                              ? items[i + 1]
                              : null;
                          final sameSenderAsPrev =
                              prev != null && prev.senderId == m.senderId;

                          // ✅ WhatsApp-Style Tagestrenner:
                          // Zeige Header, wenn Tag sich gegenüber der "neueren" Nachricht ändert.
                          // In reverse:true Liste ist i-1 = neuer (unten), i = älter (weiter oben).
                          final newer = (i - 1 >= 0) ? items[i - 1] : null;
                          final showDayHeader =
                              newer == null ||
                              !_isSameDay(newer.createdAt, m.createdAt);

                          return Column(
                            children: [
                              if (showDayHeader)
                                _DayHeader(text: _formatDayLabel(m.createdAt)),
                              Padding(
                                padding: EdgeInsets.only(
                                  top: sameSenderAsPrev ? 2 : 10,
                                  bottom: 2,
                                ),
                                child: _MessageBubble(
                                  isMe: isMe,
                                  text: m.body,
                                  time: _formatTime(m.createdAt),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
                _Composer(
                  controller: _textCtrl,
                  focusNode: _focusNode,
                  onSend: _send,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final local = dt.toLocal();
    final h = local.hour.toString().padLeft(2, '0');
    final m = local.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    final aa = a.toLocal();
    final bb = b.toLocal();
    return aa.year == bb.year && aa.month == bb.month && aa.day == bb.day;
  }

  String _formatDayLabel(DateTime dt) {
    final d = dt.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final that = DateTime(d.year, d.month, d.day);

    final diffDays = today.difference(that).inDays;

    if (diffDays == 0) return 'Heute';
    if (diffDays == 1) return 'Gestern';

    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year.toString();
    return '$dd.$mm.$yyyy';
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 6),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.black.withValues(alpha: .06)),
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                offset: const Offset(0, 6),
                color: Colors.black.withValues(alpha: .04),
              ),
            ],
          ),
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 12,
              color: Colors.black.withValues(alpha: .75),
              letterSpacing: .2,
            ),
          ),
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.focusNode,
    required this.onSend,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        final sending = state.sending;

        return Container(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
          decoration: BoxDecoration(
            color: const Color(0xfff4f2f0),
            border: Border(
              top: BorderSide(color: Colors.black.withValues(alpha: .06)),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Colors.black.withValues(alpha: .06),
                    ),
                  ),
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    enabled: !sending,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => onSend(),
                    minLines: 1,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Message…',
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: Colors.black.withValues(alpha: .45),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 46,
                height: 46,
                child: ElevatedButton(
                  onPressed: sending ? null : onSend,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    disabledBackgroundColor: Colors.black.withValues(
                      alpha: .35,
                    ),
                    shape: const CircleBorder(),
                    padding: EdgeInsets.zero,
                    elevation: 0,
                  ),
                  child: sending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.isMe,
    required this.text,
    required this.time,
  });

  final bool isMe;
  final String text;
  final String time;

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isMe ? Colors.black : Colors.white;
    final textColor = isMe ? Colors.white : Colors.black;

    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 10, 8),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: isMe
                    ? const Radius.circular(18)
                    : const Radius.circular(6),
                bottomRight: isMe
                    ? const Radius.circular(6)
                    : const Radius.circular(18),
              ),
              border: isMe
                  ? null
                  : Border.all(color: Colors.black.withValues(alpha: .06)),
              boxShadow: [
                BoxShadow(
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                  color: Colors.black.withValues(alpha: .04),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    height: 1.25,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  time,
                  style: TextStyle(
                    color: textColor.withValues(alpha: .7),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, required this.fallbackText});

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
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.accent,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black.withValues(alpha: .06)),
      ),
      clipBehavior: Clip.antiAlias,
      child: (url != null && url!.trim().isNotEmpty)
          ? Image.network(
              url!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _Initials(initials: initials),
            )
          : _Initials(initials: initials),
    );
  }
}

class _Initials extends StatelessWidget {
  const _Initials({required this.initials});
  final String initials;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initials,
        style: const TextStyle(
          fontWeight: FontWeight.w900,
          color: Colors.black,
        ),
      ),
    );
  }
}
