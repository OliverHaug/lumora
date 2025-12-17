import 'package:equatable/equatable.dart';

class HealingQuestionModel extends Equatable {
  final String id;
  final String key;
  final String question;
  final String? role;
  final int orderIndex;
  final bool isActive;

  const HealingQuestionModel({
    required this.id,
    required this.key,
    required this.question,
    required this.role,
    required this.orderIndex,
    required this.isActive,
  });

  factory HealingQuestionModel.fromMap(Map<String, dynamic> m) {
    return HealingQuestionModel(
      id: m['id'] as String,
      key: m['key'] as String,
      question: (m['question'] ?? '') as String,
      role: m['role'] as String?,
      orderIndex: (m['order_index'] ?? 0) as int,
      isActive: (m['is_active'] ?? true) as bool,
    );
  }

  @override
  List<Object?> get props => [id, key, question, role, orderIndex, isActive];
}
