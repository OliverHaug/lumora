import 'package:equatable/equatable.dart';
import 'package:lumora/features/community/tabs/profile/data/healing_question_model.dart';

class HealingQAModel extends Equatable {
  final HealingQuestionModel question;
  final String answer; // leer erlaubt

  const HealingQAModel({required this.question, required this.answer});

  HealingQAModel copyWith({String? answer}) =>
      HealingQAModel(question: question, answer: answer ?? this.answer);

  @override
  List<Object?> get props => [question, answer];
}
