import 'package:equatable/equatable.dart';
import 'package:lumora/features/community/tabs/posts/data/comment_model.dart';

class CommentsState extends Equatable {
  final Map<String, List<CommentModel>> commentsByPost;
  final Set<String> expandedCommentIds;
  final Map<String, CommentModel?> replyTargetByPost;
  final String? error;

  const CommentsState({
    this.commentsByPost = const {},
    this.expandedCommentIds = const {},
    this.replyTargetByPost = const {},
    this.error,
  });

  CommentsState copyWith({
    Map<String, List<CommentModel>>? commentsByPost,
    Set<String>? expandedCommentIds,
    Map<String, CommentModel?>? replyTargetByPost,
    String? error,
  }) {
    return CommentsState(
      commentsByPost: commentsByPost ?? this.commentsByPost,
      expandedCommentIds: expandedCommentIds ?? this.expandedCommentIds,
      replyTargetByPost: replyTargetByPost ?? this.replyTargetByPost,
      error: error,
    );
  }

  CommentModel? replyTarget(String postId) => replyTargetByPost[postId];

  @override
  List<Object?> get props => [
    commentsByPost,
    expandedCommentIds,
    replyTargetByPost,
    error,
  ];
}
