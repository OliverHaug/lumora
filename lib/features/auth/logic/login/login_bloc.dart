import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xyz/features/auth/data/auth_repository.dart';
import 'package:xyz/features/auth/logic/login/login_event.dart';
import 'package:xyz/features/auth/logic/login/login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository _repo;

  LoginBloc(this._repo) : super(LoginState()) {
    on<LoginEmailChanged>((e, emit) => emit(state.copyWith(email: e.email)));
    on<LoginPasswordChanged>(
      (e, emit) => emit(state.copyWith(password: e.password)),
    );
    on<LoginReset>(
      (e, emit) =>
          emit(state.copyWith(status: LoginStatus.initial, error: null)),
    );
    on<LoginSubmitted>(_onSubmit);
  }

  Future<void> _onSubmit(LoginSubmitted event, Emitter<LoginState> emit) async {
    emit(state.copyWith(status: LoginStatus.loading));
    try {
      await _repo.login(email: state.email.trim(), password: state.password);
      emit(state.copyWith(status: LoginStatus.success));
    } catch (e) {
      emit(state.copyWith(status: LoginStatus.failure, error: e.toString()));
    }
  }
}
