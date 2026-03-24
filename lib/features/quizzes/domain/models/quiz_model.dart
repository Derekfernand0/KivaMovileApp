class QuizQuestion {
  final String questionText;
  final String type; // 👈 NUEVO: 'multiple_choice' (cerrada) o 'open' (abierta)
  final List<String> options;
  final int correctOptionIndex;
  final int points;

  QuizQuestion({
    required this.questionText,
    this.type = 'multiple_choice', // Por defecto es cerrada
    required this.options,
    required this.correctOptionIndex,
    required this.points,
  });

  Map<String, dynamic> toMap() => {
    'questionText': questionText,
    'type': type,
    'options': options,
    'correctOptionIndex': correctOptionIndex,
    'points': points,
  };

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      questionText: map['questionText'] ?? '',
      type: map['type'] ?? 'multiple_choice',
      options: List<String>.from(map['options'] ?? []),
      correctOptionIndex: map['correctOptionIndex'] ?? 0,
      points: map['points']?.toInt() ?? 10,
    );
  }
}

class QuizModel {
  final String id;
  final String title;
  final String description;
  final List<QuizQuestion> questions;
  final bool isPremade;
  final String? hostId; // 👈 NUEVO: Para saber qué maestro lo creó

  QuizModel({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
    this.isPremade = false,
    this.hostId,
  });

  int get totalPossibleScore {
    return questions.fold(0, (sum, question) => sum + question.points);
  }

  // 👇 Para poder guardarlo en Firebase
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'questions': questions.map((q) => q.toMap()).toList(),
      'isPremade': isPremade,
      'hostId': hostId,
    };
  }

  factory QuizModel.fromMap(Map<String, dynamic> map, String docId) {
    return QuizModel(
      id: docId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      questions:
          (map['questions'] as List<dynamic>?)
              ?.map((q) => QuizQuestion.fromMap(q as Map<String, dynamic>))
              .toList() ??
          [],
      isPremade: map['isPremade'] ?? false,
      hostId: map['hostId'],
    );
  }
}
