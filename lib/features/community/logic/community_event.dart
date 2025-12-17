abstract class CommunityEvent {}

class CommunityTabChanged extends CommunityEvent {
  final int index;
  CommunityTabChanged(this.index);
}

class CommunityShowProfile extends CommunityEvent {
  final String userId;
  CommunityShowProfile(this.userId);
}
