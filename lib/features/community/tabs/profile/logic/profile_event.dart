import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

class ProfileRefreshed extends ProfileEvent {
  final String? userId;
  const ProfileRefreshed({this.userId});
}

class ProfileUserChanged extends ProfileEvent {
  final String? userId;
  const ProfileUserChanged({this.userId});

  @override
  List<Object?> get props => [userId];
}
