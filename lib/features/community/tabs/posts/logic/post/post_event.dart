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

class PostCommentsCountPatched extends PostEvent {
  final String postId;
  final int delta;
  PostCommentsCountPatched({required this.postId, required this.delta});
}
