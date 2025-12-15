import 'package:equatable/equatable.dart';
import 'package:xyz/features/community/tabs/posts/data/post_models.dart';

enum PostStatus { initial, loading, success, failure }

class PostState extends Equatable {
  final PostStatus status;
  final List<PostModel> feed;
  final String? error;

  const PostState({
    this.status = PostStatus.initial,
    this.feed = const [],
    this.error,
  });

  PostState copyWith({
    PostStatus? status,
    List<PostModel>? feed,
    String? error,
  }) {
    return PostState(
      status: status ?? this.status,
      feed: feed ?? this.feed,
      error: error,
    );
  }

  PostState updatePost(PostModel updated) {
    final idx = feed.indexWhere((p) => p.id == updated.id);
    if (idx == -1) return this;
    final newFeed = [...feed]..[idx] = updated;
    return copyWith(feed: newFeed);
  }

  @override
  List<Object?> get props => [status, feed, error];
}
