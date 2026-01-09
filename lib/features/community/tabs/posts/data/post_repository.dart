import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lumora/features/community/tabs/posts/data/comment_model.dart';
import 'package:lumora/features/community/tabs/posts/data/post_models.dart';

class PostRepository {
  final SupabaseClient _client;
  PostRepository(this._client);

  Future<Map<String, String>> uploadPostImage(XFile file) async {
    final uid = _client.auth.currentUser!.id;

    final bytes = await file.readAsBytes();
    final ext = file.path.split('.').last;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
    final path = '$uid/$fileName';

    await _client.storage
        .from('post-images')
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );

    final publicUrl = _client.storage.from('post-images').getPublicUrl(path);
    return {'url': publicUrl, 'path': path};
  }

  Future<List<PostModel>> fetchFeed({int limit = 20}) async {
    final uid = _client.auth.currentUser?.id;

    final data = await _client
        .from('posts')
        .select('''
          id, content, image_url, image_path, created_at,
          likes_count, comments_count,
          author:author_id (id, name, avatar_url, role),
          post_likes (user_id)
        ''')
        .order('created_at', ascending: false)
        .limit(limit);

    return (data as List)
        .map(
          (p) =>
              PostModel.fromMap(p as Map<String, dynamic>, currentUserId: uid),
        )
        .toList();
  }

  Future<List<PostModel>> fetchPostsByUser({
    required String userId,
    int limit = 25,
  }) async {
    final res = await _client
        .from('posts')
        .select('''
          id, content, image_url, image_path, created_at,
          likes_count, comments_count,
          author:author_id (id, name, role, avatar_url),
          post_likes (user_id)
      ''')
        .eq('author_id', userId)
        .order('created_at', ascending: false)
        .limit(limit);

    final list = (res as List).cast<Map<String, dynamic>>();
    return list.map(PostModel.fromMap).toList();
  }

  Future<List<CommentModel>> fetchComments(String postId) async {
    final uid = _client.auth.currentUser?.id;
    final data = await _client
        .from('comments_with_reply_count')
        .select('''
          id, post_id, parent_id, content, created_at,
          replies_count,
          author:author_id (id, name, avatar_url, role),
          comment_likes (user_id)
        ''')
        .eq('post_id', postId)
        .isFilter('parent_id', null)
        .order('created_at', ascending: true);

    return (data as List)
        .map(
          (c) => CommentModel.fromMap(
            c as Map<String, dynamic>,
            currentUserId: uid ?? '',
          ),
        )
        .toList();
  }

  Future<List<CommentModel>> fetchReplies(String parentId) async {
    final uid = _client.auth.currentUser?.id;

    final data = await _client
        .from('comments_with_reply_count')
        .select('''
          id, post_id, parent_id, content, created_at,
          replies_count,
          author:author_id (id, name, avatar_url, role),
          comment_likes (user_id)
        ''')
        .eq('parent_id', parentId)
        .order('created_at', ascending: true);

    return (data as List)
        .map(
          (c) => CommentModel.fromMap(
            c as Map<String, dynamic>,
            currentUserId: uid ?? '',
          ),
        )
        .toList();
  }

  Future<void> likePost(String postId) async {
    final uid = _client.auth.currentUser!.id;
    await _client.from('post_likes').insert({
      'post_id': postId,
      'user_id': uid,
    });
  }

  Future<void> unlikePost(String postId) async {
    final uid = _client.auth.currentUser!.id;
    await _client.from('post_likes').delete().match({
      'post_id': postId,
      'user_id': uid,
    });
  }

  Future<void> likeComment(String commentId) async {
    final uid = _client.auth.currentUser!.id;
    await _client.from('comment_likes').insert({
      'comment_id': commentId,
      'user_id': uid,
    });
  }

  Future<void> unlikeComment(String commentId) async {
    final uid = _client.auth.currentUser!.id;
    await _client.from('comment_likes').delete().match({
      'comment_id': commentId,
      'user_id': uid,
    });
  }

  Future<String> createPost({
    required String content,
    String? imageUrl,
    String? imagePath,
  }) async {
    final uid = _client.auth.currentUser!.id;

    final inserted = await _client
        .from('posts')
        .insert({
          'author_id': uid,
          'content': content,
          'image_url': imageUrl,
          'image_path': imagePath,
        })
        .select('id')
        .single();

    return inserted['id'] as String;
  }

  Future<void> updatePost({
    required String postId,
    required String content,
    String? imageUrl,
    String? imagePath,
    bool removeImage = false,
  }) async {
    // alten pfad holen
    final old = await _client
        .from('posts')
        .select('image_path')
        .eq('id', postId)
        .single();

    final oldPath = old['image_path'] as String?;

    // wenn remove oder ersetzen -> alten löschen
    final shouldDeleteOld = removeImage || (imagePath != null);
    if (shouldDeleteOld) {
      if (oldPath != null && oldPath.isNotEmpty) {
        await _client.storage.from('post-images').remove([oldPath]);
      }
    }

    final update = <String, dynamic>{'content': content};

    if (removeImage) {
      update['image_url'] = null;
      update['image_path'] = null;
    } else {
      if (imageUrl != null) update['image_url'] = imageUrl;
      if (imagePath != null) update['image_path'] = imagePath;
    }

    await _client.from('posts').update(update).eq('id', postId);
  }

  Future<void> deletePost(String postId) async {
    final row = await _client
        .from('posts')
        .select('image_path')
        .eq('id', postId)
        .maybeSingle();

    final path = row?['image_path'] as String?;
    if (path != null && path.isNotEmpty) {
      await _client.storage.from('post-images').remove([path]);
    }

    await _client.from('posts').delete().eq('id', postId);
  }

  Future<CommentModel> createComment({
    required String postId,
    required String content,
    String? parentId,
  }) async {
    final uid = _client.auth.currentUser!.id;

    final inserted = await _client
        .from('comments')
        .insert({
          'post_id': postId,
          'parent_id': parentId,
          'content': content,
          'author_id': uid,
        })
        .select('id')
        .single();

    final newId = inserted['id'] as String;

    final data = await _client
        .from('comments_with_reply_count')
        .select('''
        id, post_id, parent_id, content, created_at,
        replies_count,
        author:author_id (id, name, avatar_url, role),
        comment_likes (user_id)
      ''')
        .eq('id', newId)
        .single();

    return CommentModel.fromMap(data, currentUserId: uid);
  }

  Future<void> updateComment({
    required String commentId,
    required String content,
  }) async {
    await _client
        .from('comments')
        .update({'content': content})
        .eq('id', commentId);
  }

  Future<void> deleteComment(String commentId) async {
    await _client.from('comments').delete().eq('id', commentId);
  }
}
