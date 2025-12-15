import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:xyz/features/community/tabs/posts/data/post_models.dart';
import 'package:xyz/features/community/tabs/posts/data/post_repository.dart';
import 'package:xyz/features/community/tabs/posts/logic/comments/comments_bloc.dart';
import 'package:xyz/features/community/tabs/posts/logic/comments/comments_event.dart';
import 'package:xyz/features/community/tabs/posts/logic/comments/comments_state.dart';
import 'package:xyz/features/community/tabs/posts/logic/post/post_bloc.dart';
import 'package:xyz/features/community/tabs/posts/logic/post/post_event.dart';
import 'package:xyz/features/community/tabs/posts/logic/post/post_state.dart';
import 'package:xyz/features/community/tabs/posts/presentation/widgets/comment_composer_bar.dart';
import 'package:xyz/features/community/tabs/posts/presentation/widgets/comment_tile.dart';
import 'package:xyz/features/community/tabs/posts/presentation/widgets/post_card.dart';

class PostDetail extends StatelessWidget {
  const PostDetail({super.key});

  @override
  Widget build(BuildContext context) {
    final initialPost = Get.arguments as PostModel;
    final postBloc = Get.find<PostBloc>();
    final repo = Get.find<PostRepository>();

    // Controller muss irgendwo leben – hier als Stateless ist’s schwierig.
    // Minimal-Lösung: wir erstellen ihn hier pro Build und verwenden ihn nur im Composer.
    // Besser: eigener GetX Controller oder kleines Stateful Wrapper. Für jetzt: ok.
    final composerController = TextEditingController();

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: postBloc),
        BlocProvider(
          create: (_) =>
              CommentsBloc(repo: repo, postBloc: postBloc)
                ..add(CommentsRequested(postId: initialPost.id)),
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
                      final post = postState.feed.firstWhere(
                        (p) => p.id == initialPost.id,
                        orElse: () => initialPost,
                      );

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
                              // Platz damit letzter Kommentar nicht vom Composer verdeckt wird:
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

                // ✅ Facebook-Style Composer unten
                CommentComposerBar(
                  postId: initialPost.id,
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
