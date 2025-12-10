abstract class RegisterEvent {}

class RegisterEmailChanged extends RegisterEvent {
  final String email;
  RegisterEmailChanged(this.email);
}

class RegisterPasswordChanged extends RegisterEvent {
  final String password;
  RegisterPasswordChanged(this.password);
}

class RegisterConfirmPasswordChanged extends RegisterEvent {
  final String password;
  RegisterConfirmPasswordChanged(this.password);
}

class RegisterReset extends RegisterEvent {}

class RegisterSubmitted extends RegisterEvent {}
