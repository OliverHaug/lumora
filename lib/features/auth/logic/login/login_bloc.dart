import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xyz/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:xyz/core/errors/result.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final SignInUseCase _signIn;

  LoginBloc({required SignInUseCase signIn})
    : _signIn = signIn,
      super(LoginState()) {
    on<LoginSubmitted>(_onSubmitted);
    on<LoginEmailChanged>((e, emit) => emit(state.copyWith(email: e.email)));
    on<LoginPasswordChanged>(
      (e, emit) => emit(state.copyWith(password: e.password)),
    );
    on<LoginReset>(
      (e, emit) =>
          emit(state.copyWith(error: null, status: LoginStatus.initial)),
    );
  }

  Future<void> _onSubmitted(LoginSubmitted e, Emitter<LoginState> emit) async {
    emit(state.copyWith(status: LoginStatus.loading, error: null));

    final res = await _signIn(
      email: state.email.trim(),
      password: state.password,
    );

    if (res is Error<void>) {
      emit(
        state.copyWith(status: LoginStatus.failure, error: res.failure.message),
      );
      return;
    }

    emit(state.copyWith(status: LoginStatus.success));
  }
}
