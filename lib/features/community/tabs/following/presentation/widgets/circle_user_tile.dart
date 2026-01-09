import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lumora/core/theme/app_colors.dart';
import '../../data/circle_user_model.dart';

class CircleUserTile extends StatelessWidget {
  final CircleUserModel circleUser;
  final VoidCallback onToggleFollow;

  const CircleUserTile({
    super.key,
    required this.circleUser,
    required this.onToggleFollow,
  });

  @override
  Widget build(BuildContext context) {
    final isFollowed = circleUser.isFollowed;
    final user = circleUser.user;

    final subtitle = (user.bio != null && user.bio!.trim().isNotEmpty)
        ? user.bio!
        : user.role;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            offset: const Offset(0, 2),
            color: Colors.black.withValues(alpha: .05),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => context.go('/community/profile/${user.id}'),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundImage: user.avatarUrl != null
                        ? NetworkImage(user.avatarUrl!)
                        : null,
                    child: user.avatarUrl == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name.isEmpty ? 'Unknown' : user.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.black.withValues(alpha: .55),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: isFollowed ? Colors.black87 : Colors.white,
              backgroundColor: isFollowed ? Colors.white : AppColors.accent,
              side: BorderSide(
                color: isFollowed ? Colors.black12 : AppColors.accent,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            ),
            onPressed: onToggleFollow,
            child: Row(
              children: [
                if (!isFollowed) ...[
                  const Icon(Icons.add, size: 18),
                  const SizedBox(width: 6),
                ],
                Text(
                  isFollowed ? 'Unfollow' : 'Follow',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
