import 'package:equatable/equatable.dart';
import 'package:xyz/features/community/tabs/profile/data/healing_qa_model.dart';
import 'package:xyz/features/settings/data/user_model.dart';
import 'package:xyz/features/community/tabs/posts/data/post_models.dart';

enum ProfileStatus { initial, loading, success, failure }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final String? viewingUserId;
  final bool isMe;

  final UserModel? user;
  final List<PostModel> posts;

  final List<String> galleryUrls;
  final List<HealingQAModel> healing;

  final String? error;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.viewingUserId,
    this.isMe = true,
    this.user,
    this.posts = const [],
    this.galleryUrls = const [],
    this.healing = const [],
    this.error,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    String? viewingUserId,
    bool? isMe,
    UserModel? user,
    List<PostModel>? posts,
    List<String>? galleryUrls,
    List<HealingQAModel>? healing,
    String? error,
  }) {
    return ProfileState(
      status: status ?? this.status,
      viewingUserId: viewingUserId ?? this.viewingUserId,
      isMe: isMe ?? this.isMe,
      user: user ?? this.user,
      posts: posts ?? this.posts,
      galleryUrls: galleryUrls ?? this.galleryUrls,
      healing: healing ?? this.healing,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    status,
    viewingUserId,
    isMe,
    user,
    posts,
    galleryUrls,
    healing,
    error,
  ];
}
