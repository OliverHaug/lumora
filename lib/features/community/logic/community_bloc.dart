import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xyz/features/community/logic/community_event.dart';
import 'package:xyz/features/community/logic/community_state.dart';

class CommunityBloc extends Bloc<CommunityEvent, CommunityState> {
  CommunityBloc() : super(const CommunityState()) {
    on<CommunityTabChanged>(
      (e, emit) => emit(
        state.copyWith(tabIndex: e.index, clearSelectedProfileUserId: true),
      ),
    );
    on<CommunityShowProfile>(
      (e, emit) =>
          emit(state.copyWith(tabIndex: 2, profileUserIdToShow: e.userId)),
    );
  }
}
