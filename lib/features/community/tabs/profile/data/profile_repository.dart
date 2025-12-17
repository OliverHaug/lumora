import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:xyz/features/community/tabs/profile/data/healing_answer_model.dart';
import 'package:xyz/features/community/tabs/profile/data/healing_qa_model.dart';
import 'package:xyz/features/community/tabs/profile/data/healing_question_model.dart';
import 'package:xyz/features/settings/data/user_model.dart';

class ProfileRepository {
  final SupabaseClient _client;

  ProfileRepository(this._client);

  String? get currentUserId => _client.auth.currentUser?.id;

  Future<UserModel> fetchUser(String userId) async {
    final res = await _client
        .from('profiles')
        .select('id, name, avatar_url, bio, role, created_at')
        .eq('id', userId)
        .single();

    return UserModel.fromMap(res);
  }

  Future<void> updateBio({required String bio}) async {
    if (currentUserId == null) throw Exception('Not authenticated');
    await _client
        .from('profiles')
        .update({'bio': bio})
        .eq('id', currentUserId!);
  }

  Future<void> updateAvatarUrl({required String avatarUrl}) async {
    if (currentUserId == null) throw Exception('Not authenticated');
    await _client
        .from('profiles')
        .update({'avatar_url': avatarUrl})
        .eq('id', currentUserId!);
  }

  Future<List<String>> fetchGalleryUrls(String userId) async {
    final res = await _client
        .from('profile_photos')
        .select('image_url, order_index')
        .eq('user_id', userId)
        .order('order_index', ascending: true);

    final list = (res as List).cast<Map<String, dynamic>>();
    return list.map((e) => e['image_url'] as String).toList();
  }

  Future<void> addGalleryPhoto({required String imageUrl}) async {
    if (currentUserId == null) throw Exception('Not authenticated');

    final maxRes = await _client
        .from('profile_photos')
        .select('order_index')
        .eq('user_id', currentUserId!)
        .order('order_index', ascending: false)
        .limit(1);

    int next = 0;
    if ((maxRes as List).isNotEmpty) {
      next = ((maxRes.first)['order_index'] as int) + 1;
    }

    await _client.from('profile_photos').insert({
      'user_id': currentUserId,
      'image_url': imageUrl,
      'order_index': next,
    });
  }

  Future<void> deleteGalleryPhoto({required String imageUrl}) async {
    if (currentUserId == null) throw Exception('Not authenticated');

    await _client
        .from('profile_photos')
        .delete()
        .eq('user_id', currentUserId!)
        .eq('image_url', imageUrl);
  }

  // ---------- Healing ----------
  Future<List<HealingQuestionModel>> fetchHealingQuestionsForRole(
    String role,
  ) async {
    // role filter: (role is null) OR (role == user's role)
    final res = await _client
        .from('healing_questions')
        .select('id, key, question, role, order_index, is_active')
        .eq('is_active', true)
        .order('order_index', ascending: true);

    final list = (res as List)
        .cast<Map<String, dynamic>>()
        .map(HealingQuestionModel.fromMap)
        .where((q) => q.role == null || q.role == role)
        .toList();

    return list;
  }

  Future<List<HealingAnswerModel>> fetchHealingAnswers(String userId) async {
    final res = await _client
        .from('healing_answers')
        .select('question_id, answer')
        .eq('user_id', userId);

    final list = (res as List).cast<Map<String, dynamic>>();
    return list.map(HealingAnswerModel.fromMap).toList();
  }

  Future<List<HealingQAModel>> fetchHealingQA({
    required String userId,
    required String role,
  }) async {
    final questions = await fetchHealingQuestionsForRole(role);
    final answers = await fetchHealingAnswers(userId);
    final byQ = {for (final a in answers) a.questionId: a.answer};

    return questions
        .map((q) => HealingQAModel(question: q, answer: byQ[q.id] ?? ''))
        .toList();
  }

  Future<void> upsertHealingAnswers(List<HealingQAModel> qa) async {
    if (currentUserId == null) throw Exception('Not authenticated');

    final payload = qa.map((x) {
      return {
        'user_id': currentUserId,
        'question_id': x.question.id,
        'answer': x.answer,
        'updated_at': DateTime.now().toIso8601String(),
      };
    }).toList();

    await _client
        .from('healing_answers')
        .upsert(payload, onConflict: 'user_id,question_id');
  }

  // ---------- Storage Uploads ----------
  Future<String> uploadAvatar(XFile file) async {
    if (currentUserId == null) throw Exception('Not authenticated');

    final bytes = await file.readAsBytes();
    final path = '$currentUserId/${DateTime.now().millisecondsSinceEpoch}.jpg';

    await _client.storage
        .from('avatars')
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(
            upsert: true,
            contentType: 'image/jpeg',
          ),
        );

    // robust: signed URL
    final signed = await _client.storage
        .from('avatars')
        .createSignedUrl(path, 60 * 60 * 24 * 30);
    return signed;
  }

  Future<String> uploadGalleryImage(XFile file) async {
    if (currentUserId == null) throw Exception('Not authenticated');

    final bytes = await file.readAsBytes();
    final path = '$currentUserId/${DateTime.now().millisecondsSinceEpoch}.jpg';

    await _client.storage
        .from('profile-gallery')
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(
            upsert: true,
            contentType: 'image/jpeg',
          ),
        );

    final signed = await _client.storage
        .from('profile-gallery')
        .createSignedUrl(path, 60 * 60 * 24 * 30);
    return signed;
  }
}
