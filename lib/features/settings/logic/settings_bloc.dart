import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xyz/features/auth/data/auth_repository.dart';
import 'package:xyz/features/settings/logic/settings_event.dart';
import 'package:xyz/features/settings/logic/settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final AuthRepository _repo;

  SettingsBloc(this._repo) : super(SettingsState()) {
    on<Logout>((e, emit) => _repo.signOut());
  }
}
