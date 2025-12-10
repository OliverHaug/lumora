import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xyz/features/community/tabs/posts/data/comment_model.dart';
import 'package:xyz/features/community/tabs/posts/data/post_models.dart';
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
    on<PostCommentsRequested>(_onCommentsRequested);
    on<CommentRepliesToggled>(_onCommentRepliesToggled);
    on<CommentLikeToggled>(_onCommentLikeToggled);
    on<CommentSubmitted>(_onCommentSubmitted);
    on<CommentEditSubmitted>(_onCommentEditSubmitted);
    on<CommentDeleteRequested>(_onCommentDeleteRequested);
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
    } catch (err) {
      emit(state.updatePost(post));
    }
  }

  Future<void> _onCommentsRequested(
    PostCommentsRequested e,
    Emitter<PostState> emit,
  ) async {
    if (state.commentsByPost.containsKey(e.postId)) return;

    try {
      final comments = await _repo.fetchComments(e.postId);
      final newMap = Map<String, List<CommentModel>>.from(state.commentsByPost)
        ..[e.postId] = comments;
      emit(state.copyWith(commentsByPost: newMap));
    } catch (err) {
      print('fetchComments error: $err');
    }
  }

  Future<void> _onCommentRepliesToggled(
    CommentRepliesToggled e,
    Emitter<PostState> emit,
  ) async {
    final isExpanded = state.expandedCommentIds.contains(e.commentId);

    // 1) Wenn schon offen → einfach schließen (ID entfernen)
    if (isExpanded) {
      final newSet = Set<String>.from(state.expandedCommentIds)
        ..remove(e.commentId);
      emit(state.copyWith(expandedCommentIds: newSet));
      return;
    }

    // 2) sonst: öffnen → sicherstellen, dass Thread geladen ist
    final comments = state.commentsByPost[e.postId];
    if (comments == null) return;

    final idx = comments.indexWhere((c) => c.id == e.commentId);
    if (idx == -1) return;

    CommentModel parent = comments[idx];

    // Wenn noch keine Replies geladen wurden, komplette Threadstruktur holen
    if (parent.replies == null && parent.repliesCount > 0) {
      parent = await _loadThread(parent);

      final updatedComments = [...comments]..[idx] = parent;
      final newMap = Map<String, List<CommentModel>>.from(state.commentsByPost)
        ..[e.postId] = updatedComments;

      final newSet = Set<String>.from(state.expandedCommentIds)
        ..add(e.commentId);

      emit(state.copyWith(commentsByPost: newMap, expandedCommentIds: newSet));
    } else {
      // Replies waren schon geladen → nur expand markieren
      final newSet = Set<String>.from(state.expandedCommentIds)
        ..add(e.commentId);
      emit(state.copyWith(expandedCommentIds: newSet));
    }
  }

  Future<CommentModel> _loadThread(CommentModel parent) async {
    // Wenn keine Nachkommen → nichts zu tun
    if (parent.repliesCount == 0) return parent;

    // direkte Kinder laden
    final directReplies = await _repo.fetchReplies(parent.id);

    final List<CommentModel> repliesWithChildren = [];

    for (final reply in directReplies) {
      if (reply.repliesCount > 0) {
        // rekursiv: Kinder dieses Replies laden
        final withChildren = await _loadThread(reply);
        repliesWithChildren.add(withChildren);
      } else {
        repliesWithChildren.add(reply);
      }
    }

    return parent.copyWith(replies: repliesWithChildren);
  }

  Future<void> _onCommentLikeToggled(
    CommentLikeToggled e,
    Emitter<PostState> emit,
  ) async {
    final comments = state.commentsByPost[e.postId];
    if (comments == null) return;

    final comment = _findComment(comments, e.commentId);
    if (comment == null) return;

    // 💡 genau wie bei Post: optimistic copy
    final optimistic = comment.youLiked
        ? comment.copyWith(youLiked: false, likesCount: comment.likesCount - 1)
        : comment.copyWith(youLiked: true, likesCount: comment.likesCount + 1);

    final updatedList = _replaceComment(comments, e.commentId, optimistic);

    final optimisticMap = Map<String, List<CommentModel>>.from(
      state.commentsByPost,
    )..[e.postId] = updatedList;

    emit(state.copyWith(commentsByPost: optimisticMap));

    try {
      if (comment.youLiked) {
        await _repo.unlikeComment(comment.id);
      } else {
        await _repo.likeComment(comment.id);
      }
    } catch (err) {
      // rollback wie bei Post
      final revertedList = _replaceComment(updatedList, e.commentId, comment);
      print(err);
      final revertedMap = Map<String, List<CommentModel>>.from(
        state.commentsByPost,
      )..[e.postId] = revertedList;

      emit(state.copyWith(commentsByPost: revertedMap));
    }
  }

  void _onCommentSubmitted(CommentSubmitted e, Emitter<PostState> emit) async {
    final text = e.content.trim();
    if (text.isEmpty) return;

    final existing = state.commentsByPost[e.postId] ?? [];

    try {
      final newComment = await _repo.createComment(
        postId: e.postId,
        content: text,
        parentId: e.parentId,
      );

      List<CommentModel> updatedComments;

      if (e.parentId == null) {
        updatedComments = [...existing, newComment];
      } else {
        updatedComments = _updateCommentInList(existing, e.parentId!, (parent) {
          final currentReplies = parent.replies ?? [];
          final newReplies = [...currentReplies, newComment];
          return parent.copyWith(
            replies: newReplies,
            repliesCount: parent.repliesCount + 1,
          );
        });
      }

      final newMap = Map<String, List<CommentModel>>.from(state.commentsByPost)
        ..[e.postId] = updatedComments;

      final feed = state.feed;
      final idx = feed.indexWhere((p) => p.id == e.postId);
      List<PostModel> newFeed = feed;

      if (idx != -1) {
        final post = feed[idx];
        final updatedPost = post.copyWith(
          commentsCount: post.commentsCount + 1,
        );
        newFeed = [...feed]..[idx] = updatedPost;
      }

      final newExpanded = Set<String>.from(state.expandedCommentIds);
      if (e.parentId != null) {
        newExpanded.add(e.parentId!);
      }

      emit(
        state.copyWith(
          commentsByPost: newMap,
          expandedCommentIds: newExpanded,
          feed: newFeed,
        ),
      );
    } catch (err) {
      print('CommentSubmitted error: $err');
    }
  }

  Future<void> _onCommentEditSubmitted(
    CommentEditSubmitted e,
    Emitter<PostState> emit,
  ) async {
    final comments = state.commentsByPost[e.postId];
    if (comments == null) return;

    CommentModel? original;

    final updatedList = _updateCommentInList(comments, e.commentId, (c) {
      original = c;
      return c.copyWith(content: e.newContent);
    });

    if (original == null) return;

    // Optimistisch UI updaten
    emit(
      state.copyWith(
        commentsByPost: {...state.commentsByPost, e.postId: updatedList},
      ),
    );

    try {
      await _repo.updateComment(commentId: e.commentId, content: e.newContent);
    } catch (err) {
      // Rollback bei Fehler
      final revertedList = _updateCommentInList(
        updatedList,
        e.commentId,
        (_) => original!,
      );

      emit(
        state.copyWith(
          commentsByPost: {...state.commentsByPost, e.postId: revertedList},
        ),
      );
    }
  }

  Future<void> _onCommentDeleteRequested(
    CommentDeleteRequested e,
    Emitter<PostState> emit,
  ) async {
    final comments = state.commentsByPost[e.postId];
    if (comments == null) return;

    final result = _removeCommentFromTree(comments, e.commentId);
    if (result.removedCount == 0) return;

    // Post-Kommentar-Anzahl anpassen
    final feed = state.feed;
    final idx = feed.indexWhere((p) => p.id == e.postId);
    List<PostModel> newFeed = feed;
    if (idx != -1) {
      final post = feed[idx];
      final updatedPost = post.copyWith(
        commentsCount: post.commentsCount - result.removedCount,
      );
      newFeed = [...feed]..[idx] = updatedPost;
    }

    // Optimistisch UI updaten
    emit(
      state.copyWith(
        commentsByPost: {...state.commentsByPost, e.postId: result.comments},
        feed: newFeed,
      ),
    );

    try {
      await _repo.deleteComment(e.commentId);
      // DB-Trigger sorgt dafür, dass posts.comments_count in der DB konsistent ist
    } catch (err) {
      // Fallback: bei Fehler vollständigen Refresh anstoßen
      add(PostCommentsRequested(e.postId));
    }
  }
}

CommentModel? _findComment(List<CommentModel> list, String id) {
  for (final c in list) {
    if (c.id == id) return c;
    if (c.replies != null) {
      final found = _findComment(c.replies!, id);
      if (found != null) return found;
    }
  }
  return null;
}

List<CommentModel> _replaceComment(
  List<CommentModel> list,
  String id,
  CommentModel newComment,
) {
  return list.map((c) {
    if (c.id == id) return newComment;
    if (c.replies != null) {
      final updatedReplies = _replaceComment(c.replies!, id, newComment);
      return c.copyWith(replies: updatedReplies);
    }
    return c;
  }).toList();
}

List<CommentModel> _updateCommentInList(
  List<CommentModel> list,
  String id,
  CommentModel Function(CommentModel) updater,
) {
  return list.map((c) {
    if (c.id == id) return updater(c);
    if (c.replies != null) {
      final updatedReplies = _updateCommentInList(c.replies!, id, updater);
      return c.copyWith(replies: updatedReplies);
    }
    return c;
  }).toList();
}

class _DeleteResult {
  final List<CommentModel> comments;
  final int removedCount;
  _DeleteResult(this.comments, this.removedCount);
}

int _countDescendants(CommentModel c) {
  if (c.replies == null || c.replies!.isEmpty) return 0;
  var total = c.replies!.length;
  for (final r in c.replies!) {
    total += _countDescendants(r);
  }
  return total;
}

_DeleteResult _removeCommentFromTree(List<CommentModel> list, String id) {
  int removed = 0;
  final out = <CommentModel>[];

  for (final c in list) {
    if (c.id == id) {
      removed += 1 + _countDescendants(c);
      continue; // diesen Knoten + Subtree komplett entfernen
    }

    if (c.replies != null && c.replies!.isNotEmpty) {
      final childResult = _removeCommentFromTree(c.replies!, id);
      if (childResult.removedCount > 0) {
        removed += childResult.removedCount;
        out.add(
          c.copyWith(
            replies: childResult.comments,
            repliesCount: c.repliesCount - childResult.removedCount,
          ),
        );
      } else {
        out.add(c);
      }
    } else {
      out.add(c);
    }
  }

  return _DeleteResult(out, removed);
}
