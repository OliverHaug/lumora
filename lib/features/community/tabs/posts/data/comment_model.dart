import 'package:equatable/equatable.dart';
import 'package:xyz/features/profile/data/user_model.dart';

class CommentModel extends Equatable {
  final String id;
  final String postId;
  final String? parentId;
  final UserModel author;
  final String content;
  final DateTime createdAt;
  final int likesCount;
  final bool youLiked;
  final int repliesCount;
  final List<CommentModel>? replies;

  const CommentModel({
    required this.id,
    required this.postId,
    this.parentId,
    required this.author,
    required this.content,
    required this.createdAt,
    this.likesCount = 0,
    this.youLiked = false,
    this.repliesCount = 0,
    this.replies,
  });

  CommentModel copyWith({
    int? likesCount,
    bool? youLiked,
    List<CommentModel>? replies,
    int? repliesCount,
    String? content,
  }) {
    return CommentModel(
      id: id,
      postId: postId,
      parentId: parentId,
      author: author,
      content: content ?? this.content,
      createdAt: createdAt,
      likesCount: likesCount ?? this.likesCount,
      youLiked: youLiked ?? this.youLiked,
      repliesCount: repliesCount ?? this.repliesCount,
      replies: replies ?? this.replies,
    );
  }

  factory CommentModel.fromMap(
    Map<String, dynamic> map, {
    String? currentUserId,
  }) {
    final likesRel = (map['comment_likes'] as List?) ?? const [];

    return CommentModel(
      id: map['id'] as String,
      postId: map['post_id'] as String,
      parentId: map['parent_id'] as String?,
      author: UserModel.fromMap(map['author'] ?? const {}),
      content: map['content'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      likesCount: likesRel.length,
      repliesCount: (map['replies_count'] as int?) ?? 0,
      youLiked:
          (map['comment_likes'] as List?)?.any(
            (l) => l['user_id'] == currentUserId,
          ) ??
          false,
    );
  }

  @override
  List<Object?> get props => [
    id,
    postId,
    parentId,
    author,
    content,
    createdAt,
    likesCount,
    youLiked,
    repliesCount,
    replies,
  ];
}
