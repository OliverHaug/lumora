import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumora/features/community/tabs/following/data/circle_repository.dart';
import 'package:lumora/features/community/tabs/following/data/circle_user_model.dart';
import 'circle_event.dart';
import 'circle_state.dart';

class CircleBloc extends Bloc<CircleEvent, CircleState> {
  final CircleRepository _repo;

  CircleBloc(this._repo) : super(const CircleState()) {
    on<CircleStarted>(_onStarted);
    on<CircleTabChanged>(_onTabChanged);
    on<CircleSearchChanged>(_onSearchChanged);
    on<CircleRefreshRequested>(_onRefresh);
    on<FollowToggled>(_onFollowToggled);
  }

  Future<void> _onStarted(CircleStarted e, Emitter<CircleState> emit) async {
    emit(state.copyWith(status: CircleStatus.loading, error: null));
    try {
      final followingRaw = await _repo.fetchFollowing(limit: 50);
      final following = followingRaw
          .map((m) => CircleUserModel.fromMap(m).copyWith(isFollowed: true))
          .toList();

      final suggestedRaw = await _repo.fetchDiscover(query: '', limit: 50);
      final suggestedAll = suggestedRaw.map(CircleUserModel.fromMap).toList();

      final followingIds = following.map((e) => e.user.id).toSet();
      final suggested = suggestedAll
          .where((u) => !followingIds.contains(u.user.id))
          .toList();

      emit(
        state.copyWith(
          status: CircleStatus.success,
          following: following,
          suggested: suggested,
          discover: const [],
        ),
      );
    } catch (err) {
      emit(state.copyWith(status: CircleStatus.failure, error: err.toString()));
    }
  }

  Future<void> _onTabChanged(
    CircleTabChanged e,
    Emitter<CircleState> emit,
  ) async {
    emit(state.copyWith(mode: e.mode));
    if (e.mode == CircleTabMode.discover) {
      add(const CircleRefreshRequested());
    }
  }

  Future<void> _onSearchChanged(
    CircleSearchChanged e,
    Emitter<CircleState> emit,
  ) async {
    emit(state.copyWith(query: e.query));

    if (state.mode == CircleTabMode.discover) {
      add(const CircleRefreshRequested());
    }
  }

  Future<void> _onRefresh(
    CircleRefreshRequested e,
    Emitter<CircleState> emit,
  ) async {
    emit(state.copyWith(status: CircleStatus.loading, error: null));

    try {
      final followingRaw = await _repo.fetchFollowing(limit: 50);
      final following = followingRaw
          .map((m) => CircleUserModel.fromMap(m).copyWith(isFollowed: true))
          .toList();

      final followingIds = following.map((x) => x.user.id).toSet();

      final suggestedRaw = await _repo.fetchDiscover(query: '', limit: 50);
      final suggestedAll = suggestedRaw.map(CircleUserModel.fromMap).toList();

      final suggested = suggestedAll
          .where((u) => !followingIds.contains(u.user.id))
          .toList();

      final q = state.query.trim();
      List<CircleUserModel> discover = const [];

      if (q.isNotEmpty) {
        final discoverRaw = await _repo.fetchDiscover(query: q, limit: 50);
        discover = discoverRaw.map(CircleUserModel.fromMap).toList();

        discover = discover
            .where((u) => !followingIds.contains(u.user.id))
            .toList();
      }

      emit(
        state.copyWith(
          status: CircleStatus.success,
          following: following,
          suggested: suggested,
          discover: discover,
        ),
      );
    } catch (err) {
      emit(state.copyWith(status: CircleStatus.failure, error: err.toString()));
    }
  }

  Future<void> _onFollowToggled(
    FollowToggled e,
    Emitter<CircleState> emit,
  ) async {
    CircleUserModel? toggledBefore;
    CircleUserModel? toggledAfter;

    List<CircleUserModel> toggle(List<CircleUserModel> list) {
      final idx = list.indexWhere((x) => x.user.id == e.userId);
      if (idx == -1) return list;

      final oldItem = list[idx];
      final newItem = oldItem.copyWith(isFollowed: !oldItem.isFollowed);

      toggledBefore ??= oldItem;
      toggledAfter ??= newItem;

      return [...list]..[idx] = newItem;
    }

    var newFollowing = toggle(state.following);
    var newSuggested = toggle(state.suggested);
    var newDiscover = toggle(state.discover);

    if (toggledBefore == null || toggledAfter == null) return;

    final shouldFollow = toggledBefore!.isFollowed == false;

    if (shouldFollow) {
      newSuggested = newSuggested.where((x) => x.user.id != e.userId).toList();
      newDiscover = newDiscover.where((x) => x.user.id != e.userId).toList();

      final existsInFollowing = newFollowing.any((x) => x.user.id == e.userId);
      if (!existsInFollowing) {
        newFollowing = [
          toggledAfter!.copyWith(isFollowed: true),
          ...newFollowing,
        ];
      } else {
        newFollowing = newFollowing
            .map(
              (x) => x.user.id == e.userId ? x.copyWith(isFollowed: true) : x,
            )
            .toList();
      }
    } else {
      newFollowing = newFollowing.where((x) => x.user.id != e.userId).toList();

      newSuggested = [
        toggledAfter!.copyWith(isFollowed: false),
        ...newSuggested,
      ];
    }

    // Optimistic UI
    emit(
      state.copyWith(
        following: newFollowing,
        suggested: newSuggested,
        discover: newDiscover,
      ),
    );

    try {
      if (shouldFollow) {
        await _repo.follow(e.userId);
      } else {
        await _repo.unfollow(e.userId);
      }
    } catch (_) {
      add(const CircleRefreshRequested());
    }
  }
}
