import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:xyz/features/community/tabs/posts/data/post_models.dart';
import 'package:xyz/features/community/tabs/posts/logic/post/post_bloc.dart';
import 'package:xyz/features/community/tabs/posts/logic/post/post_event.dart';
import 'package:xyz/features/community/tabs/posts/logic/post/post_state.dart';
import 'package:xyz/features/community/tabs/posts/presentation/widgets/comment_tile.dart';
import 'package:xyz/features/community/tabs/posts/presentation/widgets/post_card.dart';

class PostDetail extends StatelessWidget {
  const PostDetail({super.key});

  @override
  Widget build(BuildContext context) {
    final initialPost = Get.arguments as PostModel;
    final bloc = Get.find<PostBloc>();

    return BlocProvider.value(
      value: bloc,
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
                    builder: (context, state) {
                      final post = state.feed.firstWhere(
                        (p) => p.id == initialPost.id,
                        orElse: () => initialPost,
                      );
                      final comments = state.commentsByPost[post.id];

                      // falls noch nicht geladen: Event feuern
                      if (comments == null) {
                        context.read<PostBloc>().add(
                          PostCommentsRequested(post.id),
                        );
                      }

                      return CustomScrollView(
                        slivers: [
                          // Post-Karte oben
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                              child: PostCard(
                                post: post,
                                onLike: () => context.read<PostBloc>().add(
                                  PostLikeToggled(post.id),
                                ),
                              ),
                            ),
                          ),

                          // "Comments" Header
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                              child: Text(
                                'Comments',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          const SliverToBoxAdapter(child: Divider(height: 1)),

                          // Ladezustand / leer / Liste
                          if (comments == null)
                            const SliverFillRemaining(
                              hasScrollBody: false,
                              child: Center(child: CircularProgressIndicator()),
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
                                final isExpanded = state.expandedCommentIds
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
                          const SliverToBoxAdapter(child: SizedBox(height: 16)),
                        ],
                      );
                    },
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
