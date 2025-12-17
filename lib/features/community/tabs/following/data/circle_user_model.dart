import 'package:equatable/equatable.dart';
import 'package:xyz/features/settings/data/user_model.dart';

class CircleUserModel extends Equatable {
  final UserModel user;
  final bool isFollowed;

  const CircleUserModel({required this.user, required this.isFollowed});

  factory CircleUserModel.fromMap(Map<String, dynamic> map) {
    return CircleUserModel(
      user: UserModel.fromMap(map),
      isFollowed: (map['is_followed'] as bool?) ?? false,
    );
  }

  CircleUserModel copyWith({UserModel? user, bool? isFollowed}) {
    return CircleUserModel(
      user: user ?? this.user,
      isFollowed: isFollowed ?? this.isFollowed,
    );
  }

  @override
  List<Object?> get props => [user, isFollowed];
}
