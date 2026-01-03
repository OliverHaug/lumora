import 'package:flutter/material.dart';
import 'package:xyz/core/theme/app_colors.dart';

class ProfileMomentsSlider extends StatelessWidget {
  final List<String> urls;
  final bool isMe;
  final VoidCallback? onEdit;

  const ProfileMomentsSlider({
    super.key,
    required this.urls,
    required this.isMe,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    if (urls.isEmpty) {
      return Container(
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(
          child: Text(isMe ? 'Add some moments.' : 'No moments yet.'),
        ),
      );
    }

    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: urls.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final url = urls[i];
          return ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.6,
                  child: Image.network(
                    url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const ColoredBox(
                      color: Color(0xFFF6F4EF),
                      child: Center(child: Icon(Icons.broken_image)),
                    ),
                  ),
                ),
                if (isMe && onEdit != null && i == 0)
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .9),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.edit_outlined,
                          color: AppColors.accent,
                        ),
                        onPressed: onEdit,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
