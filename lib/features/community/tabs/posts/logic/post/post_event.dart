abstract class PostEvent {}

class PostRequested extends PostEvent {
  final bool forceRefresh;
  PostRequested({this.forceRefresh = false});
}

class PostCreated extends PostEvent {
  final String content;
  final String? imageUrl;

  PostCreated({required this.content, this.imageUrl});
}

class PostEditSubmitted extends PostEvent {
  final String postId;
  final String content;
  final String? imageUrl;

  PostEditSubmitted({
    required this.postId,
    required this.content,
    this.imageUrl,
  });
}

class PostDeleteRequested extends PostEvent {
  final String postId;
  PostDeleteRequested(this.postId);
}

class PostLikeToggled extends PostEvent {
  final String postId;
  PostLikeToggled(this.postId);
}

class CommentLikeToggled extends PostEvent {
  final String postId;
  final String commentId;

  CommentLikeToggled({required this.postId, required this.commentId});
}

class PostCommentsRequested extends PostEvent {
  final String postId;
  PostCommentsRequested(this.postId);
}

class CommentRepliesToggled extends PostEvent {
  final String postId;
  final String commentId;

  CommentRepliesToggled({required this.postId, required this.commentId});
}

class CommentSubmitted extends PostEvent {
  final String postId;
  final String content;
  final String? parentId;

  CommentSubmitted({
    required this.postId,
    required this.content,
    this.parentId,
  });
}

class CommentEditSubmitted extends PostEvent {
  final String postId;
  final String commentId;
  final String newContent;

  CommentEditSubmitted({
    required this.postId,
    required this.commentId,
    required this.newContent,
  });
}

class CommentDeleteRequested extends PostEvent {
  final String postId;
  final String commentId;

  CommentDeleteRequested({required this.postId, required this.commentId});
}
