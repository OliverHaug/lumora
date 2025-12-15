// ... imports bleiben, aber PostCommentsRequested entfernen!
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
        if (!bloc.isClosed) bloc.add(PostRequested());
      });
    }

    return Scaffold(
      floatingActionButton: IconButton.filled(
        onPressed: () => showPostEditorSheet(context, bloc: bloc),
        icon: const Icon(Icons.add),
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
