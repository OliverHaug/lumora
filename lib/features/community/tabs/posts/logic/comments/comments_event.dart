import 'package:lumora/features/community/tabs/posts/data/comment_model.dart';

abstract class CommentsEvent {}

class CommentsRequested extends CommentsEvent {
  final String postId;
  final bool force;
  CommentsRequested({required this.postId, this.force = false});
}

class CommentRepliesToggled extends CommentsEvent {
  final String postId;
  final String commentId;
  CommentRepliesToggled({required this.postId, required this.commentId});
}

class CommentLikeToggled extends CommentsEvent {
  final String postId;
  final String commentId;
  CommentLikeToggled({required this.postId, required this.commentId});
}

class CommentSubmitted extends CommentsEvent {
  final String postId;
  final String content;
  CommentSubmitted({required this.postId, required this.content});
}

class CommentEditSubmitted extends CommentsEvent {
  final String postId;
  final String commentId;
  final String newContent;
  CommentEditSubmitted({
    required this.postId,
    required this.commentId,
    required this.newContent,
  });
}

class CommentDeleteRequested extends CommentsEvent {
  final String postId;
  final String commentId;
  CommentDeleteRequested({required this.postId, required this.commentId});
}

/// Reply Target (Facebook-Style)
class ReplyTargetSet extends CommentsEvent {
  final String postId;
  final CommentModel target;
  ReplyTargetSet({required this.postId, required this.target});
}

class ReplyTargetCleared extends CommentsEvent {
  final String postId;
  ReplyTargetCleared({required this.postId});
}
