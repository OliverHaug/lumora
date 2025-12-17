import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:xyz/core/theme/app_colors.dart';
import 'package:xyz/features/community/logic/community_bloc.dart';
import 'package:xyz/features/community/logic/community_event.dart';
import 'package:xyz/features/community/tabs/posts/data/post_models.dart';

class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
    required this.onLike,
    this.onEdit,
    this.onDelete,
  });

  final PostModel post;
  final VoidCallback onLike;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final supabase = Get.find<SupabaseClient>();
    final uid = supabase.auth.currentUser?.id;
    final isMine = uid != null && uid == post.author.id;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            offset: const Offset(0, 2),
            color: AppColors.black.withOpacity(.06),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    print(post.author.id);
                    context.read<CommunityBloc>().add(
                      CommunityShowProfile(post.author.id),
                    );
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundImage: (post.author.avatarUrl != null)
                            ? NetworkImage(post.author.avatarUrl!)
                            : null,
                        child: (post.author.avatarUrl == null)
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.author.name,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Text(post.author.role),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                const SizedBox(width: 12),
                Text(
                  _timeShort(post.createdAt),
                  style: TextStyle(color: AppColors.black.withOpacity(.55)),
                ),
                Spacer(),
              ],
            ),
          ),

          if (post.content != null && post.content!.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(post.content!),
            ),

          if (post.imageUrl != null) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: AspectRatio(
                  aspectRatio: 4 / 4,
                  child: Image.network(
                    post.imageUrl!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const ColoredBox(
                      color: Color(0xFFF6F4EF),
                      child: Center(child: Icon(Icons.broken_image)),
                    ),
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 4, 6, 8),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    post.youLiked ? Icons.favorite : Icons.favorite_border,
                    color: post.youLiked
                        ? Colors.red
                        : AppColors.black.withOpacity(.6),
                  ),
                  onPressed: onLike,
                ),
                Text(
                  '${post.likesCount}',
                  style: TextStyle(
                    color: AppColors.black.withOpacity(.6),
                    fontSize: 16,
                  ),
                ),

                const SizedBox(width: 18),
                Icon(
                  Icons.mode_comment_outlined,
                  color: AppColors.black.withOpacity(.6),
                ),
                const SizedBox(width: 12),
                Text(
                  '${post.commentsCount}',
                  style: TextStyle(
                    color: AppColors.black.withOpacity(.6),
                    fontSize: 16,
                  ),
                ),
                if (isMine && (onEdit != null || onDelete != null)) ...[
                  const SizedBox(width: 18),
                  if (onEdit != null)
                    IconButton(
                      icon: Icon(
                        Icons.edit_outlined,
                        color: AppColors.black.withOpacity(.6),
                      ),
                      tooltip: 'Edit post',
                      onPressed: onEdit,
                    ),
                  if (onDelete != null)
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: AppColors.black.withOpacity(.6),
                      ),
                      tooltip: 'Delete post',
                      onPressed: onDelete,
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _timeShort(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}
