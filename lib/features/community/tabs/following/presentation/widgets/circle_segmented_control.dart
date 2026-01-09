import 'package:flutter/material.dart';
import 'package:lumora/core/theme/app_colors.dart';
import '../../logic/circle_event.dart';

class CircleSegmentedControl extends StatelessWidget {
  final CircleTabMode mode;
  final ValueChanged<CircleTabMode> onChanged;

  const CircleSegmentedControl({
    super.key,
    required this.mode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isFollowing = mode == CircleTabMode.following;

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            offset: const Offset(0, 2),
            color: Colors.black.withValues(alpha: .06),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _Chip(
              label: 'Following',
              selected: isFollowing,
              onTap: () => onChanged(CircleTabMode.following),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _Chip(
              label: 'Discover',
              selected: !isFollowing,
              onTap: () => onChanged(CircleTabMode.discover),
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
              fontWeight: FontWeight.w700,
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
