import 'package:w3s/models/question.dart';

class QuizState {
  final List<Question> questions;
  final int currentQuestionIndex;
  final List<int?> userAnswers;
  final bool isCompleted;
  final int score;

  QuizState({
    required this.questions,
    this.currentQuestionIndex = 0,
    required this.userAnswers,
    this.isCompleted = false,
    this.score = 0,
  });

  QuizState copyWith({
    List<Question>? questions,
    int? currentQuestionIndex,
    List<int?>? userAnswers,
    bool? isCompleted,
    int? score,
  }) {
    return QuizState(
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      userAnswers: userAnswers ?? this.userAnswers,
      isCompleted: isCompleted ?? this.isCompleted,
      score: score ?? this.score,
    );
  }

  Question get currentQuestion => questions[currentQuestionIndex];
  bool get isLastQuestion => currentQuestionIndex == questions.length - 1;
  int get totalQuestions => questions.length;
  double get progress => (currentQuestionIndex + 1) / questions.length;
}
