import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xyz/features/community/tabs/posts/data/post_repository.dart';
import 'package:xyz/features/community/tabs/posts/logic/post/post_event.dart';
import 'package:xyz/features/community/tabs/posts/logic/post/post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final PostRepository _repo;

  PostBloc(this._repo) : super(const PostState()) {
    on<PostRequested>(_onFeedRequested);
    on<PostCreated>(_onPostCreated);
    on<PostEditSubmitted>(_onPostEditSubmitted);
    on<PostDeleteRequested>(_onPostDeleteRequested);
    on<PostLikeToggled>(_onLikeToggled);
    on<PostCommentsCountPatched>(_onCommentsCountPatched);
  }

  Future<void> _onFeedRequested(
    PostRequested e,
    Emitter<PostState> emit,
  ) async {
    if (state.status == PostStatus.success && !e.forceRefresh) return;

    emit(state.copyWith(status: PostStatus.loading, error: null));
    try {
      final posts = await _repo.fetchFeed(limit: 25);
      emit(state.copyWith(status: PostStatus.success, feed: posts));
    } catch (err) {
      emit(state.copyWith(status: PostStatus.failure, error: err.toString()));
    }
  }

  Future<void> _onPostCreated(PostCreated e, Emitter<PostState> emit) async {
    try {
      await _repo.createPost(content: e.content, imageUrl: e.imageUrl);
      add(PostRequested(forceRefresh: true));
    } catch (err) {
      emit(state.copyWith(error: err.toString()));
    }
  }

  Future<void> _onPostEditSubmitted(
    PostEditSubmitted e,
    Emitter<PostState> emit,
  ) async {
    try {
      await _repo.updatePost(
        postId: e.postId,
        content: e.content,
        imageUrl: e.imageUrl,
      );
      add(PostRequested(forceRefresh: true));
    } catch (err) {
      emit(state.copyWith(error: err.toString()));
    }
  }

  Future<void> _onPostDeleteRequested(
    PostDeleteRequested e,
    Emitter<PostState> emit,
  ) async {
    try {
      await _repo.deletePost(e.postId);
      add(PostRequested(forceRefresh: true));
    } catch (err) {
      emit(state.copyWith(error: err.toString()));
    }
  }

  Future<void> _onLikeToggled(
    PostLikeToggled e,
    Emitter<PostState> emit,
  ) async {
    final post = state.feed.firstWhere((p) => p.id == e.postId);
    final optimistic = post.youLiked
        ? post.copyWith(youLiked: false, likesCount: post.likesCount - 1)
        : post.copyWith(youLiked: true, likesCount: post.likesCount + 1);

    emit(state.updatePost(optimistic));

    try {
      if (post.youLiked) {
        await _repo.unlikePost(post.id);
      } else {
        await _repo.likePost(post.id);
      }
    } catch (_) {
      emit(state.updatePost(post));
    }
  }

  void _onCommentsCountPatched(
    PostCommentsCountPatched e,
    Emitter<PostState> emit,
  ) {
    final idx = state.feed.indexWhere((p) => p.id == e.postId);
    if (idx == -1) return;
    final post = state.feed[idx];
    final updated = post.copyWith(commentsCount: post.commentsCount + e.delta);
    final newFeed = [...state.feed]..[idx] = updated;
    emit(state.copyWith(feed: newFeed));
  }
}
