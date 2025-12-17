import 'package:equatable/equatable.dart';

class CommunityState extends Equatable {
  final int tabIndex;
  final String? profileUserIdToShow;
  const CommunityState({this.tabIndex = 0, this.profileUserIdToShow});

  CommunityState copyWith({
    int? tabIndex,
    String? profileUserIdToShow,
    bool clearSelectedProfileUserId = false,
  }) => CommunityState(
    tabIndex: tabIndex ?? this.tabIndex,
    profileUserIdToShow: clearSelectedProfileUserId
        ? null
        : (profileUserIdToShow ?? this.profileUserIdToShow),
  );

  @override
  List<Object?> get props => [tabIndex, profileUserIdToShow];
}
