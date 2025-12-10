import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:xyz/core/theme/app_colors.dart';
import 'package:xyz/features/community/tabs/posts/data/comment_model.dart';
import 'package:xyz/features/community/tabs/posts/logic/post/post_bloc.dart';
import 'package:xyz/features/community/tabs/posts/logic/post/post_event.dart';

class CommentTile extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final supabase = Get.find<SupabaseClient>();
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
                  : AssetImage('assets/img/189.jpg'),
            ),
            const SizedBox(height: 12),
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
                        onTap: () => context.read<PostBloc>().add(
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
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () => showReplyBottomSheet(
                          context,
                          postId: postId,
                          parent: comment,
                        ),
                        child: Text(
                          'Reply',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      if (comment.repliesCount > 0) ...[
                        const SizedBox(width: 18),
                        GestureDetector(
                          onTap: () {
                            context.read<PostBloc>().add(
                              CommentRepliesToggled(
                                postId: postId,
                                commentId: comment.id,
                              ),
                            );
                          },
                          child: Text(
                            isExpanded
                                ? 'Hide replies'
                                : 'View ${comment.repliesCount} repl'
                                      '${comment.repliesCount == 1 ? 'y' : 'ies'}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.amber[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],

                      if (isMine)
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              showEditCommentSheet(
                                context,
                                postId: postId,
                                comment: comment,
                              );
                            } else if (value == 'delete') {
                              _confirmDelete(context, postId, comment);
                            }
                          },
                          itemBuilder: (ctx) => const [
                            PopupMenuItem(value: 'edit', child: Text('Edit')),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(margin: const EdgeInsets.only(left: 20, right: 20)),
              Expanded(
                child: _RepliesList(postId: postId, replies: comment.replies!),
              ),
            ],
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
  final List<CommentModel> replies;

  const _RepliesList({required this.postId, required this.replies});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final supabase = Get.find<SupabaseClient>();
    final currentUserId = supabase.auth.currentUser?.id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: replies.map((reply) {
        final isMine =
            currentUserId != null && currentUserId == reply.author.id;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 80, width: 1, color: AppColors.accent),
              const SizedBox(width: 15),
              CircleAvatar(
                radius: 16,
                backgroundImage: reply.author.avatarUrl != null
                    ? NetworkImage(reply.author.avatarUrl!)
                    : AssetImage('assets/img/189.jpg'),
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
                          onTap: () => context.read<PostBloc>().add(
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
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () => showReplyBottomSheet(
                            context,
                            postId: postId,
                            parent: reply,
                          ),
                          child: Text(
                            'Reply',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (isMine) ...[
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () => showEditCommentSheet(
                              context,
                              postId: postId,
                              comment: reply,
                            ),
                            child: Text(
                              "Edit",
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () => _confirmDelete(context, postId, reply),
                            child: Text(
                              "Delete",
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    // Falls dieses Reply selbst wieder Replies hat,
                    // werden sie dank _loadThread schon in reply.replies hängen
                    if (reply.replies != null && reply.replies!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _RepliesList(
                              postId: postId,
                              replies: reply.replies!,
                            ),
                          ),
                        ],
                      ),
                    ],
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

Future<void> showReplyBottomSheet(
  BuildContext context, {
  required String postId,
  required CommentModel parent,
}) {
  final controller = TextEditingController();

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      final bottom = MediaQuery.of(ctx).viewInsets.bottom;

      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // kleiner „Header“
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Reply to ${parent.author.name}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              parent.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Write your reply...',
                border: OutlineInputBorder(),
              ),
              minLines: 1,
              maxLines: 5,
              onSubmitted: (_) => _submitReply(ctx, controller, postId, parent),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () => _submitReply(ctx, controller, postId, parent),
                icon: const Icon(Icons.send, size: 18),
                label: const Text('Reply'),
              ),
            ),
          ],
        ),
      );
    },
  );
}

void _submitReply(
  BuildContext ctx,
  TextEditingController controller,
  String postId,
  CommentModel parent,
) {
  final text = controller.text.trim();
  if (text.isEmpty) return;

  Get.find<PostBloc>().add(
    CommentSubmitted(postId: postId, content: text, parentId: parent.id),
  );

  Navigator.of(ctx).pop();
}

Future<void> showEditCommentSheet(
  BuildContext context, {
  required String postId,
  required CommentModel comment,
}) {
  final controller = TextEditingController(text: comment.content);
  final bloc = context.read<PostBloc>();

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) {
      final bottom = MediaQuery.of(sheetContext).viewInsets.bottom;

      void submit() {
        final text = controller.text.trim();
        if (text.isEmpty || text == comment.content) {
          Navigator.of(sheetContext).pop();
          return;
        }

        bloc.add(
          CommentEditSubmitted(
            postId: postId,
            commentId: comment.id,
            newContent: text,
          ),
        );

        Navigator.of(sheetContext).pop();
      }

      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Edit comment',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(sheetContext).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              maxLines: 5,
              minLines: 1,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              onSubmitted: (_) => submit(),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: submit,
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Future<void> _confirmDelete(
  BuildContext context,
  String postId,
  CommentModel comment,
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

  if (!confirmed) return;

  context.read<PostBloc>().add(
    CommentDeleteRequested(postId: postId, commentId: comment.id),
  );
}
