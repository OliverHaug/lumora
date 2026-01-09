import 'package:flutter/material.dart';
import 'package:lumora/core/theme/app_colors.dart';
import 'package:lumora/features/settings/data/user_model.dart';

class ProfileHeader extends StatelessWidget {
  final UserModel user;
  final bool isMe;
  final VoidCallback? onEditAvatar;
  final VoidCallback? onConnect;

  const ProfileHeader({
    super.key,
    required this.user,
    required this.isMe,
    this.onEditAvatar,
    this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 46,
              backgroundImage: user.avatarUrl != null
                  ? NetworkImage(user.avatarUrl!)
                  : null,
              child: user.avatarUrl == null
                  ? const Icon(Icons.person, size: 42)
                  : null,
            ),
            if (isMe && onEditAvatar != null)
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: onEditAvatar,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          user.name,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.black12),
          ),
          child: Text(
            user.role.toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: AppColors.accent,
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Connect button nur bei fremdem Profil
        if (!isMe)
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: onConnect,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Connect',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
      ],
    );
  }
}
