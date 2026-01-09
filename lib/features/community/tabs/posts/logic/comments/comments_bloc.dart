import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumora/features/community/tabs/posts/data/comment_model.dart';
import 'package:lumora/features/community/tabs/posts/data/post_repository.dart';
import 'package:lumora/features/community/tabs/posts/logic/comments/comments_event.dart';
import 'package:lumora/features/community/tabs/posts/logic/comments/comments_state.dart';
import 'package:lumora/features/community/tabs/posts/logic/post/post_bloc.dart';
import 'package:lumora/features/community/tabs/posts/logic/post/post_event.dart';

class CommentsBloc extends Bloc<CommentsEvent, CommentsState> {
  final PostRepository _repo;
  final PostBloc _postBloc; // um commentsCount im Feed zu patchen

  CommentsBloc({required PostRepository repo, required PostBloc postBloc})
    : _repo = repo,
      _postBloc = postBloc,
      super(const CommentsState()) {
    on<CommentsRequested>(_onCommentsRequested);
    on<CommentRepliesToggled>(_onRepliesToggled);
    on<CommentLikeToggled>(_onCommentLikeToggled);
    on<CommentSubmitted>(_onCommentSubmitted);
    on<CommentEditSubmitted>(_onCommentEditSubmitted);
    on<CommentDeleteRequested>(_onCommentDeleteRequested);
    on<ReplyTargetSet>(_onReplyTargetSet);
    on<ReplyTargetCleared>(_onReplyTargetCleared);
  }

  Future<void> _onCommentsRequested(
    CommentsRequested e,
    Emitter<CommentsState> emit,
  ) async {
    if (!e.force && state.commentsByPost.containsKey(e.postId)) return;

    try {
      final comments = await _repo.fetchComments(e.postId);
      emit(
        state.copyWith(
          commentsByPost: {...state.commentsByPost, e.postId: comments},
          error: null,
        ),
      );
    } catch (err) {
      emit(state.copyWith(error: err.toString()));
    }
  }

  void _onReplyTargetSet(ReplyTargetSet e, Emitter<CommentsState> emit) {
    final map = {...state.replyTargetByPost};
    map[e.postId] = e.target;
    emit(state.copyWith(replyTargetByPost: map));
  }

  void _onReplyTargetCleared(
    ReplyTargetCleared e,
    Emitter<CommentsState> emit,
  ) {
    final map = {...state.replyTargetByPost};
    map[e.postId] = null;
    emit(state.copyWith(replyTargetByPost: map));
  }

  Future<void> _onRepliesToggled(
    CommentRepliesToggled e,
    Emitter<CommentsState> emit,
  ) async {
    final isExpanded = state.expandedCommentIds.contains(e.commentId);

    if (isExpanded) {
      final newSet = Set<String>.from(state.expandedCommentIds)
        ..remove(e.commentId);
      emit(state.copyWith(expandedCommentIds: newSet));
      return;
    }

    final comments = state.commentsByPost[e.postId];
    if (comments == null) return;

    final idx = comments.indexWhere((c) => c.id == e.commentId);
    if (idx == -1) return;

    CommentModel parent = comments[idx];

    if (parent.replies == null && parent.repliesCount > 0) {
      parent = await _loadThread(parent);

      final updated = [...comments]..[idx] = parent;
      final newMap = {...state.commentsByPost, e.postId: updated};
      final newSet = Set<String>.from(state.expandedCommentIds)
        ..add(e.commentId);

      emit(state.copyWith(commentsByPost: newMap, expandedCommentIds: newSet));
    } else {
      final newSet = Set<String>.from(state.expandedCommentIds)
        ..add(e.commentId);
      emit(state.copyWith(expandedCommentIds: newSet));
    }
  }

  Future<CommentModel> _loadThread(CommentModel parent) async {
    if (parent.repliesCount == 0) return parent;

    final directReplies = await _repo.fetchReplies(parent.id);
    final repliesWithChildren = <CommentModel>[];

    for (final reply in directReplies) {
      if (reply.repliesCount > 0) {
        repliesWithChildren.add(await _loadThread(reply));
      } else {
        repliesWithChildren.add(reply);
      }
    }

    return parent.copyWith(replies: repliesWithChildren);
  }

  Future<void> _onCommentLikeToggled(
    CommentLikeToggled e,
    Emitter<CommentsState> emit,
  ) async {
    final comments = state.commentsByPost[e.postId];
    if (comments == null) return;

    final comment = _findComment(comments, e.commentId);
    if (comment == null) return;

    final optimistic = comment.youLiked
        ? comment.copyWith(youLiked: false, likesCount: comment.likesCount - 1)
        : comment.copyWith(youLiked: true, likesCount: comment.likesCount + 1);

    final updatedList = _replaceComment(comments, e.commentId, optimistic);
    emit(
      state.copyWith(
        commentsByPost: {...state.commentsByPost, e.postId: updatedList},
      ),
    );

    try {
      if (comment.youLiked) {
        await _repo.unlikeComment(comment.id);
      } else {
        await _repo.likeComment(comment.id);
      }
    } catch (_) {
      final reverted = _replaceComment(updatedList, e.commentId, comment);
      emit(
        state.copyWith(
          commentsByPost: {...state.commentsByPost, e.postId: reverted},
        ),
      );
    }
  }

  Future<void> _onCommentSubmitted(
    CommentSubmitted e,
    Emitter<CommentsState> emit,
  ) async {
    final text = e.content.trim();
    if (text.isEmpty) return;

    final existing = state.commentsByPost[e.postId] ?? [];
    final target = state.replyTargetByPost[e.postId];
    final parentId = target?.id;

    try {
      final newComment = await _repo.createComment(
        postId: e.postId,
        content: text,
        parentId: parentId,
      );

      List<CommentModel> updatedComments;

      if (parentId == null) {
        updatedComments = [...existing, newComment];
      } else {
        updatedComments = _updateCommentInList(existing, parentId, (parent) {
          final currentReplies = parent.replies ?? [];
          final newReplies = [...currentReplies, newComment];
          return parent.copyWith(
            replies: newReplies,
            repliesCount: parent.repliesCount + 1,
          );
        });
      }

      final newExpanded = Set<String>.from(state.expandedCommentIds);
      if (parentId != null) newExpanded.add(parentId);

      // ✅ update comments list + expand + clear reply target
      final newReplyTargets = {...state.replyTargetByPost};
      newReplyTargets[e.postId] = null;

      emit(
        state.copyWith(
          commentsByPost: {...state.commentsByPost, e.postId: updatedComments},
          expandedCommentIds: newExpanded,
          replyTargetByPost: newReplyTargets,
        ),
      );

      // ✅ Patch commentsCount im Feed sofort
      _postBloc.add(PostCommentsCountPatched(postId: e.postId, delta: 1));
    } catch (err) {
      emit(state.copyWith(error: err.toString()));
    }
  }

  Future<void> _onCommentEditSubmitted(
    CommentEditSubmitted e,
    Emitter<CommentsState> emit,
  ) async {
    final comments = state.commentsByPost[e.postId];
    if (comments == null) return;

    CommentModel? original;

    final updatedList = _updateCommentInList(comments, e.commentId, (c) {
      original = c;
      return c.copyWith(content: e.newContent);
    });

    if (original == null) return;

    emit(
      state.copyWith(
        commentsByPost: {...state.commentsByPost, e.postId: updatedList},
      ),
    );

    try {
      await _repo.updateComment(commentId: e.commentId, content: e.newContent);
    } catch (_) {
      final reverted = _updateCommentInList(
        updatedList,
        e.commentId,
        (_) => original!,
      );
      emit(
        state.copyWith(
          commentsByPost: {...state.commentsByPost, e.postId: reverted},
        ),
      );
    }
  }

  Future<void> _onCommentDeleteRequested(
    CommentDeleteRequested e,
    Emitter<CommentsState> emit,
  ) async {
    final comments = state.commentsByPost[e.postId];
    if (comments == null) return;

    final result = _removeCommentFromTree(comments, e.commentId);
    if (result.removedCount == 0) return;

    emit(
      state.copyWith(
        commentsByPost: {...state.commentsByPost, e.postId: result.comments},
      ),
    );

    // ✅ feed-count sofort patchen
    _postBloc.add(
      PostCommentsCountPatched(postId: e.postId, delta: -result.removedCount),
    );

    try {
      await _repo.deleteComment(e.commentId);
    } catch (_) {
      add(CommentsRequested(postId: e.postId, force: true));
    }
  }
}

/* ---------- helpers (identisch wie bei dir, nur hier hin verschoben) ---------- */

CommentModel? _findComment(List<CommentModel> list, String id) {
  for (final c in list) {
    if (c.id == id) return c;
    final replies = c.replies;
    if (replies != null) {
      final found = _findComment(replies, id);
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
    final replies = c.replies;
    if (replies != null) {
      return c.copyWith(replies: _replaceComment(replies, id, newComment));
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
    final replies = c.replies;
    if (replies != null) {
      return c.copyWith(replies: _updateCommentInList(replies, id, updater));
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
  final replies = c.replies;
  if (replies == null || replies.isEmpty) return 0;
  var total = replies.length;
  for (final r in replies) {
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
      continue;
    }

    final replies = c.replies;
    if (replies != null && replies.isNotEmpty) {
      final child = _removeCommentFromTree(replies, id);
      if (child.removedCount > 0) {
        removed += child.removedCount;
        out.add(
          c.copyWith(
            replies: child.comments,
            repliesCount: c.repliesCount - child.removedCount,
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
