import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

class ProfileStarted extends ProfileEvent {
  final String? userId;
  const ProfileStarted({this.userId});

  @override
  List<Object?> get props => [userId];
}

class ProfileRefreshed extends ProfileEvent {
  const ProfileRefreshed();
}

class ProfileUserChanged extends ProfileEvent {
  final String? userId;
  const ProfileUserChanged({this.userId});

  @override
  List<Object?> get props => [userId];
}
