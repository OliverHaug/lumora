import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumora/core/providers/app_providers.dart';
import 'package:lumora/core/theme/app_colors.dart';
import 'package:lumora/features/community/tabs/posts/data/comment_model.dart';
import 'package:lumora/features/community/tabs/posts/logic/comments/comments_bloc.dart';
import 'package:lumora/features/community/tabs/posts/logic/comments/comments_event.dart';
import 'package:lumora/features/community/tabs/posts/presentation/widgets/comment_editor_sheet.dart';

class CommentTile extends ConsumerWidget {
  final String postId;
  final CommentModel comment;
  final bool isExpanded;

  const CommentTile({
    super.key,
    required this.postId,
    required this.comment,
    required this.isExpanded,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final supabase = ref.watch(supabaseClientProvider);
    final currentUserId = supabase.auth.currentUser?.id;
    final isMine = currentUserId != null && currentUserId == comment.author.id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: comment.author.avatarUrl != null
                  ? NetworkImage(comment.author.avatarUrl!)
                  : const AssetImage('assets/img/189.jpg') as ImageProvider,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        comment.author.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Text(comment.author.role),
                      const SizedBox(width: 8),
                      Text(
                        _timeAgo(comment.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(comment.content),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.read<CommentsBloc>().add(
                          CommentLikeToggled(
                            postId: postId,
                            commentId: comment.id,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              comment.youLiked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 18,
                              color: comment.youLiked
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text('${comment.likesCount}'),
                            if (isMine) ...[
                              const SizedBox(width: 18),

                              IconButton(
                                icon: Icon(
                                  Icons.edit_outlined,
                                  color: AppColors.black.withValues(alpha: .6),
                                ),
                                tooltip: 'Edit post',
                                onPressed: () => showEditCommentSheet(
                                  context,
                                  postId: postId,
                                  comment: comment,
                                ),
                              ),

                              IconButton(
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: AppColors.black.withValues(alpha: .6),
                                ),
                                tooltip: 'Delete post',
                                onPressed: () => _confirmDeleteComment(
                                  context,
                                  comment.id,
                                  postId,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(width: 16),

                      GestureDetector(
                        onTap: () => context.read<CommentsBloc>().add(
                          ReplyTargetSet(postId: postId, target: comment),
                        ),
                        child: Text(
                          'Reply',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.accent,
                          ),
                        ),
                      ),

                      if (comment.repliesCount > 0) ...[
                        const SizedBox(width: 18),
                        GestureDetector(
                          onTap: () => context.read<CommentsBloc>().add(
                            CommentRepliesToggled(
                              postId: postId,
                              commentId: comment.id,
                            ),
                          ),
                          child: Text(
                            isExpanded
                                ? 'Hide replies'
                                : 'View ${comment.repliesCount} repl${comment.repliesCount == 1 ? 'y' : 'ies'}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.amber[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),

        if (isExpanded &&
            comment.replies != null &&
            comment.replies!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 36),
            child: _RepliesList(
              postId: postId,
              replies: comment.replies!,
              currentUserId: currentUserId,
            ),
          ),
        ],
      ],
    );
  }

  static String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _RepliesList extends StatelessWidget {
  final String postId;
  final String? currentUserId;
  final List<CommentModel> replies;

  const _RepliesList({
    required this.postId,
    required this.replies,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: replies.map((reply) {
        final isMine = currentUserId == reply.author.id;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 80, width: 1, color: AppColors.accent),
              const SizedBox(width: 12),
              CircleAvatar(
                radius: 16,
                backgroundImage: reply.author.avatarUrl != null
                    ? NetworkImage(reply.author.avatarUrl!)
                    : const AssetImage('assets/img/189.jpg') as ImageProvider,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          reply.author.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Text(reply.author.role),
                        const SizedBox(width: 8),
                        Text(
                          CommentTile._timeAgo(reply.createdAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(reply.content),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.read<CommentsBloc>().add(
                            CommentLikeToggled(
                              postId: postId,
                              commentId: reply.id,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                reply.youLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 16,
                                color: reply.youLiked
                                    ? Colors.red
                                    : Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text('${reply.likesCount}'),
                              if (isMine) ...[
                                const SizedBox(width: 18),

                                IconButton(
                                  icon: Icon(
                                    Icons.edit_outlined,
                                    color: AppColors.black.withValues(
                                      alpha: .6,
                                    ),
                                  ),
                                  tooltip: 'Edit post',
                                  onPressed: () => showEditCommentSheet(
                                    context,
                                    postId: postId,
                                    comment: reply,
                                  ),
                                ),

                                IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: AppColors.black.withValues(
                                      alpha: .6,
                                    ),
                                  ),
                                  tooltip: 'Delete post',
                                  onPressed: () => _confirmDeleteComment(
                                    context,
                                    reply.id,
                                    postId,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () => context.read<CommentsBloc>().add(
                            ReplyTargetSet(postId: postId, target: reply),
                          ),
                          child: Text(
                            'Reply',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

Future<void> _confirmDeleteComment(
  BuildContext context,
  String commentId,
  String postId,
) async {
  final confirmed =
      await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delete comment'),
          content: const Text('Are you sure you want to delete this comment?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Delete'),
            ),
          ],
        ),
      ) ??
      false;

  if (!context.mounted) return;

  if (!confirmed) return;

  context.read<CommentsBloc>().add(
    CommentDeleteRequested(commentId: commentId, postId: postId),
  );
}
