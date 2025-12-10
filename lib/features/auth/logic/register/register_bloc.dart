import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xyz/features/auth/data/auth_repository.dart';
import 'package:xyz/features/auth/logic/register/register_event.dart';
import 'package:xyz/features/auth/logic/register/register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final AuthRepository _repo;

  RegisterBloc(this._repo) : super(RegisterState()) {
    on<RegisterEmailChanged>((e, emit) => emit(state.copyWith(email: e.email)));
    on<RegisterPasswordChanged>(
      (e, emit) => emit(state.copyWith(password: e.password)),
    );
    on<RegisterConfirmPasswordChanged>(
      (e, emit) => emit(state.copyWith(confirmPassword: e.password)),
    );
    on<RegisterReset>(
      (e, emit) =>
          emit(state.copyWith(status: RegisterStatus.initial, error: null)),
    );
    on<RegisterSubmitted>(_onSubmit);
  }

  Future<void> _onSubmit(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    emit(state.copyWith(status: RegisterStatus.loading));

    if (state.password != state.confirmPassword) {
      emit(
        state.copyWith(
          status: RegisterStatus.failure,
          error: 'Passwords do not match',
        ),
      );
      return;
    }

    try {
      await _repo.register(state.email.trim(), state.password);
      emit(state.copyWith(status: RegisterStatus.success));
    } catch (e) {
      emit(state.copyWith(status: RegisterStatus.failure, error: e.toString()));
    }
  }
}
