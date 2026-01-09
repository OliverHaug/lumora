import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumora/features/community/tabs/posts/data/post_repository.dart';
import 'package:lumora/features/community/tabs/profile/data/profile_repository.dart';
import 'package:lumora/features/community/tabs/profile/logic/profile_event.dart';
import 'package:lumora/features/community/tabs/profile/logic/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _repo;
  final PostRepository _postsRepo;

  ProfileBloc(this._repo, this._postsRepo) : super(const ProfileState()) {
    on<ProfileRefreshed>(_onRefreshed);
    on<ProfileUserChanged>(_onUserChanged);
  }

  Future<void> _onUserChanged(
    ProfileUserChanged e,
    Emitter<ProfileState> emit,
  ) async {
    await _load(userId: e.userId, emit: emit);
  }

  Future<void> _onRefreshed(
    ProfileRefreshed e,
    Emitter<ProfileState> emit,
  ) async {
    await _load(userId: e.userId, emit: emit, force: true);
  }

  Future<void> _load({
    required String? userId,
    required Emitter<ProfileState> emit,
    bool force = false,
  }) async {
    final myId = _repo.currentUserId;
    final actualUserId = userId ?? myId;

    if (actualUserId == null) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          error: 'Not authenticated',
        ),
      );
      return;
    }

    final isMe = actualUserId == myId;

    emit(
      state.copyWith(
        status: ProfileStatus.loading,
        viewingUserId: actualUserId,
        isMe: isMe,
        error: null,
      ),
    );

    try {
      final user = await _repo.fetchUser(actualUserId);
      final posts = await _postsRepo.fetchPostsByUser(
        userId: actualUserId,
        limit: 25,
      );
      final gallery = await _repo.fetchGalleryUrls(actualUserId);
      final healing = await _repo.fetchHealingQA(
        userId: actualUserId,
        role: user.role,
      );

      emit(
        state.copyWith(
          status: ProfileStatus.success,
          user: user,
          posts: posts,
          galleryUrls: gallery,
          healing: healing,
        ),
      );
    } catch (err) {
      emit(
        state.copyWith(status: ProfileStatus.failure, error: err.toString()),
      );
    }
  }
}
