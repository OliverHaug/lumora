import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumora/core/theme/app_colors.dart';
import 'package:lumora/features/community/tabs/posts/logic/comments/comments_bloc.dart';
import 'package:lumora/features/community/tabs/posts/logic/comments/comments_event.dart';
import 'package:lumora/features/community/tabs/posts/logic/comments/comments_state.dart';

class CommentComposerBar extends StatelessWidget {
  final String postId;
  final TextEditingController controller;

  const CommentComposerBar({
    super.key,
    required this.postId,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CommentsBloc, CommentsState>(
      buildWhen: (p, n) => p.replyTarget(postId) != n.replyTarget(postId),
      builder: (context, state) {
        final target = state.replyTarget(postId);
        final prefix = target == null ? '' : '@${target.author.name} ';

        // Wenn target gesetzt ist, Prefix einfügen (nur wenn noch nicht drin)
        if (target != null && !controller.text.startsWith(prefix)) {
          controller.value = TextEditingValue(
            text: prefix,
            selection: TextSelection.collapsed(offset: prefix.length),
          );
        }

        return Container(
          padding: EdgeInsets.only(
            left: 12,
            right: 12,
            top: 10,
            bottom: 10 + MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0x11000000))),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Write a comment...',
                    filled: true,
                    fillColor: const Color(0xffF5F1EA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.accent.withValues(alpha: .5),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.accent),
                    ),
                  ),

                  onChanged: (v) {
                    // Wenn User den Prefix entfernt → ReplyMode aus
                    final currentTarget = context
                        .read<CommentsBloc>()
                        .state
                        .replyTarget(postId);
                    if (currentTarget == null) return;

                    final pfx = '@${currentTarget.author.name} ';
                    if (!v.startsWith(pfx)) {
                      context.read<CommentsBloc>().add(
                        ReplyTargetCleared(postId: postId),
                      );
                    }
                  },

                  onSubmitted: (_) => _submit(context),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.send_rounded),
                onPressed: () => _submit(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _submit(BuildContext context) {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    // Wenn ReplyTarget aktiv ist, enthält controller den Prefix.
    // Der Prefix soll NICHT im Comment landen:
    final target = context.read<CommentsBloc>().state.replyTarget(postId);
    final prefix = target == null ? '' : '@${target.author.name} ';
    final cleaned = target == null
        ? text
        : text.replaceFirst(prefix, '').trim();

    if (cleaned.isEmpty) return;

    context.read<CommentsBloc>().add(
      CommentSubmitted(postId: postId, content: cleaned),
    );
    controller.clear();
    FocusManager.instance.primaryFocus?.unfocus();
  }
}
