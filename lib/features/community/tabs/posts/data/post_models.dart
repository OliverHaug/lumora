import 'package:equatable/equatable.dart';
import 'package:xyz/features/community/tabs/posts/data/comment_model.dart';
import 'package:xyz/features/profile/data/user_model.dart';

class PostModel extends Equatable {
  final String id;
  final UserModel author;
  final String? content;
  final DateTime createdAt;
  final String? imageUrl;
  final int likesCount;
  final int commentsCount;
  final bool youLiked;
  final List<CommentModel>? comments;

  const PostModel({
    required this.id,
    required this.author,
    this.content,
    required this.createdAt,
    this.imageUrl,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.youLiked = false,
    this.comments,
  });

  factory PostModel.fromMap(Map<String, dynamic> map, {String? currentUserId}) {
    final likes = (map['post_likes'] as List? ?? []);
    final comments = (map['comments'] as List? ?? []);

    return PostModel(
      id: map['id'] as String,
      author: UserModel.fromMap(map['author'] ?? map['profiles'] ?? {}),
      content: map['content'] as String?,
      imageUrl: map['image_url'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      likesCount: likes.length,
      commentsCount: map['comments_count'],
      youLiked:
          currentUserId != null &&
          likes.any((l) => l['user_id'] == currentUserId),
    );
  }

  Map<String, dynamic> toMap() {
    return {'author_id': author.id, 'content': content, 'image_url': imageUrl};
  }

  PostModel copyWith({int? likesCount, bool? youLiked, int? commentsCount}) {
    return PostModel(
      id: id,
      author: author,
      content: content,
      imageUrl: imageUrl,
      createdAt: createdAt,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      youLiked: youLiked ?? this.youLiked,
      comments: comments,
    );
  }

  @override
  List<Object?> get props => [
    id,
    author,
    content,
    createdAt,
    imageUrl,
    commentsCount,
    youLiked,
    comments,
  ];
}
