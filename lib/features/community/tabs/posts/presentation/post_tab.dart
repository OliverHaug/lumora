// ... imports bleiben, aber PostCommentsRequested entfernen!
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:xyz/core/providers/di_providers.dart';
import 'package:xyz/features/community/tabs/posts/data/post_models.dart';
import 'package:xyz/features/community/tabs/posts/logic/post/post_bloc.dart';
import 'package:xyz/features/community/tabs/posts/logic/post/post_event.dart';
import 'package:xyz/features/community/tabs/posts/logic/post/post_state.dart';
import 'package:xyz/features/community/tabs/posts/presentation/widgets/post_card.dart';
import 'package:xyz/features/community/tabs/posts/presentation/widgets/post_editor_sheet.dart';

class PostTab extends ConsumerWidget {
  const PostTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bloc = ref.watch(postBlocProvider);
    final repo = ref.read(postRepositoryProvider);

    if (bloc.state.status == PostStatus.initial) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!bloc.isClosed) bloc.add(PostRequested());
      });
    }

    return Scaffold(
      floatingActionButton: IconButton.filled(
        onPressed: () => showPostEditorSheet(context, bloc: bloc, repo: repo),
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
                      context.go('/community/posts/tweet/${post.id}');
                    },
                    child: PostCard(
                      post: post,
                      onLike: () =>
                          ctx.read<PostBloc>().add(PostLikeToggled(post.id)),
                      onEdit: () => showPostEditorSheet(
                        context,
                        post: post,
                        bloc: bloc,
                        repo: repo,
                      ),
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
