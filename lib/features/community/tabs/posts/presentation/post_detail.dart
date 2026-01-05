import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xyz/core/providers/di_providers.dart';
import 'package:xyz/features/community/tabs/posts/logic/comments/comments_bloc.dart';
import 'package:xyz/features/community/tabs/posts/logic/comments/comments_event.dart';
import 'package:xyz/features/community/tabs/posts/logic/comments/comments_state.dart';
import 'package:xyz/features/community/tabs/posts/logic/post/post_bloc.dart';
import 'package:xyz/features/community/tabs/posts/logic/post/post_event.dart';
import 'package:xyz/features/community/tabs/posts/logic/post/post_state.dart';
import 'package:xyz/features/community/tabs/posts/presentation/widgets/comment_composer_bar.dart';
import 'package:xyz/features/community/tabs/posts/presentation/widgets/comment_tile.dart';
import 'package:xyz/features/community/tabs/posts/presentation/widgets/post_card.dart';

class PostDetail extends ConsumerWidget {
  const PostDetail({super.key, required this.postId});

  final String postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postBloc = ref.watch(postBlocProvider);
    final repo = ref.watch(postRepositoryProvider);

    if (postBloc.state.status == PostStatus.initial) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!postBloc.isClosed) postBloc.add(PostRequested());
      });
    }

    final composerController = TextEditingController();

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: postBloc),
        BlocProvider(
          create: (_) =>
              CommentsBloc(repo: repo, postBloc: postBloc)
                ..add(CommentsRequested(postId: postId)),
        ),
      ],
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: const Color(0xfff4f2f0),
            appBar: AppBar(
              elevation: 0,
              backgroundColor: const Color(0xfff4f2f0),
            ),
            body: Column(
              children: [
                Expanded(
                  child: BlocBuilder<PostBloc, PostState>(
                    builder: (context, postState) {
                      final post =
                          postState.feed.where((p) => p.id == postId).isNotEmpty
                          ? postState.feed.firstWhere((p) => p.id == postId)
                          : null;

                      if (post == null) {
                        if (postState.status == PostStatus.loading ||
                            postState.status == PostStatus.initial) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return const Center(child: Text("Post not found."));
                      }

                      return BlocBuilder<CommentsBloc, CommentsState>(
                        builder: (context, commentsState) {
                          final comments =
                              commentsState.commentsByPost[post.id];

                          return CustomScrollView(
                            slivers: [
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    8,
                                    16,
                                    8,
                                  ),
                                  child: PostCard(
                                    post: post,
                                    onLike: () => context.read<PostBloc>().add(
                                      PostLikeToggled(post.id),
                                    ),
                                  ),
                                ),
                              ),
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    8,
                                    16,
                                    4,
                                  ),
                                  child: const Text(
                                    'Comments',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                              const SliverToBoxAdapter(
                                child: Divider(height: 1),
                              ),

                              if (comments == null)
                                const SliverFillRemaining(
                                  hasScrollBody: false,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              else if (comments.isEmpty)
                                const SliverFillRemaining(
                                  hasScrollBody: false,
                                  child: Center(
                                    child: Text('Noch keine Kommentare.'),
                                  ),
                                )
                              else
                                SliverList.builder(
                                  itemCount: comments.length,
                                  itemBuilder: (ctx, index) {
                                    final c = comments[index];
                                    final isExpanded = commentsState
                                        .expandedCommentIds
                                        .contains(c.id);
                                    return Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        16,
                                        12,
                                        16,
                                        0,
                                      ),
                                      child: CommentTile(
                                        postId: post.id,
                                        comment: c,
                                        isExpanded: isExpanded,
                                      ),
                                    );
                                  },
                                ),

                              const SliverToBoxAdapter(
                                child: SizedBox(height: 16),
                              ),
                              const SliverToBoxAdapter(
                                child: SizedBox(height: 120),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),

                CommentComposerBar(
                  postId: postId,
                  controller: composerController,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
