import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String name;
  final String? avatarUrl;
  final String? avatarPath;
  final String? bio;
  final String role;
  final String? headline;
  final DateTime? createdAt;

  const UserModel({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.avatarPath,
    this.bio,
    required this.role,
    this.headline,
    this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      name: map['name'] ?? 'Unknown',
      avatarUrl: map['avatar_url'] as String?,
      avatarPath: map['avatar_path'] as String?,
      bio: map['bio'] as String?,
      role: map['role'] as String,
      headline: map['headline'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'avatar_url': avatarUrl,
    'avatar_path': avatarPath,
    'bio': bio,
    'role': role,
    'headline': headline,
    'created_at': createdAt?.toIso8601String(),
  };

  @override
  List<Object?> get props => [
    id,
    name,
    avatarUrl,
    avatarPath,
    bio,
    role,
    headline,
    createdAt,
  ];
}
