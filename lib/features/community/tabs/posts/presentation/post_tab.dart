import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:xyz/features/community/tabs/posts/data/post_models.dart';
import 'package:xyz/features/community/tabs/posts/logic/post/post_bloc.dart';
import 'package:xyz/features/community/tabs/posts/logic/post/post_event.dart';
import 'package:xyz/features/community/tabs/posts/logic/post/post_state.dart';
import 'package:xyz/features/community/tabs/posts/presentation/widgets/post_card.dart';
import 'package:xyz/features/community/tabs/posts/presentation/widgets/post_editor_sheet.dart';

class PostTab extends StatelessWidget {
  const PostTab({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = Get.find<PostBloc>();

    if (bloc.state.status == PostStatus.initial) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!bloc.isClosed) {
          bloc.add(PostRequested());
        }
      });
    }

    return Scaffold(
      floatingActionButton: IconButton.filled(
        onPressed: () => showPostEditorSheet(context, bloc: bloc),
        icon: Icon(Icons.add),
      ),
      body: BlocProvider.value(
        value: bloc,
        child: BlocBuilder<PostBloc, PostState>(
          builder: (context, state) {
            if (state.status == PostStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == PostStatus.failure) {
              return Center(child: Text(state.error ?? 'Failure to load feed'));
            }

            final feed = state.feed;

            return RefreshIndicator(
              onRefresh: () async => context.read<PostBloc>().add(
                PostRequested(forceRefresh: true),
              ),
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 120),
                itemCount: feed.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (ctx, i) {
                  final post = feed[i];
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      Get.toNamed('/community/tweet', arguments: post);
                      ctx.read<PostBloc>().add(PostCommentsRequested(post.id));
                    },
                    child: PostCard(
                      post: post,
                      onLike: () =>
                          ctx.read<PostBloc>().add(PostLikeToggled(post.id)),
                      onEdit: () =>
                          showPostEditorSheet(context, post: post, bloc: bloc),
                      onDelete: () => _confirmDeletePost(ctx, post, bloc),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

void _showEditPostSheet(BuildContext context, PostModel post, PostBloc bloc) {
  final controller = TextEditingController(text: post.content);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) {
      final bottom = MediaQuery.of(sheetContext).viewInsets.bottom;

      void submit() {
        final text = controller.text.trim();
        if (text.isEmpty || text == post.content) {
          Navigator.of(sheetContext).pop();
          return;
        }

        bloc.add(
          PostEditSubmitted(
            postId: post.id,
            content: text,
            imageUrl: post.imageUrl, // falls du das Feld hast
          ),
        );

        Navigator.of(sheetContext).pop();
      }

      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Edit post',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(sheetContext).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              autofocus: true,
              minLines: 3,
              maxLines: 6,
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

Future<void> _confirmDeletePost(
  BuildContext context,
  PostModel post,
  PostBloc bloc,
) async {
  final confirmed =
      await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delete post'),
          content: const Text('Are you sure you want to delete this post?'),
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

  bloc.add(PostDeleteRequested(post.id));
}
