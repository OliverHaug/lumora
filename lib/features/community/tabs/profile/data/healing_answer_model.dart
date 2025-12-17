import 'package:equatable/equatable.dart';

class HealingAnswerModel extends Equatable {
  final String questionId;
  final String answer;

  const HealingAnswerModel({required this.questionId, required this.answer});

  factory HealingAnswerModel.fromMap(Map<String, dynamic> m) {
    return HealingAnswerModel(
      questionId: m['question_id'] as String,
      answer: (m['answer'] ?? '') as String,
    );
  }

  @override
  List<Object?> get props => [questionId, answer];
}
