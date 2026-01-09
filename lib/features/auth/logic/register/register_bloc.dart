import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumora/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:lumora/core/errors/result.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final SignUpUseCase _signUp;

  RegisterBloc({required SignUpUseCase signUp})
    : _signUp = signUp,
      super(RegisterState()) {
    on<RegisterEmailChanged>((e, emit) {
      emit(state.copyWith(email: e.email, error: null));
    });

    on<RegisterPasswordChanged>((e, emit) {
      emit(state.copyWith(password: e.password, error: null));
    });
    on<RegisterConfirmPasswordChanged>((e, emit) {
      emit(state.copyWith(confirmPassword: e.confirmPassword, error: null));
    });

    on<RegisterSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    final email = state.email.trim();
    final password = state.password;
    final confirm = state.confirmPassword;

    if (email.isEmpty || !email.contains('@')) {
      emit(
        state.copyWith(
          status: RegisterStatus.failure,
          error: 'Please enter a valid email.',
        ),
      );
      return;
    }
    if (password.length < 8) {
      emit(
        state.copyWith(
          status: RegisterStatus.failure,
          error: 'Password must be at least 8 characters.',
        ),
      );
      return;
    }
    if (password != confirm) {
      emit(
        state.copyWith(
          status: RegisterStatus.failure,
          error: 'Passwords do not match.',
        ),
      );
      return;
    }

    emit(state.copyWith(status: RegisterStatus.loading, error: null));

    final result = await _signUp(email: email, password: password);

    if (result is Error<void>) {
      emit(
        state.copyWith(
          status: RegisterStatus.failure,
          error: result.failure.message,
        ),
      );
      return;
    }

    emit(state.copyWith(status: RegisterStatus.success));
  }
}
