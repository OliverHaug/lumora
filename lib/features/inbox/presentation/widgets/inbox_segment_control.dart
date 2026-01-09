import 'package:flutter/material.dart';
import 'package:xyz/core/theme/app_colors.dart';
<<<<<<< HEAD
import 'package:xyz/features/inbox/logic/inbox_event.dart';
=======
import 'package:xyz/features/inbox/logic/inbox_bloc.dart';
>>>>>>> 94ee73e (feat(inbox,chat): add realtime inbox/chat, caching and UX improvements)

class InboxSegmentedControl extends StatelessWidget {
  final InboxTabMode mode;
  final ValueChanged<InboxTabMode> onChanged;
  final bool notificationsHasDot;

  const InboxSegmentedControl({
    super.key,
    required this.mode,
    required this.onChanged,
    this.notificationsHasDot = false,
  });

  @override
  Widget build(BuildContext context) {
    final isMessages = mode == InboxTabMode.messages;

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .65),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: _Chip(
              label: 'Messages',
              selected: isMessages,
              onTap: () => onChanged(InboxTabMode.messages),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                _Chip(
                  label: 'Notifications',
                  selected: !isMessages,
                  onTap: () => onChanged(InboxTabMode.notifications),
                ),
                if (notificationsHasDot)
                  Positioned(
                    right: 18,
                    top: 10,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: selected
                  ? Colors.white
                  : Colors.black.withValues(alpha: .7),
            ),
          ),
        ),
      ),
    );
  }
}
