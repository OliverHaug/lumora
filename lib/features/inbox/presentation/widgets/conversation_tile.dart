import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:xyz/core/theme/app_colors.dart';
=======
>>>>>>> 94ee73e (feat(inbox,chat): add realtime inbox/chat, caching and UX improvements)
import 'package:xyz/features/inbox/data/models/conversation_model.dart';

class ConversationTile extends StatelessWidget {
  final ConversationModel conversation;
  final VoidCallback onTap;

  const ConversationTile({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    final u = conversation.peerUser;
=======
    final name = conversation.peerUser.name.trim().isEmpty
        ? 'Unknown'
        : conversation.peerUser.name.trim();

    final avatarUrl = (conversation.peerUser.avatarUrl ?? '').trim();

    final lastText = conversation.lastMessageText.trim().isEmpty
        ? 'No messages yet.'
        : conversation.lastMessageText.trim();

    final lastAt = conversation.lastMessageAt; // DateTime?

    final timeText = _formatTileTime(
      lastAt,
    ); // String? (null => nichts anzeigen)

    final unread = conversation.unreadCount;
    final showUnread = unread > 0;
>>>>>>> 94ee73e (feat(inbox,chat): add realtime inbox/chat, caching and UX improvements)

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
<<<<<<< HEAD
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage:
                      (u.avatarUrl != null && u.avatarUrl!.isNotEmpty)
                      ? NetworkImage(u.avatarUrl!)
                      : null,
                  child: (u.avatarUrl == null || u.avatarUrl!.isEmpty)
                      ? const Icon(Icons.person)
                      : null,
                ),
                if (conversation.isOnline)
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

=======
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black.withValues(alpha: .06)),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              offset: const Offset(0, 6),
              color: Colors.black.withValues(alpha: .04),
            ),
          ],
        ),
        child: Row(
          children: [
            _Avatar(
              url: avatarUrl.isEmpty ? null : avatarUrl,
              fallbackText: name,
            ),
            const SizedBox(width: 12),

            // Text part
>>>>>>> 94ee73e (feat(inbox,chat): add realtime inbox/chat, caching and UX improvements)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
<<<<<<< HEAD
                  Text(
                    u.name.isEmpty ? 'Unknown' : u.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    conversation.lastMessageText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: .55),
                      fontWeight: FontWeight.w600,
                    ),
=======
                  // Name + time
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      if (timeText != null) ...[
                        const SizedBox(width: 10),
                        Text(
                          timeText,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black.withValues(alpha: .55),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Last message + unread badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.black.withValues(alpha: .62),
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      if (showUnread) ...[
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            unread > 99 ? '99+' : '$unread',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ],
>>>>>>> 94ee73e (feat(inbox,chat): add realtime inbox/chat, caching and UX improvements)
                  ),
                ],
              ),
            ),
<<<<<<< HEAD

            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _timeLabel(conversation.lastMessageAt),
                  style: TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                if (conversation.unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${conversation.unreadCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 20),
              ],
            ),
=======
>>>>>>> 94ee73e (feat(inbox,chat): add realtime inbox/chat, caching and UX improvements)
          ],
        ),
      ),
    );
  }

<<<<<<< HEAD
  String _timeLabel(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${dt.day}.${dt.month}.';
=======
  /// WhatsApp-like:
  /// - heute: HH:mm
  /// - gestern: Yesterday
  /// - sonst: dd.MM
  /// - null => nix anzeigen
  String? _formatTileTime(DateTime? dt) {
    if (dt == null) return null;

    final local = dt.toLocal();
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);
    final dday = DateTime(local.year, local.month, local.day);

    final diffDays = today.difference(dday).inDays;

    if (diffDays == 0) {
      final h = local.hour.toString().padLeft(2, '0');
      final m = local.minute.toString().padLeft(2, '0');
      return '$h:$m';
    }

    if (diffDays == 1) return 'Yesterday';

    final dd = local.day.toString().padLeft(2, '0');
    final mm = local.month.toString().padLeft(2, '0');
    return '$dd.$mm';
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, required this.fallbackText});

  final String? url;
  final String fallbackText;

  @override
  Widget build(BuildContext context) {
    final initials = _initials(fallbackText);

    return Container(
      width: 52,
      height: 52,
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
              errorBuilder: (_, __, ___) => _Initials(initials: initials),
            )
          : _Initials(initials: initials),
    );
  }

  String _initials(String name) {
    final t = name.trim();
    if (t.isEmpty) return '?';
    final parts = t.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    final take = parts.take(2).toList();
    final chars = take.map((p) => p[0].toUpperCase()).join();
    return chars.isEmpty ? '?' : chars;
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
>>>>>>> 94ee73e (feat(inbox,chat): add realtime inbox/chat, caching and UX improvements)
  }
}
