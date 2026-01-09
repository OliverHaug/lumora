import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xyz/core/providers/inbox_realtime_providers.dart';

class InboxBadgeIcon extends ConsumerWidget {
  const InboxBadgeIcon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref
        .watch(inboxUnreadTotalProvider)
        .maybeWhen(data: (v) => v, orElse: () => 0);

    return BadgeIcon(icon: Icons.forum_outlined, count: unread);
  }
}

class BadgeIcon extends StatelessWidget {
  final IconData icon;
  final int count;

  const BadgeIcon({super.key, required this.icon, required this.count});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        if (count > 0)
          Positioned(
            right: -8,
            top: -6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                count > 99 ? '99+' : '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
