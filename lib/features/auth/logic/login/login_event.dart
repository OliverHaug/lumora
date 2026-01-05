part of 'login_bloc.dart';

sealed class LoginEvent extends Equatable {}

class LoginEmailChanged extends LoginEvent {
  final String email;
  LoginEmailChanged(this.email);

  @override
  List<Object?> get props => [email];
}

class LoginPasswordChanged extends LoginEvent {
  final String password;
  LoginPasswordChanged(this.password);
  @override
  List<Object?> get props => [password];
}

class LoginReset extends LoginEvent {
  @override
  List<Object?> get props => [];
}

class LoginSubmitted extends LoginEvent {
  @override
  List<Object?> get props => [];
}
