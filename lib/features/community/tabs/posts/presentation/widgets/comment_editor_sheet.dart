import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumora/features/community/tabs/posts/data/comment_model.dart';
import 'package:lumora/features/community/tabs/posts/logic/comments/comments_bloc.dart';
import 'package:lumora/features/community/tabs/posts/logic/comments/comments_event.dart';

Future<void> showEditCommentSheet(
  BuildContext context, {
  required String postId,
  required CommentModel comment,
}) {
  final controller = TextEditingController(text: comment.content);

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

        sheetContext.read<CommentsBloc>().add(
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
