import 'package:equatable/equatable.dart';
import 'package:lumora/features/community/tabs/following/data/circle_user_model.dart';
import 'circle_event.dart';

enum CircleStatus { initial, loading, success, failure }

class CircleState extends Equatable {
  final CircleStatus status;
  final CircleTabMode mode;
  final String query;

  final List<CircleUserModel> following;
  final List<CircleUserModel> suggested; // 👈 wichtig für Mockup
  final List<CircleUserModel> discover; // results (query)

  final String? error;

  const CircleState({
    this.status = CircleStatus.initial,
    this.mode = CircleTabMode.following,
    this.query = '',
    this.following = const [],
    this.suggested = const [],
    this.discover = const [],
    this.error,
  });

  CircleState copyWith({
    CircleStatus? status,
    CircleTabMode? mode,
    String? query,
    List<CircleUserModel>? following,
    List<CircleUserModel>? suggested,
    List<CircleUserModel>? discover,
    String? error,
  }) {
    return CircleState(
      status: status ?? this.status,
      mode: mode ?? this.mode,
      query: query ?? this.query,
      following: following ?? this.following,
      suggested: suggested ?? this.suggested,
      discover: discover ?? this.discover,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    status,
    mode,
    query,
    following,
    suggested,
    discover,
    error,
  ];
}
