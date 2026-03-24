class QuizQuestion {
  final String questionText;
  final List<String> options;
  final int correctOptionIndex;

  QuizQuestion({
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
  });

  Map<String, dynamic> toMap() => {
    'questionText': questionText,
    'options': options,
    'correctOptionIndex': correctOptionIndex,
  };

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      questionText: map['questionText'],
      options: List<String>.from(map['options']),
      correctOptionIndex: map['correctOptionIndex'],
    );
  }
}

class QuizModel {
  final String id;
  final String title;
  final String description;
  final List<QuizQuestion> questions;
  final bool isPremade;

  QuizModel({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
    this.isPremade = false,
  });
}
