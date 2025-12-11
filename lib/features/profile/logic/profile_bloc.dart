import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xyz/features/auth/data/auth_repository.dart';
import 'package:xyz/features/profile/logic/profile_event.dart';
import 'package:xyz/features/profile/logic/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AuthRepository _repo;

  ProfileBloc(this._repo) : super(ProfileState()) {
    on<Logout>((e, emit) => _repo.signOut());
  }
}
