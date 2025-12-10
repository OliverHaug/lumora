import 'package:equatable/equatable.dart';
import 'package:xyz/features/community/tabs/posts/data/comment_model.dart';
import 'package:xyz/features/community/tabs/posts/data/post_models.dart';

enum PostStatus { initial, loading, success, failure }

class PostState extends Equatable {
  final PostStatus status;
  final List<PostModel> feed;
  final String? error;
  final Map<String, List<CommentModel>> commentsByPost;
  final Set<String> expandedCommentIds;

  const PostState({
    this.status = PostStatus.initial,
    this.feed = const [],
    this.error,
    this.commentsByPost = const {},
    this.expandedCommentIds = const {},
  });

  PostState copyWith({
    PostStatus? status,
    List<PostModel>? feed,
    String? error,
    Map<String, List<CommentModel>>? commentsByPost,
    Set<String>? expandedCommentIds,
    CommentModel? replyTarget,
  }) {
    return PostState(
      status: status ?? this.status,
      feed: feed ?? this.feed,
      error: error,
      commentsByPost: commentsByPost ?? this.commentsByPost,
      expandedCommentIds: expandedCommentIds ?? this.expandedCommentIds,
    );
  }

  PostState updatePost(PostModel updated) {
    final idx = feed.indexWhere((p) => p.id == updated.id);
    if (idx == -1) return this;
    final newFeed = [...feed]..[idx] = updated;
    return copyWith(feed: newFeed);
  }

  @override
  List<Object?> get props => [
    status,
    feed,
    error,
    commentsByPost,
    expandedCommentIds,
  ];
}
